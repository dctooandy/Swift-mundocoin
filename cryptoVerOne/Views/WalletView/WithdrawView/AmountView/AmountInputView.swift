//
//  AmountInputView.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/16.
//

import Foundation
import RxCocoa
import RxSwift

class AmountInputView: UIView ,NibOwnerLoadable{
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var maxAmount : String = "0"
    var currency : String = "TW"
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var amountTextView: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var maxBalanceLabel: UILabel!
    
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        customInit()
        setupUI()
        bindUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func customInit()
    {
        loadNibContent()
    }
    // MARK: -
    // MARK:業務方法
    func setData(data:String)
    {
        currency = data
    }
    func setupUI()
    {
        currencyLabel.text = currency
        amountTextView.text = "0"
    }
    func bindUI()
    {
        maxBalanceLabel.rx.click.subscribeSuccess { [self](_) in
            amountTextView.text = maxAmount
            amountTextView.sendActions(for: .valueChanged)
        }.disposed(by: dpg)
    }
}
// MARK: -
// MARK: 延伸
extension AmountInputView:UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newPosition = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        guard let text = textField.text else {
            return true
        }
        
        /// 1.过滤删除事件
        guard !string.isEmpty else {
            return true
        }
        
        /// 2.检查允许输入的合法字符
        guard "0123456789.".contains(string) else {
            if string.contains("\n")
            {
                textField.resignFirstResponder()
            }
            return false
        }
        /// 3.检查总长度限制 (最多输入10位)
        if text.count >= 13 {
            return false
        }
        /// 4.检查小数点后位数限制 (小数点后最多输入2位)
        if let ran = text.range(of: "."), range.location - NSRange(ran, in: text).location > 8 {
            return false
        }
        /// 5.检查首位输入是否为0
        if text == "0", string != "." {
            textField.text = string
            return false
        }
        /// 6.特殊情况检查
//        guard string == "." || string == "0" else {
//            return true
//        }
        /// a.首位小数点替换为0.
        if text.count == 0, string == "." {
            textField.text = "0."
            return false
        }
        /// b.禁止多次输入小数点
        if text.range(of: ".") != nil, string == "." {
            return false
        }
        if string != "."
        {
            let finalString = text.appending(string)
            if finalString.toDouble() > maxAmount.toDouble()
            {
                amountTextView.text = maxAmount
                amountTextView.sendActions(for: .valueChanged)
                return false
            }
        }
        return true
//        var result = false
//        if let text = textField.text, let range = Range(range, in: text) {
//            let newText = text.replacingCharacters(in: range, with: string)
//            if newText.count < 10 {
//                result = true
//            }else if string == ""
//            {
//                result = true
//            }else
//            {
//                return false
//            }
//        }
//        if let _ = string.rangeOfCharacter(from: NSCharacterSet.decimalDigits)
//        {
//            result = true
//        }else {
//            if string == ""
//            {
//                result = true
//            }else
//            {
//                result = false
//            }
//        }
//        return result
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.resignFirstResponder()
    }
}

class CustomUITextField: UITextField {
   override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
   }
}
