import XCTest
@testable import InteractiveLabel

final class InteractiveLabelTests: XCTestCase {

    var label: InteractiveLabel!
    var textManager: InteractiveTextManager! 
    var touchManager: InteractiveTouchManager!

    override func setUp() {
        super.setUp()
        label = InteractiveLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        // KVC를 사용하여 private lazy var에 접근하고 테스트용으로 재설정합니다.
        textManager = InteractiveTextManager(label: label)
        touchManager = InteractiveTouchManager(label: label, textManager: textManager)
        label.setValue(textManager, forKey: "textManager")
        label.setValue(touchManager, forKey: "touchManager")
    }

    override func tearDown() {
        label = nil
        textManager = nil
        touchManager = nil
        super.tearDown()
    }

    func testMinimumLineHeight() {
        let text = "This is a test text."
        let expectedLineHeight: CGFloat = 20.0
        
        label.text = text
        label.config.minimumLineHeight = expectedLineHeight
        
        let paragraphStyle = label.attributedText?.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
        XCTAssertEqual(paragraphStyle?.minimumLineHeight, expectedLineHeight)
    }

    func testConfigureInteractiveAttribute() {
        let text = "This is a #hashtag."
        label.enabledTypes = [.hashtag]
        let customAttributeKey = NSAttributedString.Key("customKey")
        let customAttributeValue = "customValue"

        label.configureInteractiveAttribute = { type, attributes, isSelected in
            var newAttributes = attributes
            newAttributes[customAttributeKey] = customAttributeValue
            return newAttributes
        }
        label.text = text

        let hashtagRange = (text as NSString).range(of: "#hashtag")
        let attributes = textManager.textStorage.attributes(at: hashtagRange.location, effectiveRange: nil)
        XCTAssertEqual(attributes[customAttributeKey] as? String, customAttributeValue)
    }

    func testHighlightFont() {
        let text = "Hello @user"
        label.enabledTypes = [.mention]
        label.text = text
        label.sizeToFit()
        let highlightFontName = "Helvetica-Bold"
        let highlightFontSize: CGFloat = 18.0
        label.config.highlightFontName = highlightFontName
        label.config.highlightFontSize = highlightFontSize
        
        let mentionRange = (text as NSString).range(of: "@user")
        let mentionRect = textManager.layoutManager.boundingRect(forGlyphRange: mentionRange, in: textManager.textContainer)
        let tapLocation = CGPoint(x: mentionRect.midX, y: mentionRect.midY)

        // When: Touch began
        let touch = TestTouch(location: tapLocation)
        label.touchesBegan(Set([touch]), with: nil)

        // Then: Font should be highlighted
        let highlightedAttributes = textManager.textStorage.attributes(at: mentionRange.location, effectiveRange: nil)
        let highlightedFont = highlightedAttributes[.font] as? UIFont
        XCTAssertEqual(highlightedFont?.fontName, highlightFontName)
        XCTAssertEqual(highlightedFont?.pointSize, highlightFontSize)

        // When: Touch ended
        label.touchesEnded(Set([touch]), with: nil)

        // Then: Font should be restored
        let normalAttributes = textManager.textStorage.attributes(at: mentionRange.location, effectiveRange: nil)
        let normalFont = normalAttributes[.font] as? UIFont
        XCTAssertEqual(normalFont?.fontName, label.font.fontName)
        XCTAssertEqual(normalFont?.pointSize, label.font.pointSize)
    }

    func testSuccessfulTap() {
        let text = "Tap this #hashtag"
        label.enabledTypes = [.hashtag]
        label.text = text
        label.sizeToFit()

        let hashtagRange = (text as NSString).range(of: "#hashtag")
        let hashtagRect = textManager.layoutManager.boundingRect(forGlyphRange: hashtagRange, in: textManager.textContainer)
        let tapLocation = CGPoint(x: hashtagRect.midX, y: hashtagRect.midY)

        let expectation = XCTestExpectation(description: "didTap publisher should fire on a valid tap")
        var receivedElement: InteractiveElement? = nil
        let cancellable = label.didTap.sink { element in
            receivedElement = element
            expectation.fulfill()
        }

        let touch = TestTouch(location: tapLocation)
        label.touchesBegan(Set([touch]), with: nil)
        label.touchesEnded(Set([touch]), with: nil)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedElement)
        if case .hashtag(let hashtag) = receivedElement {
            XCTAssertEqual(hashtag, "hashtag")
        } else {
            XCTFail("Incorrect element type received.")
        }
        cancellable.cancel()
    }

    func testFailedTap() {
        let text = "Tap this #hashtag"
        label.enabledTypes = [.hashtag]
        label.text = text
        label.sizeToFit()

        let hashtagRange = (text as NSString).range(of: "#hashtag")
        let hashtagRect = textManager.layoutManager.boundingRect(forGlyphRange: hashtagRange, in: textManager.textContainer)
        let startLocation = CGPoint(x: hashtagRect.midX, y: hashtagRect.midY)
        let endLocation = CGPoint.zero

        let expectation = XCTestExpectation(description: "didTap publisher should not fire on a failed tap")
        expectation.isInverted = true
        let cancellable = label.didTap.sink { _ in expectation.fulfill() }

        let startTouch = TestTouch(location: startLocation)
        let endTouch = TestTouch(location: endLocation)
        label.touchesBegan(Set([startTouch]), with: nil)
        label.touchesEnded(Set([endTouch]), with: nil)

        wait(for: [expectation], timeout: 0.5)
        cancellable.cancel()
    }
}

class TestTouch: UITouch {
    private let touchLocation: CGPoint

    init(location: CGPoint) {
        self.touchLocation = location
        super.init()
    }

    override func location(in view: UIView?) -> CGPoint {
        return touchLocation
    }
}
