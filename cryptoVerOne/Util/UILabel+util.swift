//
// Created by liq on 2018/4/9.
//

import Foundation
import UIKit

extension UILabel {
    convenience init(title: String, textColor: UIColor, font: UIFont = UIFont.systemFont(ofSize: 14)) {
        self.init()
        self.text = title
        self.textColor = textColor
        self.font = font
    }
    
    static func customLabel(font:UIFont = UIFont.systemFont(ofSize: 12),
                            alignment:NSTextAlignment = .left,
                            textColor:UIColor = .white,
                            text:String = "loading...") -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        label.text = text
        return label
    }
    
    
    func boundingRect(forCharacterRange range: NSRange) -> CGRect? {
        
        guard let attributedText = attributedText else { return nil }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        
        layoutManager.addTextContainer(textContainer)
        
        var glyphRange = NSRange()
        
        // Convert the range for glyphs.
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        
        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    }
}
