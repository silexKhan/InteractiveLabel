
import UIKit
import Combine

/// 상호작용 요소의 속성을 사용자 정의하기 위한 클로저 타입입니다.
/// - Parameters:
///   - InteractiveType: 현재 처리중인 상호작용 요소의 타입입니다.
///   - [NSAttributedString.Key: Any]: 기본적으로 적용될 속성들입니다.
///   - Bool: 현재 요소가 선택된 상태인지 여부를 나타냅니다.
/// - Returns: 사용자 정의가 적용된 새로운 속성 딕셔너리를 반환해야 합니다.
public typealias ConfigureInteractiveAttribute = ((InteractiveType, [NSAttributedString.Key: Any], Bool) -> ([NSAttributedString.Key: Any]))

/**
 텍스트 내에서 특정 패턴(멘션, 해시태그, URL 등)을 감지하여 상호작용을 가능하게 하는 `UILabel`의 서브클래스입니다.

 이 레이블은 텍스트의 일부를 탭 가능하게 만들고, 탭했을 때의 동작과 모양을 유연하게 사용자 정의할 수 있는 기능을 제공합니다.
 모든 설정은 `config` 프로퍼티를 통해 관리되며, 탭 이벤트는 Combine `PassthroughSubject`를 통해 전달됩니다.

 ## 사용 예제
 ```swift
 let label = InteractiveLabel()
 label.text = "이 레이블은 #해시태그 와 @멘션, 그리고 http://github.com 같은 URL을 감지합니다."

 // 활성화할 타입 설정
 label.enabledTypes = [.hashtag, .mention, .url]

 // 특정 타입의 색상 변경
 label.config.hashtagColor = .purple
 label.config.mentionColor = .green

 // 탭 이벤트 처리 (Combine 사용)
 let cancellable = label.didTap.sink { element in
     switch element {
     case .hashtag(let hashtag):
         print("Tapped hashtag: \(hashtag)")
     case .mention(let mention):
         print("Tapped mention: \(mention)")
     case .url(let url, _):
         print("Tapped URL: \(url)")
     default:
         break
     }
 }
 ```
*/
public class InteractiveLabel: UILabel {


    /// 레이블의 모든 모양과 동작을 제어하는 설정 객체입니다.
    public var config = InteractiveLabelConfig() { didSet { textManager.updateTextStorage() } }
    /// 레이블이 감지할 상호작용 요소의 유형 배열입니다.
    public var enabledTypes: [InteractiveType] = [] { didSet { textManager.updateTextStorage() } }
    /// 상호작용 요소의 속성을 외부에서 동적으로 구성하기 위한 클로저입니다.
    public var configureInteractiveAttribute: ConfigureInteractiveAttribute? { didSet { textManager.updateTextStorage() } }
    /// 상호작용 요소를 탭했을 때 `InteractiveElement`를 방출하는 Combine `PassthroughSubject`입니다.
    public var didTap = PassthroughSubject<InteractiveElement, Never>()


    /// 사용자 정의 타입에 대한 필터 클로저를 저장하는 딕셔너리입니다.
    var customFilters: [InteractiveType: InteractiveFilterPredicate?] = [:]
    /// 내부적으로 사용되는 상호작용 관련 속성 키 배열입니다.
    static let interactiveAttributes: [NSAttributedString.Key] = [
        .font, .foregroundColor, .paragraphStyle, .interactiveElement, .interactiveType, .interactiveColor, .interactiveSelectedColor
    ]


    /// `customize` 블록 실행 중 불필요한 `updateTextStorage` 호출을 방지하기 위한 플래그입니다.
    private var _customizing: Bool = false
    /// 텍스트 처리를 담당하는 매니저 객체입니다.
    private lazy var textManager: InteractiveTextManager = InteractiveTextManager(label: self)
    /// 터치 이벤트를 담당하는 매니저 객체입니다.
    private lazy var touchManager: InteractiveTouchManager = InteractiveTouchManager(label: self, textManager: self.textManager)


    override public var attributedText: NSAttributedString? {
        didSet { textManager.updateTextStorage() }
    }

    override public var font: UIFont! {
        didSet { textManager.updateTextStorage() }
    }

    override public var textColor: UIColor! {
        didSet { textManager.updateTextStorage() }
    }
    
    override public var textAlignment: NSTextAlignment {
        didSet { textManager.updateTextStorage() }
    }

    override public var lineBreakMode: NSLineBreakMode {
        didSet { textManager.updateTextStorage() }
    }

    override public var numberOfLines: Int {
        didSet {
            textManager.textContainer.maximumNumberOfLines = numberOfLines
            textManager.updateTextStorage()
        }
    }


    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    /// 초기화 시 공통으로 수행하는 설정 작업을 담당합니다.
    private func commonInit() {
        textAlignment = .left
        lineBreakMode = .byWordWrapping
        isUserInteractionEnabled = true
        numberOfLines = 0
    }


    
    /// 사용자 정의 상호작용 타입을 등록하고 관련 동작을 설정합니다.
    /// - Parameters:
    ///   - type: 등록할 사용자 정의 타입. `.custom(pattern: ...)` 형태여야 합니다.
    ///   - filter: 해당 패턴에 일치한 문자열을 요소로 포함할지 결정하는 필터 클로저입니다.
    ///   - handler: 해당 요소를 탭했을 때 실행될 핸들러 클로저입니다.
    public func handleCustom(for type: InteractiveType, with filter: InteractiveFilterPredicate? = nil, handler: ((String) -> Void)?) {
        guard case .custom = type else { return }
        customFilters[type] = filter
        if let handler = handler {
            touchManager.customSelectedHandler[type] = handler
        }
        textManager.updateTextStorage()
    }

    /// 등록된 사용자 정의 타입의 핸들러를 제거합니다.
    /// - Parameter type: 핸들러를 제거할 사용자 정의 타입입니다.
    public func removeHandle(for type: InteractiveType) {
        customFilters[type] = nil
        touchManager.customSelectedHandler[type] = nil
        textManager.updateTextStorage()
    }

    /// 여러 속성을 한 번에 변경하고 텍스트 업데이트는 마지막에 한 번만 수행하여 성능을 향상시킵니다.
    /// - Parameter block: `InteractiveLabel` 인스턴스를 받아 속성을 변경하는 클로저입니다.
    /// - Returns: 변경된 `InteractiveLabel` 인스턴스를 반환합니다.
    @discardableResult
    public func customize(_ block: (InteractiveLabel) -> Void) -> InteractiveLabel {
        _customizing = true
        block(self)
        _customizing = false
        textManager.updateTextStorage()
        return self
    }
    

    override public func drawText(in rect: CGRect) {
        textManager.drawText(in: rect)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        textManager.textContainer.size = bounds.size
    }
    
    override public var intrinsicContentSize: CGSize {
        return textManager.intrinsicContentSize()
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        return textManager.sizeThatFits(size)
    }
    

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchManager.onTouch(touch, .began)
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchManager.onTouch(touch, .moved)
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchManager.onTouch(touch, .ended)
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchManager.onTouch(touch, .cancelled)
    }
}
