import SwiftUI
import UIKit
import Combine

/// `InteractiveLabel`을 SwiftUI 뷰 계층 구조에서 사용할 수 있도록 하는 `UIViewRepresentable` 래퍼입니다.
public struct InteractiveLabelView: UIViewRepresentable {
    
    /// 표시할 텍스트에 대한 바인딩입니다.
    @Binding var text: String
    /// 레이블의 모양과 동작을 제어하는 설정 객체입니다.
    var config: InteractiveLabelConfig = InteractiveLabelConfig()
    /// 감지할 상호작용 요소의 타입 배열입니다.
    var enabledTypes: [InteractiveType] = []
    /// 상호작용 요소를 탭했을 때 호출될 클로저입니다.
    var onDidTap: ((InteractiveElement) -> Void)?

    /// `InteractiveLabelView`의 새 인스턴스를 초기화합니다.
    /// - Parameters:
    ///   - text: 표시할 텍스트에 대한 `Binding<String>`입니다.
    ///   - config: 레이블의 모양과 동작을 설정하는 `InteractiveLabelConfig` 객체입니다.
    ///   - enabledTypes: 활성화할 상호작용 요소 타입의 배열입니다.
    ///   - onDidTap: 상호작용 요소를 탭했을 때 실행될 클로저입니다.
    public init(
        text: Binding<String>,
        config: InteractiveLabelConfig = InteractiveLabelConfig(),
        enabledTypes: [InteractiveType] = [],
        onDidTap: ((InteractiveElement) -> Void)? = nil
    ) {
        self._text = text
        self.config = config
        self.enabledTypes = enabledTypes
        self.onDidTap = onDidTap
    }

    /// SwiftUI가 뷰를 생성할 때 호출되어 `InteractiveLabel` 인스턴스를 생성합니다.
    /// - Parameter context: 뷰의 컨텍스트 정보입니다.
    /// - Returns: 생성된 `InteractiveLabel` 인스턴스를 반환합니다.
    public func makeUIView(context: Context) -> InteractiveLabel {
        let label = InteractiveLabel()
        label.didTap
            .sink { element in
                self.onDidTap?(element)
            }
            .store(in: &context.coordinator.cancellables)
        return label
    }

    /// SwiftUI 뷰가 업데이트될 때 호출되어 `InteractiveLabel`의 속성을 업데이트합니다.
    /// - Parameters:
    ///   - uiView: 업데이트할 `InteractiveLabel` 인스턴스입니다.
    ///   - context: 뷰의 컨텍스트 정보입니다.
    public func updateUIView(_ uiView: InteractiveLabel, context: Context) {
        uiView.text = text
        uiView.enabledTypes = enabledTypes
        uiView.config = config
    }

    /// `UIViewRepresentable`을 위한 코디네이터를 생성합니다.
    /// - Returns: `Coordinator`의 새 인스턴스를 반환합니다.
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    /// `InteractiveLabelView`의 코디네이터 클래스입니다.
    /// Combine 구독을 관리하는 역할을 합니다.
    public class Coordinator: NSObject {
        var cancellables = Set<AnyCancellable>()
    }
}