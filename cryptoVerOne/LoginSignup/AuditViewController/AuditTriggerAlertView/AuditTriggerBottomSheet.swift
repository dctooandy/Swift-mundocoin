//
//  AuditTriggerBottomSheet.swift
//  cryptoVerOne
//
//  Created by BBk on 7/8/22.
//

import Foundation
import RxCocoa
import RxSwift

enum AuditTriggerMode {
    case accept
    case reject
    
    var titleString: String {
        switch self {
        case .accept:
            return "Withdrawals Accept"
        case .reject:
            return "Withdrawals Reject *"
        }
    }
    var rightButtonString: String {
        switch self {
        case .accept:
            return "Confirm"
        case .reject:
            return "Reject"
        }
    }
}

class AuditTriggerBottomSheet: BaseBottomSheet {
    // MARK:業務設定
    var alertMode : AuditTriggerMode!
    private let dpg = DisposeBag()
    typealias DoneHandler = (Bool , String) -> ()
    var doneHandler: DoneHandler!
    private let onConfirmClick = PublishSubject<(Bool , String)>()
    // MARK: -
    // MARK:UI 設定
    var alertView = AuditTriggerAlertView.loadNib()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewAction()
        setNotification()
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
    init(alertMode:AuditTriggerMode = .accept , _ done: DoneHandler?) {
        super.init()
        self.alertMode = alertMode
        titleLabel.text = alertMode.titleString
        doneHandler = done
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ parameters: Any? = nil) {
        fatalError("init(_:) has not been implemented")
    }
    
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        defaultContainer.addSubview(alertView)
        alertView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        alertView.alertMode = self.alertMode
    }
    func bindViewAction()
    {
        alertView.rxConfirmClick().subscribeSuccess { [self] data in
            dismiss(animated: true){ [self] in
                doneHandler(data.0 , data.1)
            }

        }.disposed(by: dpg)
    }
    func setNotification()
    {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if ((alertView.messageTextView.isFirstResponder) == true)
            {
                let diffHeight = (360 - alertView.messageTextView.frame.minY)
                if diffHeight < (keyboardHeight + 50)
                {
                    let upHeight = (keyboardHeight) 
                    var newFrame = self.view.frame
                    newFrame.size.height = (Views.screenHeight - upHeight)
                    UIView.animate(withDuration: 0.5) {
                        self.view.frame = newFrame
                        self.view.layoutIfNeeded() // add this
                    }
                }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        var newFrame = self.view.frame
        newFrame.size.height = Views.screenHeight
        UIView.animate(withDuration: 0.5) {
            self.view.frame = newFrame
            self.view.layoutIfNeeded() // add this
        }
    }
}
// MARK: -
// MARK: 延伸
