//
//  Reactive+util.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//



import Foundation
import UIKit
import Parchment
import RxCocoa
import RxSwift
import SDWebImage
extension Reactive where Base:UIView {
    
    var click:Observable<Void> {
        let tap = UITapGestureRecognizer()
        base.addGestureRecognizer(tap)
        base.isUserInteractionEnabled = true
        return tap.rx.event.map{ _ -> Void  in
            return
        }
    }
    var longPress:Observable<Void> {
         let tap = UILongPressGestureRecognizer()
         base.addGestureRecognizer(tap)
         base.isUserInteractionEnabled = true
         return tap.rx.event.map{ _ -> Void  in
             return
         }
     }
}

extension Reactive where Base: UILabel {
    var textColor: Binder<UIColor> {
        return Binder(self.base, binding: { label, color in
            label.textColor = color
        })
    }
}


extension Reactive where Base: UIView {
    
    var borderColor: Binder<UIColor> {
        return Binder(self.base, binding: { view, color in
            view.layer.borderColor = color.cgColor
        })
    }
}

extension Reactive where Base: UIButton {
    var tintColor: Binder<UIColor> {
        return Binder(self.base, binding: { btn, color in
            btn.setImage(btn.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn.tintColor = color
        })
    }
    
    var textColor: Binder<UIColor> {
        return Binder(self.base, binding: { button, color in
            button.setTitleColor(color, for: .normal)
        })
    }
    var borderColor: Binder<UIColor> {
        return Binder(self.base, binding: { view, color in
            view.layer.borderColor = color.cgColor
        })
    }
    
    var imageUrl: Binder<String?> {
        return Binder(self.base) { (btn, urlStr) in
            SDWebImageManager.shared.loadImage(with: URL(string: urlStr ?? ""), options: [], context: nil, progress: nil) { (image, _, _, _, _, _) in
                
                btn.setImage(image, for: .normal)
            }
        }
    }
}
extension Reactive where Base: CAGradientLayer {
    var fanMenuBaclgroundColor: Binder<UIColor> {
        return Binder(self.base) { (layer, color) in
            layer.colors = [color.withAlphaComponent(0).cgColor,color.withAlphaComponent(0.5).cgColor,color.cgColor]
        }
    }
    var colors: Binder<[Any]> {
        return Binder(self.base) { (layer, colors) in
            layer.colors = colors
        }
    }
}

extension Reactive where Base: CALayer {
    var borderColor: Binder<UIColor> {
        return Binder(self.base, binding: { layer, color in
            layer.borderColor = color.cgColor
        })
    }
    var shadowColor: Binder<UIColor> {
        return Binder(self.base, binding: { layer, color in
            layer.shadowColor = color.cgColor
        })
    }
}

extension Reactive where Base: UINavigationBar {
    
    var backgroundImage: Binder<UIImage?> {
        return Binder(self.base, binding: { bar, image in
            
            bar.setBackgroundImage(image?.resizableImage(withCapInsets: .zero, resizingMode: .stretch), for: .default)
        })
    }
}

extension Reactive where Base: UIControl {
    var backgroundColor: Binder<UIColor?> {
        return Binder(self.base, binding: { control, color in
            control.backgroundColor = color
        })
    }
}

extension Reactive where Base: UITextField {
    var textColor: Binder<UIColor> {
        return Binder(self.base, binding: { tf, color in
            tf.textColor = color
        })
    }
    var fontData: Binder<UIFont> {
        return Binder(self.base, binding: { tf, fontData in
            tf.font = fontData
        })
    }
    var placeholderColor: Binder<UIColor> {
        return Binder(self.base, binding: { tf, color in
            let attributes = [
                NSAttributedString.Key.foregroundColor: color,NSAttributedString.Key.font: Fonts.pingFangSCRegular(10)
            ]
            tf.attributedPlaceholder = NSAttributedString(string: tf.placeholder ?? "",
                                                            attributes: attributes)
        })
    }
    var contentPlaceholderColor: Binder<UIColor> {
        return Binder(self.base, binding: { tf, color in
            
            let attributeDic: [NSAttributedString.Key: Any] =
            [.foregroundColor: color,
             .font: Fonts.pingFangSCRegular(12)]
            tf.attributedPlaceholder = NSAttributedString(string: tf.placeholder ?? "",
                                                            attributes: attributeDic)
        })
    }
}

extension Reactive where Base: UIImageView {
    var tintColor: Binder<UIColor> {
        return Binder(self.base, binding: { imageView, color in
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
        })
    }
}

extension Reactive where Base: PagingViewController<PagingIndexItem> {
    var menuBackgroundColor: Binder<UIColor> {
        return Binder(self.base, binding: { pageViewController, color in
            pageViewController.menuBackgroundColor = color
            pageViewController.reloadMenu()
        })
    }
    
    var backgroundColor: Binder<UIColor> {
        return Binder(self.base, binding: { pageViewController, color in
            pageViewController.backgroundColor = color
            pageViewController.reloadMenu()
        })
    }
    
    var textColor: Binder<UIColor> {
        return Binder(self.base, binding: { pageViewController, color in
            pageViewController.textColor = color
            pageViewController.reloadMenu()
        })
    }
    
    var selectorTextColor: Binder<UIColor> {
        return Binder(self.base, binding: { pageViewController, color in
            pageViewController.selectedTextColor = color
            pageViewController.reloadMenu()
        })
    }
    
    var selectedBackgroundColor: Binder<UIColor> {
        return Binder(self.base, binding: { pageViewController, color in
            pageViewController.selectedBackgroundColor = color
            pageViewController.reloadMenu()
        })
    }
}

