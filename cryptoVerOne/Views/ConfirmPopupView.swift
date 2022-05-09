//
//  ConfirmPopup.swift
//  betlead
//
//  Created by Victor on 2019/6/14.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation

class ConfirmPopupView: PopupBottomSheet {
    
    private lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()
    
    
    private lazy var messageLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.textColor = .black
        lb.numberOfLines = 0
        return lb
    }()
    
    private lazy var confirmButton: OKButton = {
        let btn = OKButton()
        btn.setTitle("是", for: .normal)
        btn.addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var cancelButton: CancelButton = {
        let btn = CancelButton()
        btn.setTitle("否", for: .normal)
        btn.addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    typealias DoneHandler = (Bool) -> ()
    var doneHandler: DoneHandler?
    
    init(title: String, message: String, _ done: DoneHandler?) {
        super.init()
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
        setupUI()
    }
    
    
    private func setupUI() {
        defaultContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        let titleView = GradientView()
        defaultContainer.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
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
        
        let stackView = UIStackView(arrangedSubviews: [confirmButton, cancelButton])
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        defaultContainer.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(msgContentView.snp.bottom).offset(20)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-30)
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
