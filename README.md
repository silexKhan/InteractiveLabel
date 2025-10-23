<p align="center">
  <b><a href="#--korean">🇰🇷 한국어</a></b>
  &nbsp;&nbsp;|&nbsp;&nbsp;
  <b><a href="#--english">🇺🇸 English</a></b>
</p>

---

## <a name="--korean"></a> 🇰🇷 한국어

# InteractiveLabel
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

`InteractiveLabel`은 텍스트 내에서 해시태그, 멘션, URL, 이메일, 사용자 정의 패턴 등을 감지하여 상호작용을 가능하게 하는 강력하고 유연한 `UILabel` 서브클래스입니다.

이 프로젝트는 더 이상 유지보수되지 않는 [optonaut/ActiveLabel.swift](https://github.com/optonaut/ActiveLabel.swift)의 좋은 기능과 아이디어에 모티브를 얻어, 현대적인 Swift 기능(Combine, SwiftUI)과 더 나은 아키텍처를 적용하여 새롭게 만들어졌습니다.

## ✨ 특징 (Features)

- **다양한 타입 감지**: 해시태그(#), 멘션(@), URL, 이메일 기본 지원
- **사용자 정의 패턴**: 정규식을 사용하여 원하는 모든 패턴을 감지하고 처리
- **설정 객체 기반의 손쉬운 커스터마이징**: `InteractiveLabelConfig` 객체를 통해 색상, 폰트, 줄 간격 등 모든 시각적 요소를 한 곳에서 관리
- **현대적인 이벤트 처리**: Combine `PassthroughSubject` (`didTap`)를 통해 탭 이벤트를 반응형으로 처리
- **풍부한 터치 경험**: 터치가 시작되는 즉시 하이라이트가 적용되고, 터치 위치를 벗어나면 해제되는 등 섬세한 상호작용 제공
- **SwiftUI 지원**: `InteractiveLabelView`를 통해 SwiftUI 프로젝트에서 손쉽게 사용 가능
- **깔끔한 아키텍처**: `TextManager`, `TouchManager` 등 역할별로 책임이 명확하게 분리되어 유지보수 및 확장이 용이

## 📋 요구사항 (Requirements)

- **iOS**: 13.0+
- **Xcode**: 14.0+
- **Swift**: 5.0+

## 📦 설치 (Installation)

### Swift Package Manager (SPM)

Xcode에서 `File > Add Packages...`를 선택하고, 아래의 저장소 URL을 추가합니다.

```
https://github.com/silexKhan/InteractiveLabel.git
```

## 🚀 사용법 (Usage)

```swift
import UIKit
import Combine
import InteractiveLabel

class ViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = InteractiveLabel()
        label.numberOfLines = 0
        label.text = "#해시태그, @멘션, URL(https://github.com)을 눌러보세요."
        label.enabledTypes = [.hashtag, .mention, .url]
        
        view.addSubview(label)
        // ... 오토레이아웃 설정 ...
        
        // 탭 이벤트 처리
        label.didTap
            .sink { element in
                self.handleTap(on: element)
            }
            .store(in: &cancellables)
    }
    
    func handleTap(on element: InteractiveElement) {
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
}
```

## ⚙️ 설정 (Configuration)

`InteractiveLabel`의 모든 시각적 요소와 정규식 패턴은 `config` 프로퍼티를 통해 변경할 수 있습니다.

```swift
// InteractiveLabel 인스턴스 생성 후

// 색상 변경
label.config.hashtagColor = .systemPurple
label.config.hashtagSelectedColor = .systemIndigo
label.config.mentionColor = .systemOrange

// 하이라이트 시 폰트 변경
label.config.highlightFontName = "Helvetica-Bold"
label.config.highlightFontSize = label.font.pointSize

// URL 최대 길이 설정
label.config.urlMaximumLength = 30

// 사용자 정의 패턴 추가
let customType = InteractiveType.custom(pattern: "silex")
label.enabledTypes.append(customType)
label.config.customColor[customType] = .systemGreen

label.handleCustom(for: customType) { customString in
    print("Custom type tapped: \(customString)")
}
```

## 🤝 기여 방법 (Contributing)

이슈 제보 및 기능 제안, Pull Request 등 모든 종류의 기여를 환영합니다. 

## 🔗 대안 라이브러리 (Alternatives)

- [ActiveLabel.swift](https://github.com/optonaut/ActiveLabel.swift) (이 프로젝트의 모티브)
- [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel)
- [KILabel](https://github.com/Krelborn/KILabel)

## 👨‍💻 작성자 (Author)

- **silex**
- **Email**: realsilex@gmail.com

## 📄 라이선스 (License)

`InteractiveLabel`은 MIT 라이선스에 따라 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참고하십시오.

---

## <a name="--english"></a> 🇺🇸 English

# InteractiveLabel
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

`InteractiveLabel` is a powerful and flexible `UILabel` subclass that detects patterns like hashtags, mentions, URLs, emails, and custom patterns within text, enabling interaction.

This project was inspired by the great features and ideas of the no-longer-maintained [optonaut/ActiveLabel.swift](https://github.com/optonaut/ActiveLabel.swift), and has been newly created with modern Swift features (Combine, SwiftUI) and a better architecture.

## ✨ Features

- **Multiple Type Detection**: Default support for hashtags (#), mentions (@), URLs, and emails.
- **Custom Patterns**: Detect and handle any custom pattern using regular expressions.
- **Easy Customization via Config Object**: Manage all visual elements like colors, fonts, and line spacing in one place with the `InteractiveLabelConfig` object.
- **Modern Event Handling**: Handle tap events reactively through a Combine `PassthroughSubject` (`didTap`).
- **Rich Touch Experience**: Provides delicate interactions, such as highlighting immediately on touch-down and releasing when the touch moves away.
- **SwiftUI Support**: Easily usable in SwiftUI projects with `InteractiveLabelView`.
- **Clean Architecture**: Responsibilities are clearly separated by roles (`TextManager`, `TouchManager`), making it easy to maintain and extend.

## 📋 Requirements

- **iOS**: 13.0+
- **Xcode**: 14.0+
- **Swift**: 5.0+

## 📦 Installation

### Swift Package Manager (SPM)

In Xcode, select `File > Add Packages...` and add the repository URL below.

```
https://github.com/silexKhan/InteractiveLabel.git
```

## 🚀 Usage

```swift
import UIKit
import Combine
import InteractiveLabel

class ViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = InteractiveLabel()
        label.numberOfLines = 0
        label.text = "Tap on a #hashtag, @mention, or URL like https://github.com."
        label.enabledTypes = [.hashtag, .mention, .url]
        
        view.addSubview(label)
        // ... set up auto layout ...
        
        // Handle tap events
        label.didTap
            .sink { element in
                self.handleTap(on: element)
            }
            .store(in: &cancellables)
    }
    
    func handleTap(on element: InteractiveElement) {
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
}
```

## ⚙️ Configuration

All visual elements and regex patterns of `InteractiveLabel` can be changed via the `config` property.

```swift
// After creating an InteractiveLabel instance

// Change colors
label.config.hashtagColor = .systemPurple
label.config.hashtagSelectedColor = .systemIndigo
label.config.mentionColor = .systemOrange

// Change font on highlight
label.config.highlightFontName = "Helvetica-Bold"
label.config.highlightFontSize = label.font.pointSize

// Set max URL length
label.config.urlMaximumLength = 30

// Add a custom pattern
let customType = InteractiveType.custom(pattern: "silex")
label.enabledTypes.append(customType)
label.config.customColor[customType] = .systemGreen

label.handleCustom(for: customType) { customString in
    print("Custom type tapped: \(customString)")
}
```

## 🤝 Contributing

All kinds of contributions are welcome, including issue reports, feature suggestions, and Pull Requests.

## 🔗 Alternatives

- [ActiveLabel.swift](https://github.com/optonaut/ActiveLabel.swift) (The motive for this project)
- [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel)
- [KILabel](https://github.com/Krelborn/KILabel)

## 👨‍💻 Author

- **silex**
- **Email**: realsilex@gmail.com

## 📄 License

`InteractiveLabel` is distributed under the MIT license. See `LICENSE` for more information.