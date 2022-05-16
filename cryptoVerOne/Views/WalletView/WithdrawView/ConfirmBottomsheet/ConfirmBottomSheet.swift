//
//  ConfirmBottomSheet.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/13.
//


import Foundation
import RxCocoa
import RxSwift

class ConfirmBottomSheet: BaseBottomSheet {
    // MARK:業務設定
    private let onSecondConfirmClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var addressString = ""
    // MARK: -
    // MARK:UI 設定
    var confirmView = ConfirmBottomView.loadNib()
    // MARK: -
    // MARK:Life cycle
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(address: String ) {
        super.init()
        addressString = address
    }
    
    required init(_ parameters: Any? = nil) {
        fatalError("init(_:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
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
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        confirmView.addressString = addressString
        defaultContainer.addSubview(confirmView)
        confirmView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    func bindUI()
    {
        confirmView.rxConfirmAction().subscribeSuccess { [self](_) in
            dismiss(animated: true) {
                onSecondConfirmClick.onNext(())
            }
        }.disposed(by: dpg)
    }
    func rxSecondConfirmAction() -> Observable<Any>
    {
        return onSecondConfirmClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
