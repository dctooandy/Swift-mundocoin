//
//  AuditTriggerAlertView.swift
//  cryptoVerOne
//
//  Created by BBk on 6/13/22.
//


import Foundation
import UIKit
enum AuditTriggerMode {
    case accept
    case reject
    
    var titleString: String {
        switch self {
        case .accept:
            return "Withdrawals Accept"
        case .reject:
            return "Withdrawals Reject *"
        }
    }
    var rightButtonString: String {
        switch self {
        case .accept:
            return "Confirm"
        case .reject:
            return "Reject"
        }
    }
}
class AuditTriggerAlertView: PopupBottomSheet {
    var alertMode : AuditTriggerMode!
    
    private lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.textAlignment = .left
        lb.font = Fonts.pingFangTCRegular(20)
        return lb
    }()
    
    private lazy var messageTextView: UITextView = {
        let tView = UITextView()
        tView.isEditable = true
        tView.isSelectable = true
        tView.font = Fonts.pingFangTCRegular(14)
        return tView
    }()
    
    private lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(color: UIColor(rgb: 0x898989)), for: .normal)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 3
        btn.layer.borderColor = UIColor(rgb: 0x898989).cgColor
        btn.layer.borderWidth = 1
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("Confirm".localized, for: .normal)
        btn.addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(color: UIColor(rgb: 0xE4E4E4)), for: .normal)
        btn.setTitle("Cancel".localized, for: .normal)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 3
        btn.setTitleColor(UIColor(rgb: 0x434343), for: .normal)
        btn.addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    typealias DoneHandler = (Bool) -> ()
    var doneHandler: DoneHandler?
    
    init(alertMode:AuditTriggerMode = .accept , _ done: DoneHandler?) {
        super.init()
        self.alertMode = alertMode
        titleLabel.text = alertMode.titleString
        confirmButton.setTitle(alertMode.rightButtonString, for: .normal)
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
        var defaultContainerHeight = 290.0
        var stackView :UIStackView!
        stackView = UIStackView(arrangedSubviews: [cancelButton,confirmButton])
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        var buttonViewMultiplied = 0.9
        switch self.alertMode {
        case .accept:
            break
        case .reject:
            let textRange = NSMakeRange(0, "Withdrawals Reject".count)
            let attributedText = NSMutableAttributedString(string: self.alertMode.titleString)
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor , value: UIColor.black, range: textRange)
            let markRange = NSMakeRange("Withdrawals Reject".count + 1, 1)
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: markRange)
            self.titleLabel.attributedText = attributedText
        case .none:
            break
        }
        defaultContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo(defaultContainerHeight)
        }
       // title 背景漸層
        let backView = UIView()

        backView.backgroundColor = UIColor(rgb: 0xC4C4C4)
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 3
        defaultContainer.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }

        // title
        backView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(5)
        }
        // message
        backView.addSubview(messageTextView)
        messageTextView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalTo(titleLabel)

            make.height.equalTo(168.0)
        }
        
        backView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(buttonViewMultiplied)
            make.height.equalTo(44)
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
