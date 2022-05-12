//
//  ConfirmPopup.swift
//  betlead
//
//  Created by Victor on 2019/6/14.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
enum ConfirmIconMode {
    case important
    case info
    
    var imageName: String {
        switch self {
        case .important:
            return "launch-logo"
        case .info:
            return "arrow-circle-right"
        }
    }
}
class ConfirmPopupView: PopupBottomSheet {
    var iconMode : ConfirmIconMode = .important
    private lazy var titleIcon: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage()
        return imgView
    }()
    private lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.textAlignment = .center
        lb.font = Fonts.pingFangTCRegular(18)
        return lb
    }()
    
    private lazy var messageLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.textColor = .black
        lb.numberOfLines = 0
        lb.font = Fonts.pingFangTCRegular(14)
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
    
    init(title: String, message: String , iconMode:ConfirmIconMode = .important, _ done: DoneHandler?) {
        super.init()
        self.iconMode = iconMode
        titleLabel.text = title
        messageLabel.text = message
        doneHandler = done
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
        defaultContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
            make.height.equalToSuperview().multipliedBy(0.32)
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
            make.height.equalTo(height(120.0/812.0))
        }
        titleView.addSubview(titleIcon)
        let image = UIImage(named:iconMode.imageName)?.reSizeImage(reSize: CGSize(width: 30, height: 30))
        titleIcon.image = image
        titleIcon.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(height(40.0/812.0))
            make.centerX.equalToSuperview()
            make.width.height.equalTo(30)
        }
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(height(-20.0/812.0))
        }
        
        let msgContentView = UIView()
        defaultContainer.addSubview(msgContentView)
        msgContentView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        defaultContainer.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        let stackView = UIStackView(arrangedSubviews: [cancelButton,confirmButton])
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        defaultContainer.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
//            make.top.equalTo(msgContentView.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
    }
    
    override func dismissVC(nextSheet: BottomSheet? = nil) {
        super.dismissVC()
        print("vc dismiss")
        usedBioVerify(false)
    }
    
    override func dismissToTopVC() {
        super.dismissToTopVC()
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
