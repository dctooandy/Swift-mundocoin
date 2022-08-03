//
//  Extension.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation
import WebKit
import UIKit
import SDWebImage

extension UIImageView {
    
    func sdLoad(with url:URL? ,completed:((UIImage?) -> Void)? = nil) {
        let image : UIImage = UIImage(color: .clear)!
        sd_setImage(with: url, placeholderImage: image) { (image, _, _, _) in
            completed?(image)
        }
    }
    
    func setImageTintColor(_ color: UIColor) {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}

extension UIResponder {
    
    func next<T: UIResponder>(_ type: T.Type) -> T? {
        return next as? T ?? next?.next(type)
    }
}
extension UITableViewCell {
    
    var tableView: UITableView? {
        return next(UITableView.self)
    }
    
    var indexPath: IndexPath? {
        return tableView?.indexPath(for: self)
    }
}


extension UIView
{
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func loadNibView() -> UIView{
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
}

extension Array {
    func indexOfObject(object : AnyObject) -> NSInteger {
        return (self as NSArray).index(of: object)
    }
}
class UnderlinedLabel: UILabel {
    var isGrayColor : Bool = false
    override var text: String? {
        didSet {
            guard let text = text else { return }
            let textRange = NSMakeRange(0, text.count)
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
#if Approval_PRO || Approval_DEV || Approval_STAGE
            if isGrayColor == true
            {
                attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: Themes.black637684, range: textRange)
            }else
            {
                attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: Themes.blue0587FF, range: textRange)
            }
#else
            if isGrayColor == true
            {
                attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: Themes.gray707EAE, range: textRange)
            }else
            {
                attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: Themes.blue0587FF, range: textRange)
            }
#endif
            // Add other attributes if needed
            self.attributedText = attributedText
        }
    }
}

extension NSMutableAttributedString {
    
    /// 對同一串文字中的特定幾個字設定不同顏色
    ///
    /// - Parameters:
    ///   - textForAttribute: 要更改顏色的文字
    ///   - color: 要更改顏色
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
}
extension URL {
    var queryDictionary: [String: String]? {
        guard let query = self.query else { return nil}
        
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            
            let key = pair.components(separatedBy: "=")[0]
            
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            
            queryStrings[key] = value
        }
        return queryStrings
    }
}


extension UIScrollView {
    // 鍵盤彈出將輸入框向上移動
    func scrollToKeyboardTop(keyboardHeight: CGFloat) {
        var contentInset:UIEdgeInsets = self.contentInset
        contentInset.bottom = keyboardHeight
        self.contentInset = contentInset
    }
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
        print("touchesBegan")
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesMoved(touches, with: event)
        print("touchesMoved")
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesEnded(touches, with: event)
        print("touchesEnded")
    }
}


extension DecodingError: LocalizedError {
    
    public var errorDescription: String? {
        switch  self {
        case .dataCorrupted(let context):
            return NSLocalizedString(context.debugDescription, comment: "")
        case .keyNotFound(_, let context):
            return NSLocalizedString("\(context.debugDescription)", comment: "")
        case .typeMismatch(_, let context):
            return NSLocalizedString("\(context.debugDescription)", comment: "")
        case .valueNotFound(_, let context):
            return NSLocalizedString("\(context.debugDescription)", comment: "")
        }
    }
}

extension CAGradientLayer {
    
    enum Point {
        case topRight, topLeft
        case bottomRight, bottomLeft
        case custion(point: CGPoint)
        
        var point: CGPoint {
            switch self {
            case .topRight: return CGPoint(x: 1, y: 0)
            case .topLeft: return CGPoint(x: 0, y: 0)
            case .bottomRight: return CGPoint(x: 1, y: 1)
            case .bottomLeft: return CGPoint(x: 0, y: 1)
            case .custion(let point): return point
            }
        }
    }
    
