//
//  CheckBox.swift
//  betlead
//
//  Created by Victor on 2019/5/28.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit

class CheckBox: UIView {
    // 圈圈, 勾勾
    public enum Style {
        case circle
        case tick
    }
    
    
    public enum BorderStyle {
        case round
    }
    
    var style: Style = .tick
    var borderStyle: BorderStyle = .round
    
    var borderWidth: CGFloat = 2.0
    
    var checkmarkSize: CGFloat = 0.7
    
    var checkmarkColor: UIColor = .black
    
    var increasedTouchRadius: CGFloat = 5
    
    var useHapticFeedback = true
    
    var checkBorderColor: UIColor = .blue
    var checkBackgroundColor: UIColor = .white
    
    var uncheckBorderColor: UIColor = .blue
    var uncheckBackgroundColor: UIColor = UIColor(rgb: 0xEDEDED)
    
    var alwaysShowTick: Bool = false
    var isCheck: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    init(boxColor: UIColor = .white, borderColor: UIColor, alwaysShowTick: Bool = false , style:Style = .tick) {
        super.init(frame: .zero)
        self.checkBackgroundColor = UIColor(rgb: 0xEDEDED)
        self.uncheckBackgroundColor = UIColor(rgb: 0xEDEDED)
        self.checkBorderColor = UIColor(rgb: 0xEDEDED)
        self.uncheckBorderColor = UIColor(rgb: 0xEDEDED)
        self.alwaysShowTick = alwaysShowTick
        self.style = style
        setupViews()
    }
    
    init(boxColor: UIColor = .white) {
        super.init(frame: .zero)
        self.checkBackgroundColor = UIColor(rgb: 0xEDEDED)
        self.checkBorderColor = UIColor(rgb: 0xEDEDED)
        self.uncheckBorderColor = UIColor(rgb: 0xEDEDED)
        setupViews()
    }
    
    private func setupViews() {
        self.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        let newRect = rect.insetBy(dx: borderWidth / 2, dy: borderWidth / 2)
//
//        let context = UIGraphicsGetCurrentContext()
//        context?.setStrokeColor(self.isCheck ? checkBorderColor.cgColor : uncheckBorderColor.cgColor)
//        context?.setFillColor(self.isCheck ? checkBorderColor.cgColor: uncheckBorderColor.cgColor)
//        context?.setLineWidth(borderWidth)
//
//        var shapePath: UIBezierPath!
//
//        switch self.borderStyle {
//        case .round:
//            shapePath = UIBezierPath(ovalIn: newRect)
//        }
//
//        context?.addPath(shapePath.cgPath)
//        context?.strokePath()
//        context?.fillPath()
        
        if isCheck {
            fillBackground(frame: newRect)
            switch self.style {
            case .circle:
                self.drawCircle(frame: newRect)
            case .tick:
                self.drawCheckMark(frame: newRect)
            }
        } else {
            if !alwaysShowTick {
                fillBackground(frame: newRect)
            }else
            {
                fillBackground(frame: newRect)
                switch self.style {
                case .circle:
                    self.drawCircle(frame: newRect)
                case .tick:
                    self.drawCheckMark(frame: newRect)
                }
            }
        }
        
    }
    
    func fillBackground(frame: CGRect) {
        // 背景色
        let backgroundBezierPath = UIBezierPath(rect: frame)
        if isCheck {
            checkBackgroundColor.setFill()
        } else {
//            checkBackgroundColor.setFill()
            uncheckBackgroundColor.setFill()
        }
        backgroundBezierPath.fill()
    }
    
    // 勾勾
    func drawCheckMark(frame: CGRect) {
       
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: frame.minX + 0.26000 * frame.width, y: frame.minY + 0.50000 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.42000 * frame.width, y: frame.minY + 0.62000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.38000 * frame.width, y: frame.minY + 0.60000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.42000 * frame.width, y: frame.minY + 0.62000 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.70000 * frame.width, y: frame.minY + 0.24000 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.78000 * frame.width, y: frame.minY + 0.30000 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.44000 * frame.width, y: frame.minY + 0.76000 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.20000 * frame.width, y: frame.minY + 0.58000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.44000 * frame.width, y: frame.minY + 0.76000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.26000 * frame.width, y: frame.minY + 0.62000 * frame.height))
        checkmarkColor.setFill()
        bezierPath.fill()
    }
    
    // 圈圈
    func drawCircle(frame: CGRect) {
        func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: frame.minX + fastFloor(frame.width * 0.22000 + 0.5), y: frame.minY + fastFloor(frame.height * 0.22000 + 0.5), width: fastFloor(frame.width * 0.76000 + 0.5) - fastFloor(frame.width * 0.22000 + 0.5), height: fastFloor(frame.height * 0.78000 + 0.5) - fastFloor(frame.height * 0.22000 + 0.5)))
        checkmarkColor.setFill()
        ovalPath.fill()
    }
    
}
