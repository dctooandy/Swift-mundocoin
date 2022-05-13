//
//  WithdrawViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/9.
//

import Foundation
import RxCocoa
import RxSwift

class WithdrawViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
   
    @IBOutlet weak var withdrawToInputView: UIView!
    @IBOutlet weak var methodInputView: UIView!
    var withdrawToView : InputStyleView!
    var methodView : InputStyleView!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Withdraw"
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func setupUI()
    {
        withdrawToView = InputStyleView(inputViewMode: .copy)
        methodView = InputStyleView(inputViewMode: .twoFAVerify)
        
        withdrawToInputView.addSubview(withdrawToView)
        methodInputView.addSubview(methodView)
        withdrawToView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        methodView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    // MARK: -
    // MARK:業務方法
}
// MARK: -
// MARK: 延伸
