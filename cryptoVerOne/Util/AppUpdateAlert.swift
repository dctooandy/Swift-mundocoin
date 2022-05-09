//
//  AppUpdateAlert.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation
import UIKit

class AppUpdateAlert: PopupBottomSheet {
    
    typealias DoneHandler = (Bool) -> ()
    var doneHandler: DoneHandler?
    
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
        btn.setTitle("立即升级", for: .normal)
        btn.addTarget(self, action: #selector(okButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var cancelButton: CancelButton = {
        let btn = CancelButton()
        btn.setTitle("再等等", for: .normal)
        btn.addTarget(self, action: #selector(cancelButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    var downloadUrl: String = ""
    
    init(_ parameters: Any? = nil, _ done: DoneHandler?) {
        super.init()
        isAddDismissGesture(false)
        disablePanGesture()
        guard let appVersionDto = parameters as? AppVersionDto else { return }
        doneHandler = done
        setup(data: appVersionDto)
    }
    
    private func setup(data: AppVersionDto) {
        downloadUrl = data.appVersionFileLocation
        titleLabel.text = data.appVersionTitle
        messageLabel.text = data.appVersionContent.replacingOccurrences(of: "\\n", with: "\n")
        if data.appVersionForceUpdate!.value! {
            cancelButton.isHidden = true
        }
    }
    
    override func setupViews() {
        super.setupViews()
        dismissButton.isHidden = true
        setupUI()
    }
    
    func setupUI() {
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
    
    @objc private func okButtonPressed(_ sender: UIButton) {
        // go app down load web
        doneHandler?(true)
        guard let url = URL(string: downloadUrl) else { return }
        UIApplication.shared.canOpenURL(url)
        UIApplication.shared.open(url)
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func cancelButtonPressed(_ sender: UIButton) {
        doneHandler?(false)
        self.dismiss(animated: true, completion: nil)
    }
    
    required init(_ parameters: Any? = nil) {
        super.init()
        guard let appVersionDto = parameters as? AppVersionDto else { return }
        setup(data: appVersionDto)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    
}
