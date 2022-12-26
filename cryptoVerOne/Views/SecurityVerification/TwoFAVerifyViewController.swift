//
//  TwoFAVerifyViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/11.
//

import Foundation
import RxCocoa
import RxSwift

class TwoFAVerifyViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    private let onThirdSendVerifyClick = PublishSubject<Any>()
    private let onSubmitOnlyEmailClick = PublishSubject<String>()
    private let onSubmitOnlyTwoFAClick = PublishSubject<String>()
    var twoFAViewMode : TwoFAViewMode = .onlyEmail {
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
    static func instance(mode: TwoFAViewMode) -> TwoFAVerifyViewController {
        let vc = TwoFAVerifyViewController.loadNib()
        vc.twoFAViewMode = mode
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let onlyView = TwoFAVerifyView.loadNib()
        onlyView.twoFAViewMode = twoFAViewMode
        self.verifyView = onlyView
        self.view.addSubview(self.verifyView)
        verifyView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(42)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    func bindView()
    {
        self.verifyView.rxSecondSendVerifyAction().subscribeSuccess { [self](_) in
            onThirdSendVerifyClick.onNext(())
        }.disposed(by: dpg)
        self.verifyView.rxSubmitOnlyEmailAction().subscribeSuccess {[self](stringData) in
            Log.v("發送submit請求 ,onlyEmail:\(stringData)")
            onSubmitOnlyEmailClick.onNext(stringData)
        }.disposed(by: dpg)
        self.verifyView.rxSubmitOnlyTwoFAAction().subscribeSuccess {[self](stringData) in
            Log.v("發送submit請求 ,onlyTwoFA:\(stringData)")
            onSubmitOnlyTwoFAClick.onNext(stringData)
        }.disposed(by: dpg)
    }
    func rxThirdSendVerifyAction() -> Observable<(Any)>
    {
        return onThirdSendVerifyClick.asObserver()
    }

    func rxSecondSubmitOnlyEmailAction() -> Observable<(String)>
    {
        return onSubmitOnlyEmailClick.asObserver()
    }
    func rxSecondSubmitOnlyTwoFAAction() -> Observable<(String)>
    {
        return onSubmitOnlyTwoFAClick.asObserver()
    }
    func modeTitle() -> String {
        switch  twoFAViewMode {
        case .onlyEmail: return "E-mail".localized
        case .onlyTwoFA: return "2FA".localized
        case .both: return ""
        }
    }
}
// MARK: -
// MARK: 延伸
