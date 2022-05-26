//
//  RecaptchaViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 5/26/22.
//


import ReCaptcha
import RxCocoa
import RxSwift
import UIKit


class RecaptchaViewController: BaseViewController {
    // MARK:業務設定
    private let onSuccessClick = PublishSubject<String>()
    private struct Constants {
        static let webViewTag = 123
        static let testLabelTag = 321
    }
    private var locale: Locale?
    private var endpoint = ReCaptcha.Endpoint.default
    // MARK: -
    // MARK:UI 設定
    private var recaptcha: ReCaptcha!
    @IBOutlet weak var validateBtn: UIButton!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var localeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var endpointSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var visibleChallengeSwitch: UISwitch!
    
     // MARK: -
     // MARK:Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupReCaptcha()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateBtn.sendActions(for: .touchUpInside)
    }
    // MARK: -
    // MARK:業務方法
    @IBAction func didPressEndpointSegmentedControl(_ sender: UISegmentedControl) {
        label.text = ""
        switch sender.selectedSegmentIndex {
        case 0: endpoint = .default
        case 1: endpoint = .alternate
        default: assertionFailure("invalid index")
        }

        setupReCaptcha()
    }

    @IBAction func didPressLocaleSegmentedControl(_ sender: UISegmentedControl) {
        label.text = ""
        switch sender.selectedSegmentIndex {
        case 0: locale = nil
        case 1: locale = Locale(identifier: "zh-CN")
        default: assertionFailure("invalid index")
        }

        setupReCaptcha()
    }

    @IBAction private func didPressButton(button: UIButton) {
//        disposeBag = DisposeBag()

        recaptcha.rx.didFinishLoading
            .debug("did finish loading")
            .subscribe()
            .disposed(by: disposeBag)

        let validate = recaptcha.rx.validate(on: view, resetOnError: false)
            .debug("validate")
            .share()

        let isLoading = validate
            .map { _ in false }
            .startWith(true)
            .share(replay: 1)

        isLoading
            .bind(to: spinner.rx.isAnimating)
            .disposed(by: disposeBag)

        let isEnabled = isLoading
            .map { !$0 }
//            .catchAndReturn(false)
            .share(replay: 1)

        isEnabled
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)

        isEnabled
            .bind(to: endpointSegmentedControl.rx.isEnabled)
            .disposed(by: disposeBag)

        validate
            .map { [weak self] _ in
                self?.view.viewWithTag(Constants.webViewTag)
            }
            .subscribe(onNext: { [self]subview in
                subview?.removeFromSuperview()
                if let valisToken = label.text
                {
                    onSuccessClick.onNext(valisToken)
                }
                navigationController?.popViewController(animated: false)
            })
            .disposed(by: disposeBag)

        validate
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)

        visibleChallengeSwitch.rx.value
            .subscribe(onNext: { [weak recaptcha] value in
                recaptcha?.forceVisibleChallenge = value
            })
            .disposed(by: disposeBag)
    }
    func rxSuccessClick() -> Observable<String>
    {
        return onSuccessClick.asObservable()
    }
    private func setupReCaptcha() {
        // swiftlint:disable:next force_try
        recaptcha = try! ReCaptcha(endpoint: endpoint, locale: locale)

        recaptcha.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
            webview.tag = Constants.webViewTag

            // For testing purposes
            // If the webview requires presentation, this should work as a way of detecting the webview in UI tests
            self?.view.viewWithTag(Constants.testLabelTag)?.removeFromSuperview()
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            label.tag = Constants.testLabelTag
            label.accessibilityLabel = "webview"
            self?.view.addSubview(label)
        }
    }
}
