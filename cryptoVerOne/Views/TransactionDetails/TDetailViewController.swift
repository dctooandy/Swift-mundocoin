//
//  TDetailViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/16.
//


import Foundation
import RxCocoa
import RxSwift

class TDetailViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var titleString = ""
    // model
    var addressModel = ""{
        didSet{
            withdrawToInputView.textField.text = addressModel
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var withdrawToView: UIView!
    @IBOutlet weak var txidView: UIView!
    var withdrawToInputView : InputStyleView!
    var txidInputView : InputStyleView!
    // MARK: -
    // MARK:Life cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = titleString
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        withdrawToInputView = InputStyleView(inputViewMode: .withdrawTo(true))
        withdrawToView.addSubview(withdrawToInputView)
        withdrawToInputView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        txidInputView = InputStyleView(inputViewMode: .txid)
        txidInputView.textField.text = "37f5d6c3d1c4408a47e34601febd78ad9be79473df71742805a8b2a339c25b9e"
        txidView.addSubview(txidInputView)
        txidInputView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
// MARK: -
// MARK: 延伸

