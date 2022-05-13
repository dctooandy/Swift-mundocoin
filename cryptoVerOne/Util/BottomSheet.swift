//
// Created by liq on 2018/4/10.
//

import Foundation
import UIKit
import SnapKit
import RxCocoa
import RxSwift

@objcMembers class BottomSheet: BaseViewController {
    
    var defaultContainerHeight : CGFloat = 414.0
    let subject = PublishSubject<Any?>()
    var value:Any?
    static let bottomSheetDismissNotify = "BottomSheetDismissNotify"
    private var isSetupBgview = true
    lazy var tap = UITapGestureRecognizer(target: self, action: #selector(dismissToTopVC))
    lazy var dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    let defaultContainer:UIView = UIView(color: .white)
    private var shouldCompleteTransition = false
    private var firstLocation:CGFloat?
    private var transitionInProgress = false
    var nextSheet:BottomSheet.Type?
    var nextNextSheet:BottomSheet.Type?
    var nextNextSheetVC:BottomSheet?
    var nextSheetVC:BottomSheet?
    lazy var cancelBtn:UIButton = {
        let btn = UIButton()
        btn.setTitle("Close", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.addTarget(self, action: #selector(dismissToTopVC), for: .touchUpInside)
        return btn
    }()
     lazy var nextBtn:UIButton = {
        let btn = UIButton()
        btn.setTitle("next", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.addTarget(self, action: #selector(presentVC), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
     lazy var backBtn:UIButton = {
        let btn = UIButton()
        btn.setTitle("Back", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        subject.onNext(value)
    }
    private let separeator = UIView(color: Themes.grayLayer)
                
    var isHideBackBtn = true {
        didSet{
            backBtn.isHidden = isHideBackBtn
        }
    }
    
    var parameters:Any?
    
    required  init(_ parameters:Any? = nil) {
        self.parameters = parameters
        super.init()
        modalPresentationStyle = .custom
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        handlePanGesture()

    }
    
    @discardableResult
    func start(viewController:UIViewController ,height:CGFloat = 414 ,animated:Bool = true ,completion:(() -> Void)? = nil) -> Observable<Any?> {
        self.defaultContainerHeight = height
        self.transitioningDelegate = viewController
        viewController.present(self, animated: animated, completion: completion)
        return subject.asObserver()
    }
    
    func disablePanGesture(){
        pan.isEnabled = false
    }
    private let pan = UIPanGestureRecognizer()

    private func handlePanGesture() {
        pan.delegate = self
        defaultContainer.addGestureRecognizer(pan)
        pan.rx.event.subscribe(onNext: {[weak self] (gesture) in
            guard let weakSelf = self else { return }
            let viewTranslation = gesture.translation(in:gesture.view?.superview)
            if weakSelf.firstLocation == nil {
                weakSelf.firstLocation = viewTranslation.y
            }
            let offsetY = viewTranslation.y > 0 ? viewTranslation.y : 0
            let progress = (offsetY / Views.screenHeight)
            switch gesture.state {
            case .began:
                weakSelf.transitionInProgress = true
                break
            case .changed:
                weakSelf.shouldCompleteTransition = progress > 0.2
                weakSelf.defaultContainer.transform = CGAffineTransform(translationX: 0, y: offsetY)
                break
            case .cancelled:
                weakSelf.transitionInProgress = false
                weakSelf.cancel()
                break
            case .ended:
                weakSelf.transitionInProgress = false
                weakSelf.shouldCompleteTransition ? weakSelf.dismissToTopVC() : weakSelf.cancel()
                break
            default:
                return
            }
        }).disposed(by: disposeBag)
    }
    private func cancel(){
        defaultContainer.transform = CGAffineTransform.identity
    }
    
    private func getTopBottomSheet(_ vc:BottomSheet?) -> BottomSheet? {
        if let vc = vc?.presentingViewController as? BottomSheet {
            return getTopBottomSheet(vc)
        }
        return vc
    }
    
    deinit {
        
    }
    
    private lazy var bgView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private func setupBgView() {
        view.insertSubview(bgView, at: 0)
        bgView.snp.makeConstraints { maker in
            maker.edges.equalTo(UIEdgeInsets.zero)
        }
    }
    
    required init?(coder aDecoder:NSCoder) {
        fatalError("wrong")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        if isSetupBgview {
            setupBgView()
            isSetupBgview = false
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setupViews(){
        view.addSubview(defaultContainer)
    }
    
    func isAddDismissGesture(_ isAadd:Bool) {
        if isAadd {
            self.bgView.addGestureRecognizer(tap)
        } else {
            self.bgView.gestureRecognizers = []
        }
    }
    
    @objc func sendBtnDidTapped() {
        
    }
    
    @objc func presentVC(){
        let newVC = BottomSheet()
        newVC.isHideBackBtn = false
        newVC.start(viewController: self)
    }
    
     func dismissVC(nextSheet:BottomSheet? = nil)  {
        if let nextSheet = nextSheet {
          guard  let presentingVC = presentingViewController else { return }
            dismiss(animated: true) {
                nextSheet.start(viewController: presentingVC)
            }
        }
        if let nextSheet = self.nextSheet {
            guard  let presentingVC = presentingViewController else { return }
            dismiss(animated: true) {
                let nextVC = nextSheet.init()
                self.assignNextSheet(nextVC)
                nextVC.start(viewController: presentingVC)
            }
        }
        if let nextSheet = self.nextSheetVC {
            guard  let presentingVC = presentingViewController else { return }
            dismiss(animated: true) {
               self.assignNextSheet(nextSheet)
                nextSheet.start(viewController: presentingVC)
            }
        }
       
        dismiss(animated: true, completion: nil)
    }
    
    private func assignNextSheet(_ newVC:BottomSheet){
        if let nextSheet = self.nextNextSheet {
            newVC.nextSheet = nextSheet
        }
        if let nextSheetVC = self.nextNextSheetVC {
            newVC.nextSheetVC = nextSheetVC
        }
    }
    
    @objc func dismissToTopVC() {
        //    NotificationCenter.default.post(name: Notification.Name(BottomSheet.bottomSheetDismissNotify), object: type(of: self))
        let topBottomSheet = getTopBottomSheet(self)
        topBottomSheet?.presentingViewController?.dismiss(animated: false, completion: {
            self.defaultContainer.transform = CGAffineTransform.identity
        })
    }
    
    @objc private func keyboardWillShow(_ notification:Notification) {
        isAddDismissGesture(false)
        self.view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    @objc private func keyboardWillHide(_ notification:Notification) {
        isAddDismissGesture(true)
        self.view.removeGestureRecognizer(dismissKeyboardTap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}

extension BottomSheet {
    override func animationController(forPresented presented:UIViewController,
                                    presenting:UIViewController,
                                    source:UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomSheetPresentAnimationController()
    }
    
    override func animationController(forDismissed dismissed:UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomSheetDismissAnimationController()
    }
}

extension BottomSheet:UIGestureRecognizerDelegate {
     func gestureRecognizerShouldBegin(_ gestureRecognizer:UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: defaultContainer)
            return abs(velocity.y) > abs(velocity.x)
        }
        return true
    }
}
