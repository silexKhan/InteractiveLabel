import Foundation

/// `InteractiveLabel`에서 사용될 상호작용 가능한 요소를 필터링하기 위한 클로저 타입입니다.
public typealias InteractiveFilterPredicate = ((String) -> Bool)

/// 상호작용 요소의 범위, 요소 자체, 그리고 타입을 캡슐화하는 튜플입니다.
typealias ElementTuple = (range: NSRange, element: InteractiveElement, type: InteractiveType)

/// 텍스트에서 상호작용 가능한 요소를 파싱하고 생성하는 유틸리티 구조체입니다.
struct InteractiveElementParser {

    /// 정규식 객체를 캐싱하여 성능을 향상시키기 위한 저장소입니다.
    private static var cachedRegularExpressions: [String : NSRegularExpression] = [:]

    /// 주어진 타입에 따라 텍스트에서 상호작용 요소를 생성합니다.
    /// - Parameters:
    ///   - type: 생성할 요소의 `InteractiveType`입니다.
    ///   - text: 요소를 검색할 원본 텍스트입니다.
    ///   - range: 검색을 수행할 텍스트의 범위입니다.
    ///   - config: 정규식 패턴을 포함하는 설정 객체입니다.
    ///   - filterPredicate: 요소를 추가할지 결정하는 필터 클로저입니다.
    /// - Returns: 감지된 요소 정보(`ElementTuple`)의 배열을 반환합니다.
    static func createElements(type: InteractiveType, from text: String, range: NSRange, config: InteractiveLabelConfig, filterPredicate: InteractiveFilterPredicate?) -> [ElementTuple] {
        switch type {
        case .mention, .hashtag:
            return createElementsIgnoringFirstCharacter(from: text, for: type, range: range, config: config, filterPredicate: filterPredicate)
        case .url:
            return createElements(from: text, for: type, range: range, config: config, filterPredicate: filterPredicate)
        case .custom:
            return createElements(from: text, for: type, range: range, config: config, minLength: 1, filterPredicate: filterPredicate)
        case .email:
            return createElements(from: text, for: type, range: range, config: config, filterPredicate: filterPredicate)
        }
    }

    /// 텍스트에서 URL 요소를 생성하고, 필요한 경우 길이를 조절합니다.
    /// - Parameters:
    ///   - text: URL을 검색할 원본 텍스트입니다.
    ///   - range: 검색을 수행할 텍스트의 범위입니다.
    ///   - config: URL 최대 길이 및 정규식 패턴을 포함하는 설정 객체입니다.
    /// - Returns: 감지된 URL 요소와, URL이 잘렸을 경우 수정된 텍스트를 포함하는 튜플을 반환합니다.
    static func createURLElements(from text: String, range: NSRange, config: InteractiveLabelConfig) -> ([ElementTuple], String) {
        let type = InteractiveType.url
        var text = text
        let matches = findMatches(from: text, with: type.pattern(from: config), range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > 2 {
            let word = nsstring.substring(with: match.range).trimmingCharacters(in: .whitespacesAndNewlines)

            guard let maxLength = config.urlMaximumLength, word.count > maxLength else {
                let range = (text as NSString).range(of: word)
                let element = InteractiveElement.create(with: type, text: word)
                elements.append((range, element, type))
                continue
            }

            let trimmedWord = word.trim(to: maxLength)
            text = text.replacingOccurrences(of: word, with: trimmedWord)

            let newRange = (text as NSString).range(of: trimmedWord)
            let element = InteractiveElement.url(original: word, trimmed: trimmedWord)
            elements.append((newRange, element, type))
        }
        return (elements, text)
    }

    /// 주어진 타입에 따라 텍스트에서 일반적인 상호작용 요소를 생성합니다.
    /// - Parameters:
    ///   - text: 요소를 검색할 텍스트입니다.
    ///   - type: 생성할 요소의 타입입니다.
    ///   - range: 검색 범위입니다.
    ///   - config: 정규식 패턴을 담고 있는 설정 객체입니다.
    ///   - minLength: 요소로 간주될 최소 길이입니다.
    ///   - filterPredicate: 요소를 필터링하기 위한 클로저입니다.
    /// - Returns: 감지된 요소 정보의 배열을 반환합니다.
    private static func createElements(from text: String, for type: InteractiveType, range: NSRange, config: InteractiveLabelConfig, minLength: Int = 2, filterPredicate: InteractiveFilterPredicate?) -> [ElementTuple] {
        let pattern = type.pattern(from: config)
        let matches = findMatches(from: text, with: pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > minLength {
            let word = nsstring.substring(with: match.range).trimmingCharacters(in: .whitespacesAndNewlines)
            if filterPredicate?(word) ?? true {
                let element = InteractiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }

    /// 멘션이나 해시태그처럼 첫 글자(예: '@', '#')를 무시하고 요소를 생성합니다.
    /// - Parameters:
    ///   - text: 요소를 검색할 텍스트입니다.
    ///   - type: 생성할 요소의 타입입니다.
    ///   - range: 검색 범위입니다.
    ///   - config: 정규식 패턴을 담고 있는 설정 객체입니다.
    ///   - filterPredicate: 요소를 필터링하기 위한 클로저입니다.
    /// - Returns: 감지된 요소 정보의 배열을 반환합니다.
    private static func createElementsIgnoringFirstCharacter(from text: String, for type: InteractiveType, range: NSRange, config: InteractiveLabelConfig, filterPredicate: InteractiveFilterPredicate?) -> [ElementTuple] {
        let pattern = type.pattern(from: config)
        let matches = findMatches(from: text, with: pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > 2 {
            let range = NSRange(location: match.range.location + 1, length: match.range.length - 1)
            var word = nsstring.substring(with: range)
            if word.hasPrefix("@") { word.remove(at: word.startIndex) }
            else if word.hasPrefix("#") { word.remove(at: word.startIndex) }

            if filterPredicate?(word) ?? true {
                let element = InteractiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }
    
    /// 주어진 패턴에 일치하는 모든 결과를 텍스트에서 찾아 반환합니다.
    /// - Parameters:
    ///   - text: 검색할 텍스트입니다.
    ///   - pattern: 검색할 정규식 패턴입니다.
    ///   - range: 검색 범위입니다.
    /// - Returns: 일치하는 `NSTextCheckingResult`의 배열을 반환합니다.
    private static func findMatches(from text: String, with pattern: String, range: NSRange) -> [NSTextCheckingResult] {
        guard let elementRegex = regularExpression(for: pattern) else { return [] }
        return elementRegex.matches(in: text, options: [], range: range)
    }

    /// 주어진 패턴에 대한 캐시된 `NSRegularExpression` 객체를 반환하거나, 없으면 새로 생성하여 캐시합니다.
    /// - Parameter pattern: 정규식 패턴 문자열입니다.
    /// - Returns: `NSRegularExpression` 객체를 반환합니다.
    private static func regularExpression(for pattern: String) -> NSRegularExpression? {
        if let regex = cachedRegularExpressions[pattern] {
            return regex
        } else if let createdRegex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            cachedRegularExpressions[pattern] = createdRegex
            return createdRegex
        } else {
            return nil
        }
    }
}