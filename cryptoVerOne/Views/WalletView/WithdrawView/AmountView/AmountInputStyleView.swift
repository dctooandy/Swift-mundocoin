//
//  AmountInputStyleView.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/12/2.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

class AmountInputStyleView: UIView ,NibOwnerLoadable{
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var maxAmount : String = "0"
    var currency : String = "TW"
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var availableBalanceAmountLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var inputContentView :UIView!
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
//        amountTextView.tintColor = .clear
        addDoneCancelToolbar()
        inputContentView.layer.borderColor = Themes.grayE0E5F2.cgColor
        inputContentView.layer.borderWidth = 1.0
//        inputContentView.applyCornerAndShadow(radius: 10)
    }
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
//        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(cancelButtonTapped))
        let doneItem = UIBarButtonItem(image: UIImage(named: "icon-chevron-down"), style: .done, target: onDone.target, action: onDone.action)
//        doneItem.tintColor = .white
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
//            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            doneItem
        ]
//        toolbar.setBackgroundImage(UIImage().imageWithColor(color: Themes.gray2B3674), forToolbarPosition: .bottom, barMetrics: .default)
        toolbar.sizeToFit()
        
        self.amountTextView.inputAccessoryView = toolbar
    }
    // Default actions:
    @objc func cancelButtonTapped() { self.amountTextView.resignFirstResponder() }
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
extension AmountInputStyleView:UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newPosition = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        guard let text = textField.text else {
            return true
        }
        
        /// 1.过滤删除事件
        guard !string.isEmpty else {
            if textField.text?.count == 1
            {
                textField.text = "0"
                return false
            }else
            {
                return true
            }
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
        /// 0818 產品驗收 限制長度調整為小數點後5位
        if let ran = text.range(of: "."), range.location - NSRange(ran, in: text).location == 5 {
            if text.toDouble() == 0 , string.toDouble() == 0
            {
                amountTextView.text = "0.00001"
                return false
            }
            return true
        }
        /// 0818 產品驗收 限制長度調整為小數點後5位
        if let ran = text.range(of: "."), range.location - NSRange(ran, in: text).location > 5 {
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
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.resignFirstResponder()
    }
}
