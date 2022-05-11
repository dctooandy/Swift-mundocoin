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
    private lazy var backBtn:UIButton = {
        let btn = UIButton()
        let image = UIImage(named:"back")?.reSizeImage(reSize: CGSize(width: Views.backImageHeight(), height: Views.backImageHeight())).withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
//        btn.setImage(UIImage(named:"left-arrow"), for:.normal)
        btn.tintColor = .black
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        btn.setTitle("", for:.normal)
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
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
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
    @objc func popVC(isAnimation : Bool = true)
    {
        _ = self.navigationController?.popToRootViewController(animated: isAnimation)
    }
}
// MARK: -
// MARK: 延伸
