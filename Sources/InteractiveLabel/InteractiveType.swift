
import Foundation

/// `InteractiveLabel` 텍스트 내에서 감지되는 상호작용 가능한 요소를 나타냅니다.
///
/// 이 열거형은 요소의 유형(예: 멘션, 해시태그, URL)과 관련 문자열 값을 캡슐화합니다.
public enum InteractiveElement {
    /// 일반적으로 '@'로 시작하는 멘션입니다. 관련 값은 멘션된 사용자 이름입니다.
    case mention(String)
    /// 일반적으로 '#'으로 시작하는 해시태그입니다. 관련 값은 해시태그 텍스트입니다.
    case hashtag(String)
    /// 이메일 주소입니다. 관련 값은 이메일 문자열입니다.
    case email(String)
    /// URL입니다. 관련 값은 원본 URL 문자열과 표시를 위해 잠재적으로 잘린 버전입니다.
    case url(original: String, trimmed: String)
    /// 정규 표현식으로 정의된 사용자 정의 요소입니다. 관련 값은 일치하는 문자열입니다.
    case custom(String)

    /// 주어진 `InteractiveType`과 텍스트를 기반으로 `InteractiveElement` 인스턴스를 생성합니다.
    /// - Parameters:
    ///   - interactiveType: 생성할 요소의 타입입니다.
    ///   - text: 요소의 문자열 내용입니다.
    /// - Returns: 제공된 타입과 텍스트에 해당하는 `InteractiveElement` 인스턴스를 반환합니다.
    static func create(with interactiveType: InteractiveType, text: String) -> InteractiveElement {
        switch interactiveType {
        case .mention: return .mention(text)
        case .hashtag: return .hashtag(text)
        case .email: return .email(text)
        case .url: return .url(original: text, trimmed: text)
        case .custom: return .custom(text)
        }
    }
}

extension InteractiveElement: Equatable {
    public static func ==(lhs: InteractiveElement, rhs: InteractiveElement) -> Bool {
        switch (lhs, rhs) {
        case (.mention(let l), .mention(let r)): return l == r
        case (.hashtag(let l), .hashtag(let r)): return l == r
        case (.email(let l), .email(let r)): return l == r
        case (.url(let l), .url(let r)): return l.original == r.original && l.trimmed == r.trimmed
        case (.custom(let l), .custom(let r)): return l == r
        default: return false
        }
    }
}

/// `InteractiveLabel`이 감지하고 상호작용할 수 있는 요소의 유형을 정의합니다.
public enum InteractiveType {
    /// '@'로 시작하는 멘션을 감지합니다.
    case mention
    /// '#'으로 시작하는 해시태그를 감지합니다.
    case hashtag
    /// URL(웹 링크)을 감지합니다.
    case url
    /// 이메일 주소를 감지합니다.
    case email
    /// 사용자 정의 정규식 패턴을 감지합니다.
    case custom(pattern: String)

    /// `InteractiveLabelConfig` 객체로부터 해당 `InteractiveType`에 대한 정규식 패턴을 반환합니다.
    /// - Parameter config: 정규식 패턴을 포함하는 설정 객체입니다.
    /// - Returns: 해당 유형에 대한 정규식 패턴 문자열을 반환합니다.
    func pattern(from config: InteractiveLabelConfig) -> String {
        switch self {
        case .mention: return config.mentionPattern
        case .hashtag: return config.hashtagPattern
        case .url: return config.urlPattern
        case .email: return config.emailPattern
        case .custom(let regex): return regex
        }
    }
}

extension InteractiveType: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .mention: hasher.combine(-1)
        case .hashtag: hasher.combine(-2)
        case .url: hasher.combine(-3)
        case .email: hasher.combine(-4)
        case .custom(let regex): hasher.combine(regex)
        }
    }
}

public func ==(lhs: InteractiveType, rhs: InteractiveType) -> Bool {
    switch (lhs, rhs) {
    case (.mention, .mention): return true
    case (.hashtag, .hashtag): return true
    case (.url, .url): return true
    case (.email, .email): return true
    case (.custom(let pattern1), .custom(let pattern2)): return pattern1 == pattern2
    default: return false
    }
}
