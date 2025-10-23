import Foundation
import UIKit


extension String {
    /// 문자열을 지정된 최대 길이로 자르고, 잘린 경우 "..."을 추가합니다.
    ///
    /// 문자열의 길이가 `maximumCharacters`보다 작거나 같으면 원본 문자열을 반환합니다.
    /// - Parameter maximumCharacters: 문자열을 자를 최대 길이입니다.
    /// - Returns: 잘리거나 원본 문자열입니다.
    func trim(to maximumCharacters: Int) -> String {
        guard self.count > maximumCharacters else {
            return self
        }
        return "\(self[..<index(startIndex, offsetBy: maximumCharacters)])" + "..."
    }
}
public extension NSAttributedString.Key {
    /// 텍스트 범위와 연결된 `InteractiveElement`를 저장하기 위한 사용자 정의 속성 키입니다.
    static let interactiveElement = NSAttributedString.Key("InteractiveElement")
    /// 텍스트 범위와 연결된 `InteractiveType`을 저장하기 위한 사용자 정의 속성 키입니다.
    static let interactiveType = NSAttributedString.Key("InteractiveType")
    /// 상호작용 요소의 일반 색상을 저장하기 위한 사용자 정의 속성 키입니다.
    static let interactiveColor = NSAttributedString.Key("InteractiveColor")
    /// 상호작용 요소가 선택되었을 때의 색상을 저장하기 위한 사용자 정의 속성 키입니다.
    static let interactiveSelectedColor = NSAttributedString.Key("InteractiveSelectedColor")
}