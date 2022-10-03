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
//            bindTextView()
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
        bindButton()
        setupTextField()
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
            attributedText.addAttributes([NSAttributedString.Key.foregroundColor: Themes.black002033,.font: Fonts.PlusJakartaSansBold(18)], range: textRange)
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
        confirmButton.layer.cornerRadius = 8
        confirmButton.layer.masksToBounds = true
        confirmButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = Themes.grayE3EbF3
        cancelButton.layer.borderColor = UIColor(rgb: 0x004116 ,alpha: 0.08).cgColor
        cancelButton.setTitleColor(Themes.gray33617D, for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 8
        cancelButton.layer.masksToBounds = true
    }
    func setupTextField()
    {
        messageTextView.text = "Message"
        messageTextView.textColor = Themes.grayA1ACB6
    }
    
    func bindTextView()
    {
        if alertMode == .reject
        {
            let isValid = messageTextView.rx.text.map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return !acc.isEmpty
            }
            isValid.bind(to: confirmButton.rx.isEnabled).disposed(by: dpg)
        }
    }
    func bindButton()
    {
        confirmButton.rx.tap.subscribeSuccess { [self] _ in
            let stripped = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if alertMode == .accept
            {
                onConfirmClick.onNext((true, messageTextView.text))
            }else
            {
                if messageTextView.text.isEmpty == true || stripped.count == 0 || messageTextView.text == "Message"
                {
                    messageTextView.layer.borderColor = UIColor.red.cgColor
                }else
                {
                    messageTextView.layer.borderColor = UIColor(rgb: 0xCDD9E4).cgColor
                    onConfirmClick.onNext((true, messageTextView.text))
                }
            }
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
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Themes.grayA1ACB6 {
            textView.text = nil
            textView.textColor = Themes.black002033
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Message"
            textView.textColor = Themes.grayA1ACB6
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText string: String) -> Bool
    {
        messageTextView.layer.borderColor = UIColor(rgb: 0xCDD9E4).cgColor
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
