//
//  AuditTriggerAlertView.swift
//  cryptoVerOne
//
//  Created by BBk on 6/13/22.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

class AuditTriggerAlertView: UIView {
    // MARK:業務設定
    private let onConfirmClick = PublishSubject<(Bool , String)>()
    var alertMode : AuditTriggerMode = .accept{
        didSet
        {
            titleLabel.text = alertMode.titleString
            setTitleString()
            confirmButton.setTitle(alertMode.rightButtonString, for: .normal)
        }
    }
    private let dpg = DisposeBag()
 
    @IBOutlet weak var topIconTopConstant: NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bindTextView()
        bindButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: -
    // MARK:業務方法
    func setTitleString()
    {
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
        }
    }
    private func setupUI() {
        
        messageTextView.isEditable = true
        messageTextView.isSelectable = true
        messageTextView.layer.borderColor = UIColor(rgb: 0xCDD9E4).cgColor
        messageTextView.layer.borderWidth = 1
        confirmButton.layer.cornerRadius = 12
        confirmButton.layer.masksToBounds = true
        confirmButton.setTitleColor(.white, for: .normal)
        cancelButton.setTitleColor(Themes.gray33617D, for: .normal)
        cancelButton.layer.borderColor = UIColor(rgb: 0xCDD9E4).cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 12
        cancelButton.layer.masksToBounds = true
    }
    func bindTextView()
    {
        if alertMode == .reject
        {
            let isValid = messageTextView.rx.text.map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return !acc.isEmpty
            }
            isValid.skip(0).bind(to: confirmButton.rx.isEnabled).disposed(by: dpg)
        }
    }
    func bindButton()
    {
        confirmButton.rx.tap.subscribeSuccess { [self] _ in
            onConfirmClick.onNext((true, messageTextView.text))
        }.disposed(by: dpg)
        cancelButton.rx.tap.subscribeSuccess { [self] _ in
            onConfirmClick.onNext((false, messageTextView.text))
        }.disposed(by: dpg)
    }
    func rxConfirmClick() -> Observable<(Bool , String)>
    {
        onConfirmClick.asObservable()
    }
}
extension AuditTriggerAlertView : UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText string: String) -> Bool
    {
        let newPosition = textView.endOfDocument
        textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        guard let text = textView.text ,text.count < 100 else {
            if string == ""
            {
                return true
            }else
            {
                return false
            }
        }
        if string == ""
        {
            return true
        }
        /// 3.检查总长度限制 (最多输入10位)
        if text.count >= 100 || (text.count + string.count) >= 100 {
            return false
        }
        return true
    }
}
