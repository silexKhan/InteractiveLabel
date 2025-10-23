
import UIKit

class InteractiveTouchManager {
    
    private weak var label: InteractiveLabel?
    private weak var textManager: InteractiveTextManager?
    
    private var selectedElement: (element: InteractiveElement, range: NSRange)?
    var customSelectedHandler: [InteractiveType: (String) -> Void] = [:]

    init(label: InteractiveLabel, textManager: InteractiveTextManager) {
        self.label = label
        self.textManager = textManager
    }
    
    func onTouch(_ touch: UITouch, _ phase: UITouch.Phase) {
        guard let label = label else { return }
        let location = touch.location(in: label)
        let tapped = tappedInteractiveElement(at: location)

        switch phase {
        case .began:
            selectedElement = tapped
            highlight(selectedElement, highlight: true)
        case .moved:
            if let selected = selectedElement, let tapped = tapped, tapped.element == selected.element {
                highlight(tapped, highlight: true)
            } else {
                highlight(selectedElement, highlight: false)
            }
        case .ended:
            if let selected = selectedElement, let tapped = tapped, tapped.element == selected.element {
                handleTap(for: tapped.element)
            }
            highlight(selectedElement, highlight: false)
            selectedElement = nil
        case .cancelled, .regionExited, .regionEntered, .stationary, .regionMoved:
            highlight(selectedElement, highlight: false)
            selectedElement = nil
        @unknown default: break
        }
    }

    private func handleTap(for element: InteractiveElement) {
        guard let label = label else { return }
        
        if case .custom(let value) = element, let handler = customSelectedHandler.first(where: { $0.key == .custom(pattern: value) })?.value {
            handler(value)
        } else {
            label.didTap.send(element)
        }
    }

    private func highlight(_ elementTuple: (element: InteractiveElement, range: NSRange)?, highlight: Bool) {
        guard let label = label, let textManager = textManager, let (_, range) = elementTuple else { return }
        
        var attributes = textManager.textStorage.attributes(at: range.location, effectiveRange: nil)
        let type = attributes[.interactiveType] as! InteractiveType
        
        if highlight {
            attributes[.foregroundColor] = textManager.selectedColor(for: type)
            let highlightFont: UIFont
            if let fontName = label.config.highlightFontName, let fontSize = label.config.highlightFontSize {
                highlightFont = UIFont(name: fontName, size: fontSize) ?? label.font
            } else if let fontName = label.config.highlightFontName {
                highlightFont = UIFont(name: fontName, size: label.font.pointSize) ?? label.font
            } else if let fontSize = label.config.highlightFontSize {
                highlightFont = UIFont(name: label.font.fontName, size: fontSize) ?? label.font
            } else {
                highlightFont = label.font
            }
            attributes[.font] = highlightFont
        } else {
            attributes[.foregroundColor] = textManager.color(for: type)
            attributes[.font] = label.font
        }
        
        if let configureAttribute = label.configureInteractiveAttribute {
            attributes = configureAttribute(type, attributes, highlight)
        }
        
        textManager.textStorage.setAttributes(attributes, range: range)
        label.setNeedsDisplay()
    }
    
    private func tappedInteractiveElement(at location: CGPoint) -> (element: InteractiveElement, range: NSRange)? {
        guard let label = label, let textManager = textManager, textManager.textStorage.length > 0 else { return nil }

        let textBoundingBox = textManager.layoutManager.usedRect(for: textManager.textContainer)
        let textContainerOffset = CGPoint(x: (label.bounds.width - textBoundingBox.width) * 0.5 - textBoundingBox.minX,
                                          y: (label.bounds.height - textBoundingBox.height) * 0.5 - textBoundingBox.minY)
        let locationInTextContainer = CGPoint(x: location.x - textContainerOffset.x, y: location.y - textContainerOffset.y)
        let characterIndex = textManager.layoutManager.characterIndex(for: locationInTextContainer, in: textManager.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        guard characterIndex < textManager.textStorage.length else { return nil }

        var range = NSRange()
        if let element = textManager.textStorage.attribute(.interactiveElement, at: characterIndex, effectiveRange: &range) as? InteractiveElement {
            return (element, range)
        }
        return nil
    }
}
