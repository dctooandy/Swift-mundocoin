//
//  CPasswordViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/6.
//

import Foundation
import RxCocoa
import RxSwift

class CPasswordViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton()
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    let returnButton = CornerradiusButton()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:backBtn)
        setupUI()
        bindButton()
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundImageView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(Views.topOffset + 12.0)
        }
        backgroundImageView.layer.cornerRadius = 20
        backgroundImageView.layer.contents = UIImage(color: .white)?.cgImage
        backgroundImageView.layer.addShadow()
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        view.backgroundColor = #colorLiteral(red: 0.9552231431, green: 0.9678531289, blue: 0.994515121, alpha: 1)
        
        topLabel.text = "You’ve already change password".localized
        view.addSubview(returnButton)
        returnButton.titleLabel?.font = Fonts.pingFangTCRegular(16)
        returnButton.setTitle("Return to log in".localized, for: .normal)
        returnButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        returnButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        returnButton.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom).offset(50)
            make.centerX.equalTo(topLabel)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.065)
        }
    }
    func bindButton()
    {
        returnButton.rx.tap
            .subscribeSuccess { [weak self] in
                self?.returnButtonPressed()
            }.disposed(by: dpg)
    }
    func returnButtonPressed()
    {
        popVC()
    }
    @objc override func popVC()
    {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
// MARK: -
// MARK: 延伸
