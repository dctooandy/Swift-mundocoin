//
//  TwoWayVerifyViewController.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/21.
//


import Foundation
import RxCocoa
import RxSwift

class TwoWayVerifyViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    private let onEmailSendVerifyClick = PublishSubject<Any>()
    private let onMobileSendVerifyClick = PublishSubject<Any>()
    private let onSubmitOnlyEmailClick = PublishSubject<String>()
    private let onSubmitOnlyMobileClick = PublishSubject<String>()
    private var isSendEmailVerifyCode : Bool = false
    private var isSendMobileVerifyCode : Bool = false
    var twoWayViewMode : TwoWayViewMode = .onlyEmail {
        didSet{
            setup()
            bindView()
        }
    }
    // MARK: -
    // MARK:UI 設定
    var verifyView = TwoWayVerifyView()
    // MARK: -
    // MARK:Life cycle
    // MARK: instance
    static func instance(mode: TwoWayViewMode) -> TwoWayVerifyViewController {
        let vc = TwoWayVerifyViewController.loadNib()
        vc.twoWayViewMode = mode
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if twoWayViewMode == .onlyEmail , isSendEmailVerifyCode == false
        {
            isSendEmailVerifyCode = true
            verifyView.emailInputView.sendVerifyCode()
        }else if twoWayViewMode == .onlyMobile , isSendMobileVerifyCode == false
        {
            isSendMobileVerifyCode = true
            verifyView.mobileInputView.sendVerifyCode()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        verifyView.cleanTimer()
    }
    // MARK: -
    // MARK:業務方法
    func setup()
    {
        let onlyView = TwoWayVerifyView.loadNib()
        onlyView.twoWayViewMode = twoWayViewMode
        self.verifyView = onlyView
        self.view.addSubview(self.verifyView)
        verifyView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(28)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    func bindView()
    {
        self.verifyView.rxEmailSecondSendVerifyAction().subscribeSuccess { [self](_) in
            onEmailSendVerifyClick.onNext(())
        }.disposed(by: dpg)
        self.verifyView.rxMobileSecondSendVerifyAction().subscribeSuccess { [self](_) in
            onMobileSendVerifyClick.onNext(())
        }.disposed(by: dpg)
        self.verifyView.rxSubmitOnlyEmailAction().subscribeSuccess {[self](stringData) in
            Log.i("發送submit請求 ,onlyEmail:\(stringData)")
            onSubmitOnlyEmailClick.onNext(stringData)
            verifyView.resetProperty()
        }.disposed(by: dpg)
        self.verifyView.rxSubmitOnlyMobileAction().subscribeSuccess {[self](stringData) in
            Log.i("發送submit請求 ,onlyMobile:\(stringData)")
            onSubmitOnlyMobileClick.onNext(stringData)
            verifyView.resetProperty()
        }.disposed(by: dpg)
    }
    func cleanTimerAndResetProperty()
    {
        isSendEmailVerifyCode = false
        isSendMobileVerifyCode = false
        verifyView.cleanTimer()
    }
    func rxEmailSendVerifyAction() -> Observable<(Any)>
    {
        return onEmailSendVerifyClick.asObserver()
    }

    func rxMobileSendVerifyAction() -> Observable<(Any)>
    {
        return onMobileSendVerifyClick.asObserver()
    }
    
    func rxSecondSubmitOnlyEmailAction() -> Observable<(String)>
    {
        return onSubmitOnlyEmailClick.asObserver()
    }
    func rxSecondSubmitOnlyMobileAction() -> Observable<(String)>
    {
        return onSubmitOnlyMobileClick.asObserver()
    }
    func modeTitle() -> String {
        switch twoWayViewMode {
        case .onlyEmail: return "E-mail".localized
        case .onlyMobile: return "Mobile".localized
        case .both: return ""
        }
    }
}
// MARK: -
// MARK: 延伸
