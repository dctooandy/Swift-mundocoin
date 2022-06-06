//
//  TransactionTableViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 6/6/22.
//

import Foundation
import RxCocoa
import RxSwift

class TransactionTableViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var showModeAtTableView : TransactionShowMode = .deposits{
        didSet{
            setup()
            bindView()
        }
    }
    // MARK: -
    // MARK:UI 設定
    var verifyView = TwoFAVerifyView()
    // MARK: -
    // MARK:Life cycle
    // MARK: instance
    static func instance(mode: TransactionShowMode) -> TransactionTableViewController {
        let vc = TransactionTableViewController()
        vc.showModeAtTableView = mode
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Themes.grayF4F7FE
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        verifyView.cleanTimer()
    }
    // MARK: -
    // MARK:業務方法

    func setup()
    {
        
//        let onlyView = TwoFAVerifyView.loadNib()
//        onlyView.twoFAViewMode = twoFAViewMode
//        self.verifyView = onlyView
//        self.view.addSubview(self.verifyView)
//        verifyView.snp.remakeConstraints { (make) in
//            make.top.equalToSuperview().offset(42)
//            make.leading.trailing.bottom.equalToSuperview()
//        }
    }
    func bindView()
    {
//        self.verifyView.rxSecondSendVerifyAction().subscribeSuccess { [self](_) in
//            onThirdSendVerifyClick.onNext(())
//        }.disposed(by: dpg)
//        self.verifyView.rxSubmitOnlyEmailAction().subscribeSuccess {[self](stringData) in
//            Log.i("發送submit請求 ,onlyEmail:\(stringData)")
//            onSubmitOnlyEmailClick.onNext(stringData)
//        }.disposed(by: dpg)
//        self.verifyView.rxSubmitOnlyTwiFAAction().subscribeSuccess {[self](stringData) in
//            Log.i("發送submit請求 ,onlyTwoFA:\(stringData)")
//            onSubmitOnlyTwoFAClick.onNext(stringData)
//        }.disposed(by: dpg)
    }

    func modeTitle() -> String {
        switch showModeAtTableView
        {
        case .deposits:
            return  "Deposits".localized
        case .withdrawals:
            return  "Withdrawals".localized
        }
    }
}
// MARK: -
// MARK: 延伸
