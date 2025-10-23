
import UIKit

/// `InteractiveLabel`의 모양과 동작에 대한 모든 설정을 포함하는 구조체입니다.
public struct InteractiveLabelConfig {

    /// 멘션을 감지하는 데 사용되는 정규식 패턴입니다.
    public var mentionPattern: String
    /// 해시태그를 감지하는 데 사용되는 정규식 패턴입니다.
    public var hashtagPattern: String
    /// URL을 감지하는 데 사용되는 정규식 패턴입니다.
    public var urlPattern: String
    /// 이메일을 감지하는 데 사용되는 정규식 패턴입니다.
    public var emailPattern: String


    /// 감지된 멘션 요소에 적용할 색상입니다.
    public var mentionColor: UIColor
    /// 감지된 해시태그 요소에 적용할 색상입니다.
    public var hashtagColor: UIColor
    /// 감지된 URL 요소에 적용할 색상입니다.
    public var urlColor: UIColor
    /// 감지된 이메일 주소 요소에 적용할 색상입니다.
    public var emailColor: UIColor
    /// 감지된 사용자 정의 활성 요소에 적용할 색상입니다.
    public var customColor: [InteractiveType: UIColor]


    /// 멘션 요소가 탭되거나 강조 표시될 때 적용할 색상입니다. `nil`인 경우 `mentionColor`가 사용됩니다.
    public var mentionSelectedColor: UIColor?
    /// 해시태그 요소가 탭되거나 강조 표시될 때 적용할 색상입니다. `nil`인 경우 `hashtagColor`가 사용됩니다.
    public var hashtagSelectedColor: UIColor?
    /// URL 요소가 탭되거나 강조 표시될 때 적용할 색상입니다. `nil`인 경우 `urlColor`가 사용됩니다.
    public var urlSelectedColor: UIColor?
    /// 이메일 요소가 탭되거나 강조 표시될 때 적용할 색상입니다. `nil`인 경우 `emailColor`가 사용됩니다.
    public var emailSelectedColor: UIColor?
    /// 사용자 정의 활성 요소가 탭되거나 강조 표시될 때 적용할 색상입니다. `nil`인 경우 `customColor`가 사용됩니다.
    public var customSelectedColor: [InteractiveType: UIColor]


    /// 활성 요소가 강조 표시될 때 적용할 사용자 정의 글꼴 이름입니다.
    public var highlightFontName: String?
    /// 활성 요소가 강조 표시될 때 적용할 사용자 정의 글꼴 크기입니다.
    public var highlightFontSize: CGFloat?


    /// 레이블 텍스트에 적용할 줄 간격입니다.
    public var lineSpacing: CGFloat
    /// 텍스트의 최소 줄 높이를 설정합니다.
    public var minimumLineHeight: CGFloat
    /// URL 문자열의 최대 길이입니다. URL이 이 길이를 초과하면 잘리고 "..."이 추가됩니다. `nil`이면 자르지 않습니다.
    public var urlMaximumLength: Int?

    public init(
        mentionPattern: String = #"(?:^|\s|$|[.])@[\p{L}0-9_]*"#,
        hashtagPattern: String = #"(?:^|\s|$)#[\p{L}0-9_]*"#,
        urlPattern: String = #"(^|[\s.:;?\-\]<\(])((https?://|www\.)[-\w;/?:@&=+$\|\_.!~*'()\[\]%#,☺]+[\w/#](\(\))?)(?=$|[\s',\|\(\).:;?\[\]>\)])"#,
        emailPattern: String = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"#,
        mentionColor: UIColor = .blue,
        hashtagColor: UIColor = .blue,
        urlColor: UIColor = .blue,
        emailColor: UIColor = .blue,
        customColor: [InteractiveType: UIColor] = [:],
        mentionSelectedColor: UIColor? = nil,
        hashtagSelectedColor: UIColor? = nil,
        urlSelectedColor: UIColor? = nil,
        emailSelectedColor: UIColor? = nil,
        customSelectedColor: [InteractiveType: UIColor] = [:],
        highlightFontName: String? = nil,
        highlightFontSize: CGFloat? = nil,
        lineSpacing: CGFloat = 0,
        minimumLineHeight: CGFloat = 0,
        urlMaximumLength: Int? = nil
    ) {
        self.mentionPattern = mentionPattern
        self.hashtagPattern = hashtagPattern
        self.urlPattern = urlPattern
        self.emailPattern = emailPattern
        self.mentionColor = mentionColor
        self.hashtagColor = hashtagColor
        self.urlColor = urlColor
        self.emailColor = emailColor
        self.customColor = customColor
        self.mentionSelectedColor = mentionSelectedColor
        self.hashtagSelectedColor = hashtagSelectedColor
        self.urlSelectedColor = urlSelectedColor
        self.emailSelectedColor = emailSelectedColor
        self.customSelectedColor = customSelectedColor
        self.highlightFontName = highlightFontName
        self.highlightFontSize = highlightFontSize
        self.lineSpacing = lineSpacing
        self.minimumLineHeight = minimumLineHeight
        self.urlMaximumLength = urlMaximumLength
    }
}
