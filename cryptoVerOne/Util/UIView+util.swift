//
//  UIView+util.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation
import UIKit

extension UIView {
    func screenShot() -> UIImage? {
        let scale = UIScreen.main.scale
        let bounds = self.bounds
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        
        if let _ = UIGraphicsGetCurrentContext()
        {
            self.drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    func changeBorderWith( isChoose:Bool)
    {
        layer.borderColor = (isChoose ? Themes.grayA3AED0.cgColor : Themes.grayE0E5F2.cgColor)
        layer.borderWidth = (isChoose ? 2 : 1)
    }
    //将当前视图转为UIImage
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    func addShadowBgView(radius:CGFloat) -> UIView {
        let shadow = UIView()
        let frame = self.frame
        shadow.layer.shadowOpacity = 0.3
        shadow.layer.cornerRadius = 10
        shadow.addSubview(self)
        shadow.frame = frame
        self.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        return shadow
    }
    
    func addGradientBlueLayer(size:CGSize = .zero) {
        let layerSize = size == .zero ? frame.size :size
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x:0,
                                     y:0,
                                     width:layerSize.width,
                                     height:layerSize.height)
        gradientLayer.colors = [Themes.gradientStartBlue.cgColor,Themes.gradientEndBlue.cgColor]
        gradientLayer.startPoint = CGPoint(x:0.5, y:0.0)
        gradientLayer.endPoint = CGPoint(x:0.5, y:1.0)
        layer.insertSublayer(gradientLayer, at:0)
    }
    func addGradientLayer(size:CGSize = .zero, startColor:UIColor, endColor:UIColor,axis: NSLayoutConstraint.Axis = .horizontal) {
        let layerSize = size == .zero ? frame.size :size
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x:0,
                                     y:0,
                                     width:layerSize.width,
                                     height:layerSize.height)
        gradientLayer.colors = [startColor.cgColor,endColor.cgColor]
        if axis == .horizontal{
            gradientLayer.startPoint = CGPoint(x:0.0, y:0.5)
            gradientLayer.endPoint = CGPoint(x:1.0, y:0.5)
        } else {
            gradientLayer.startPoint = CGPoint(x:0.5, y:0.0)
            gradientLayer.endPoint = CGPoint(x:0.5, y:1.0)
        }
        layer.insertSublayer(gradientLayer, at:0)
    }
    
    func applyCornerRadius(radius:CGFloat = 5) {
        layer.masksToBounds = true
        layer.cornerRadius = radius
    }
    
    func applyShadow(size:CGSize = CGSize(width: 0, height: 5), radius:CGFloat = 5) {
        layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = size
        layer.shadowRadius = radius
        layer.shadowOpacity = 1
    }
    
    func applyShadow(color:UIColor = .black ,radius:CGFloat = 5, alpha: Float = 0.8) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOffset = .zero
        layer.shadowOpacity = alpha
        
    }
    
    func applyBorder(color: UIColor, borderWidth: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = borderWidth
    }
    
    func applyCornerAndShadow(radius:CGFloat = 5){
        layer.addShadow()
        layer.roundCorners(radius: radius)
    }
    
    func addBottomSeparator(color:UIColor, edgeSpacing:CGFloat = 0) {
        let separator = UIView(color:color)
        self.addSubview(separator)
        separator.snp.makeConstraints { maker in
            maker.bottom.equalToSuperview()
            maker.leading.equalToSuperview().offset(edgeSpacing)
            maker.trailing.equalToSuperview().offset(-edgeSpacing)
            maker.height.equalTo(1)
        }
    }
    convenience init(color:UIColor) {
        self.init(frame:.zero)
        self.backgroundColor = color
    }
    
    func applyDefaultLayer() {
        layer.masksToBounds = false
        layer.cornerRadius = 0
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 0
    }
    
    func roundCorner(corners:UIRectCorner, radius:CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.frame = bounds
        self.layer.mask = mask
    }
    
    func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale);
        
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: self.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() };
        UIGraphicsEndImageContext();
        return image;
    }
    
    func setAnchorPoint(_ point:CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);
        
        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)
        
        var position = layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        layer.position = position
        layer.anchorPoint = point
    }
    
    
    func addGradientLayer(colors: [CGColor], direction: GradientDirection = .toBottom) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = direction.points.0
        gradientLayer.endPoint = direction.points.1
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    enum GradientDirection {
        case toBottom
        case toLeft
        case toRight
        
        var points: (CGPoint, CGPoint) {
            switch self {
            case .toBottom:
                return (CGPoint(x: 0.5, y: 0.0), CGPoint(x: 0.5, y: 1.0))
            case .toLeft:
                return (CGPoint(x: 1, y: 0.5), CGPoint(x: 0, y: 0.5))
            case .toRight:
                return (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
            }
        }
        
    }
//    func drawDottedLine(_ rect: CGRect, _ radius: CGFloat, _ color: UIColor) {
//        let layer = CAShapeLayer()
//        layer.bounds = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
//        layer.position = CGPoint(x: rect.midX, y: rect.midY)
//        layer.path = UIBezierPath(rect: layer.bounds).cgPath
//        layer.path = UIBezierPath(roundedRect: layer.bounds, cornerRadius: radius).cgPath
//        layer.lineWidth = 1/UIScreen.main.scale
//        //虚线边框
//        layer.lineDashPattern = [NSNumber(value: 5), NSNumber(value: 5)]
//        layer.fillColor = UIColor.clear.cgColor
//        layer.strokeColor = color.cgColor
//
//        self.layer.addSublayer(layer)
//    }
  
    
    func createDashedLine(from point1: CGPoint, to point2: CGPoint, color: UIColor, strokeLength: NSNumber, gapLength: NSNumber, width: CGFloat) {
           let shapeLayer = CAShapeLayer()

           shapeLayer.strokeColor = color.cgColor
           shapeLayer.lineWidth = width
           shapeLayer.lineDashPattern = [strokeLength, gapLength]

           let path = CGMutablePath()
           path.addLines(between: [point1, point2])
           shapeLayer.path = path
           layer.addSublayer(shapeLayer)
       }
    
    var allSubViews : [UIView] {
        var array = [self.subviews].flatMap {$0}
        array.forEach { array.append(contentsOf: $0.allSubViews) }
        return array
    }
}
