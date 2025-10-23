import UIKit

/// `InteractiveLabel`의 TextKit 스택과 텍스트 속성 처리를 전문적으로 관리하는 클래스입니다.
class InteractiveTextManager {
    
    private weak var label: InteractiveLabel?
    
    lazy var textStorage = NSTextStorage()
    lazy var layoutManager = NSLayoutManager()
    lazy var textContainer = NSTextContainer()

    init(label: InteractiveLabel) {
        self.label = label
        configureTextStorage()
    }
    
    
    /// `TextStorage`를 업데이트하여 텍스트 속성과 상호작용 요소를 다시 계산하고 적용합니다.
    func updateTextStorage() {
        guard let label = label, let attributedText = label.attributedText, attributedText.length > 0 else {
            textStorage.setAttributedString(NSAttributedString())
            label?.setNeedsDisplay()
            return
        }

        var mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        applyBaseAttributes(to: mutableAttributedString)
        
        let wholeRange = NSRange(location: 0, length: mutableAttributedString.length)
        for attribute in InteractiveLabel.interactiveAttributes {
            mutableAttributedString.removeAttribute(attribute, range: wholeRange)
        }

        var interactiveElements = createInteractiveElements(for: mutableAttributedString)
        handleURLTrimming(for: &interactiveElements, in: &mutableAttributedString)
        applyInteractiveAttributes(interactiveElements, to: mutableAttributedString)

        textStorage.setAttributedString(mutableAttributedString)
        label.setNeedsDisplay()
    }

    /// 주어진 `NSMutableAttributedString`에 기본 텍스트 속성을 적용합니다.
    private func applyBaseAttributes(to attributedString: NSMutableAttributedString) {
        guard let label = label else { return }
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.font, value: label.font!, range: range)
        attributedString.addAttribute(.foregroundColor, value: label.textColor ?? .black, range: range)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = label.config.lineSpacing
        paragraphStyle.minimumLineHeight = label.config.minimumLineHeight
        paragraphStyle.alignment = label.textAlignment
        paragraphStyle.lineBreakMode = label.lineBreakMode
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
    }

    /// 상호작용 요소를 찾아 배열로 반환합니다.
    private func createInteractiveElements(for attributedString: NSAttributedString) -> [ElementTuple] {
        guard let label = label else { return [] }
        let range = NSRange(location: 0, length: attributedString.length)
        return label.enabledTypes.flatMap { type in
            InteractiveElementParser.createElements(type: type, from: attributedString.string, range: range, config: label.config, filterPredicate: label.customFilters[type] ?? nil)
        }
    }

    /// URL 길이를 조절하고, 필요한 경우 문자열과 요소를 업데이트합니다.
    private func handleURLTrimming(for elements: inout [ElementTuple], in attributedString: inout NSMutableAttributedString) {
        guard let label = label, label.enabledTypes.contains(.url) else { return }

        let range = NSRange(location: 0, length: attributedString.length)
        let (urlElements, newText) = InteractiveElementParser.createURLElements(from: attributedString.string, range: range, config: label.config)

        guard newText != attributedString.string else { return }

        let newAttributedString = NSMutableAttributedString(string: newText)
        applyBaseAttributes(to: newAttributedString)
        attributedString = newAttributedString
        
        elements = elements.filter { $0.type != .url } + urlElements
    }

    /// 상호작용 요소에 속성을 적용합니다.
    private func applyInteractiveAttributes(_ elements: [ElementTuple], to attributedString: NSMutableAttributedString) {
        guard let label = label else { return }
        for (range, element, type) in elements {
            var attributes: [NSAttributedString.Key: Any] = [:]
            attributes[.font] = label.font
            attributes[.foregroundColor] = color(for: type)
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            attributes[.interactiveElement] = element
            attributes[.interactiveType] = type
            attributes[.interactiveColor] = color(for: type)
            attributes[.interactiveSelectedColor] = selectedColor(for: type)
            
            if let configureAttribute = label.configureInteractiveAttribute {
                attributes = configureAttribute(type, attributes, false)
            }
            attributedString.addAttributes(attributes, range: range)
        }
    }
    

    /// 텍스트를 그립니다.
    func drawText(in rect: CGRect) {
        let range = NSRange(location: 0, length: textStorage.length)
        let origin = textOrigin(in: rect)
        layoutManager.drawBackground(forGlyphRange: range, at: origin)
        layoutManager.drawGlyphs(forGlyphRange: range, at: origin)
    }

    /// 텍스트의 고유 콘텐츠 크기를 계산합니다.
    func intrinsicContentSize() -> CGSize {
        guard let label = label else { return .zero }
        // 너비를 먼저 설정해야 정확한 높이를 계산할 수 있습니다.
        textContainer.size = CGSize(width: label.preferredMaxLayoutWidth > 0 ? label.preferredMaxLayoutWidth : label.bounds.width, height: .greatestFiniteMagnitude)
        layoutManager.ensureLayout(for: textContainer)
        let size = layoutManager.usedRect(for: textContainer).size
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }

    /// 주어진 크기에 맞는 텍스트의 크기를 계산합니다.
    func sizeThatFits(_ size: CGSize) -> CGSize {
        textContainer.size = CGSize(width: size.width, height: .greatestFiniteMagnitude)
        layoutManager.ensureLayout(for: textContainer)
        let fitSize = layoutManager.usedRect(for: textContainer).size
        return CGSize(width: ceil(fitSize.width), height: ceil(fitSize.height))
    }
    
    /// 텍스트를 수직 중앙에 그리기 위한 시작점을 계산합니다.
    private func textOrigin(in rect: CGRect) -> CGPoint {
        guard let label = label else { return .zero }
        layoutManager.ensureLayout(for: textContainer)
        let usedRect = layoutManager.usedRect(for: textContainer)
        let yOffset = (label.bounds.height - usedRect.height) / 2
        return CGPoint(x: 0, y: yOffset)
    }

    
    /// TextKit 스택의 기본 설정을 구성합니다.
    private func configureTextStorage() {
        guard let label = self.label else { return }
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
    }
    
    /// 주어진 타입에 대한 기본 색상을 반환합니다.
    func color(for type: InteractiveType) -> UIColor {
        guard let label = label else { return .black }
        switch type {
        case .mention: return label.config.mentionColor
        case .hashtag: return label.config.hashtagColor
        case .url: return label.config.urlColor
        case .email: return label.config.emailColor
        case .custom: return label.config.customColor[type] ?? .blue
        }
    }

    /// 주어진 타입에 대한 선택 상태의 색상을 반환합니다.
    func selectedColor(for type: InteractiveType) -> UIColor {
        guard let label = label else { return .black }
        switch type {
        case .mention: return label.config.mentionSelectedColor ?? label.config.mentionColor
        case .hashtag: return label.config.hashtagSelectedColor ?? label.config.hashtagColor
        case .url: return label.config.urlSelectedColor ?? label.config.urlColor
        case .email: return label.config.emailSelectedColor ?? label.config.emailColor
        case .custom: return label.config.customSelectedColor[type] ?? color(for: type)
        }
    }
}