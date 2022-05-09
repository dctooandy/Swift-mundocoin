//
//  ImagetTextButton.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import UIKit
import RxSwift
import RxCocoa

// let NextButton be an observable sequence
extension Reactive where Base: UIControl {
    internal var tap: ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
    
    
}

class ImagetTextButton: UIControl {

    var image: UIImage? = nil
    private let titleLabel = UILabel()
    private var imageView: UIImageView?
    private var imvTintColor = UIColor.white
    private var titleColor = UIColor.white
    private var imvAndTitleSpace: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setTitleColor(_ c: UIColor) {
        titleLabel.textColor = c
    }
    func setImageColor(_ c: UIColor) {
        imageView?.tintColor = c
    }
    init(title: String, titleColor: UIColor, image: UIImage?, imageColor: UIColor?, space: CGFloat, borderColor: UIColor = .white) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.image = image?.withRenderingMode(.alwaysTemplate)
        self.imvTintColor = imageColor ?? .white
        self.titleColor = titleColor
        self.imvAndTitleSpace = space
        self.layer.borderColor = borderColor.cgColor
        self.setup()
    }
    
    init(title: String, image: UIImage?) {
        super.init(frame: .zero)
        layer.borderColor = UIColor.white.cgColor
        self.titleLabel.text = title
        self.image = image?.withRenderingMode(.alwaysTemplate)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.layer.cornerRadius = rect.height / 2
        self.layer.borderWidth = 1
        self.clipsToBounds = true
    }
    
    func setup() {
        
        let contentView = UIView()
        contentView.isUserInteractionEnabled = false
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        if image != nil {
            self.imageView = UIImageView()
            imageView?.image = self.image!
            imageView?.tintColor = imvTintColor
            contentView.addSubview(imageView!)
        }
        
        
        titleLabel.textColor = titleColor
        contentView.addSubview(titleLabel)
        self.titleLabel.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.centerY.left.equalToSuperview()
            if strongSelf.imageView == nil {
                make.right.equalToSuperview()
            }
        }
        
        
        self.imageView?.snp.makeConstraints({ [weak self] (make) in
            guard let strongSelf = self else { return }
            make.centerY.right.equalToSuperview()
            make.left.equalTo(strongSelf.titleLabel.snp.right).offset(strongSelf.imvAndTitleSpace)
            make.size.equalTo(15)
        })
    }
    
    func setTitle(text: String) {
        self.titleLabel.text = text
    }
    
    private var enableColor: UIColor? = nil {
        didSet {
            if isEnabled {
                backgroundColor = self.enableColor
            }
        }
    }
    
    private var disableColor: UIColor? = nil {
        didSet {
            if !isEnabled {
                backgroundColor = self.disableColor
            }
        }
    }
    override var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                if let enableColor = self.enableColor {
                    backgroundColor = enableColor
                }
            } else {
                if let disableColor = self.disableColor {
                    backgroundColor = disableColor
                }
            }
        }
    }
    
    func setBackgroundColor(_ color: UIColor, isEnable: Bool) {
        if isEnable {
            enableColor = color
        } else {
            disableColor = color
        }
    }
}
