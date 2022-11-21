//
//  ConfirmPopup.swift
//  betlead
//
//  Created by Victor on 2019/6/14.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
enum ConfirmIconMode {
    case showIcon(String = "")
    case nonIcon(Array<String> = [])
    
    var imageName: String {
        switch self {
        case .showIcon(_):
            return "icon-alert-triangle"
        case .nonIcon(_):
            return ""
        }
    }
}
class ConfirmPopupView: PopupBottomSheet {
    var iconMode : ConfirmIconMode!
    var containerHeight: CGFloat = 155.0
    private lazy var titleIcon: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage()
        return imgView
    }()
    private lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.textAlignment = .center
        lb.font = Fonts.PlusJakartaSansRegular(20)
        return lb
    }()
    
    lazy var messageLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.textColor = Themes.gray2B3674
        lb.numberOfLines = 0
        lb.font = Fonts.PlusJakartaSansMedium(16)
        return lb
    }()
    
    private lazy var confirmButton: OKButton = {
        let btn = OKButton()
        btn.setTitle("Continue".localized, for: .normal)
        btn.addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var cancelButton: CancelButton = {
        let btn = CancelButton()
        btn.setTitle("Cancel".localized, for: .normal)
        btn.addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    typealias DoneHandler = (Bool) -> ()
    var doneHandler: DoneHandler?
    
    init(viewHeight:CGFloat = 155.0 ,iconMode:ConfirmIconMode = .nonIcon(["Cancel".localized,"Logout".localized]), title: String = "", message: String ,  _ done: DoneHandler?) {
        super.init()
        containerHeight = viewHeight
        self.iconMode = iconMode
        titleLabel.text = title
        messageLabel.text = message
        doneHandler = done
    }
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    required init(_ parameters: Any? = nil) {
         super.init()
    }
    
    override func setupViews() {
        super.setupViews()
        dismissButton.isHidden = true
        setupUI()
    }
    
    private func setupUI() {
        
        var iconHeight = 40.0
        var titleViewHeight = 96.0
        var stackView :UIStackView!
        var buttonViewMultiplied = 0.45
        switch self.iconMode {
        case .nonIcon(let array):
            if array.count > 1
            {
                cancelButton.setTitle(array.first, for: .normal)
                confirmButton.setTitle(array.last, for: .normal)
                stackView = UIStackView(arrangedSubviews: [cancelButton,confirmButton])
                stackView.distribution = .fillEqually
                stackView.spacing = 10
                buttonViewMultiplied = 0.8
            }else
            {
                confirmButton.setTitle(array.first, for: .normal)
                stackView = UIStackView(arrangedSubviews: [confirmButton])
                buttonViewMultiplied = 0.45
            }
            iconHeight = 0.0
            titleViewHeight = 40.0
        case .showIcon(let string):
            confirmButton.setTitle(string, for: .normal)
            containerHeight = 222.0
            iconHeight = 40.0
            titleViewHeight = 96.0
            stackView = UIStackView(arrangedSubviews: [confirmButton])
            buttonViewMultiplied = 0.45
        case .none: break
            
        }
  
       // title 背景漸層
//        let titleView = GradientView()
//        defaultContainer.addSubview(titleView)
//        titleView.snp.makeConstraints { (make) in
//            make.top.left.right.equalToSuperview()
//            make.height.equalTo(56)
//        }
        let titleView = UIView()
        defaultContainer.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(titleViewHeight)
        }
        // title
        titleView.addSubview(titleIcon)
        let image = UIImage(named:iconMode.imageName)
        titleIcon.image = image
        titleIcon.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16.0)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(iconHeight)
        }
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleIcon.snp.bottom).offset(6)
        }
        // message
        
        defaultContainer.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(26)
            make.right.equalToSuperview().offset(-26)
        }
        
        defaultContainer.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(buttonViewMultiplied)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
        let messageString = messageLabel.text ?? ""
        let height = messageString.height(withConstrainedWidth: (Views.screenWidth - 80), font: messageLabel.font)
//        let height = heightForView(text: messageLabel.text ?? "", font: messageLabel.font, width: defaultContainer.frame.width)
        if (height + 120) > containerHeight
        {
            containerHeight = (height + 150)
        }else
        {
//            containerHeight = viewHeight
        }
        defaultContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
//            make.width.equalToSuperview().multipliedBy(0.75)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(containerHeight)
        }
    }
    
    override func dismissVC(nextSheet: BottomSheet? = nil) {
        super.dismissVC()
        print("vc dismiss")
        usedBioVerify(false)
    }
    
    override func dismissToTopVC(animation:Bool = true) {
        super.dismissToTopVC(animation: animation)
        print("top vc dismiss")
        usedBioVerify(false)
    }

    @objc private func confirmButtonPressed(_ sender: UIButton) {
        
        if sender == confirmButton {
            usedBioVerify(true)
        } else {
            usedBioVerify(false)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func usedBioVerify(_ isCheck: Bool) {
        doneHandler?(isCheck)
    }
}