    convenience init(frame: CGRect, colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        self.init()
        self.frame = frame
        self.colors = colors.map { $0.cgColor }
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    convenience init(frame: CGRect, colors: [UIColor], startPoint: Point, endPoint: Point) {
        self.init(frame: frame, colors: colors, startPoint: startPoint.point, endPoint: endPoint.point)
    }
    
    func createGradientImage() -> UIImage? {
        defer { UIGraphicsEndImageContext() }
        UIGraphicsBeginImageContext(bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UINavigationBar {
    func setGradientBackground(colors: [UIColor], startPoint: CAGradientLayer.Point = .topLeft, endPoint: CAGradientLayer.Point = .topRight) {
        var updatedFrame = bounds
        updatedFrame.size.height += self.frame.origin.y
        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors, startPoint: startPoint, endPoint: endPoint)
        setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
    }
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 51)
    }
}
extension UINavigationController {
    enum ViewFromType:Int{
        case fromLeft = 1
        case fromRight = 2
    }
    func viewPushAnimation(_ viewController:UIViewController,from orientation:ViewFromType)
    {
        self.view.bringSubviewToFront(viewController.view)
        AnimatorManager.scaleUp(view: viewController.view, frame: self.view.frame,orientation: orientation.rawValue).startAnimation()
    }
    
    func pushViewControllerFromLeft(_ viewController:UIViewController, animated:Bool) {
        let theWindow = self.view
        if (animated)
        {
            let transition = CATransition()
            transition.duration = 0.4
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromLeft
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            theWindow!.layer.add(transition, forKey: "")
        }
        self.pushViewController(viewController, animated: false)
   }
    func popFromLeft(animated:Bool)
    {
        let theWindow = self.view
        if (animated)
        {
            let transition = CATransition()
            transition.duration = 0.4
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            theWindow!.layer.add(transition, forKey: "")
        }
        self.popViewController(animated: false)
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let tab = base as? AuditTabbarViewController {
            if let selected = tab.children.first {
                return topViewController(base: selected)
            }
        }
        if let tab = base as? MDNavigationController {
            if let selected = tab.children.first {
                return topViewController(base: selected)
            }
        }
        if let alert = base as? UIAlertController {
            return alert
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
extension Encodable {
    /// Encode into JSON and return `Data`
    func jsonData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
    
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}


extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
extension TimeInterval{
    
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        
        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
        
    }
    func intervalToString() -> String {
        let time = NSInteger(self)
        return NSString(format: "%0.2d",time) as String
    }
}
// MARK: -
// MARK: UIView 圖形化介面 要指定在XIB裏面
protocol NibOwnerLoadable: AnyObject {
    static var nib: UINib { get }
}

extension NibOwnerLoadable {
    
    static var nib: UINib {
        UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

extension NibOwnerLoadable where Self: UIView {
    
    func loadNibContent() {
        guard let views = Self.nib.instantiate(withOwner: self, options: nil) as? [UIView],
            let contentView = views.first else {
                fatalError("Fail to load \(self) nib content")
        }
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
// MARK: -
// MARK: 使用圖形化介面,但不在XIB裏面
protocol Nibloadable {

}

extension UIView: Nibloadable {
    
}

extension Nibloadable where Self : UIView
{
    /*
     static func loadNib(_ nibNmae :String = "") -> Self{
     let nib = nibNmae == "" ? "\(self)" : nibNmae
     return Bundle.main.loadNibNamed(nib, owner: nil, options: nil)?.first as! Self
     }
     */
    static func loadNib(_ nibNmae :String? = nil) -> Self{
        return Bundle.main.loadNibNamed(nibNmae ?? "\(self)", owner: nil, options: nil)?.first as! Self
    }
    
    func loadNibView(_ nibNmae :String? = nil) -> UIView {
        return Bundle.main.loadNibNamed(nibNmae ?? "\(self)", owner: nil, options: nil)?.first as! UIView
    }
}

extension Nibloadable where Self : UIViewController
{
    /*
     static func loadNib(_ nibNmae :String = "") -> Self{
     let nib = nibNmae == "" ? "\(self)" : nibNmae
     return Bundle.main.loadNibNamed(nib, owner: nil, options: nil)?.first as! Self
     }
     */
    static func loadNib(_ nibNmae :String? = nil) -> Self{
        return UINib(nibName: nibNmae ?? "\(self)", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! Self
    }
}
