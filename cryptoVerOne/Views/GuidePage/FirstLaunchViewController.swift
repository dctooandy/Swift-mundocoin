//
//  FirstLaunchViewController.swift
//  betlead
//
//  Created by Victor on 2019/5/31.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import RxSwift

class FirstLaunchViewController: BaseViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var passButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var goMainButton: UIButton!
    @IBOutlet weak var goRegisterButton: UIButton!
    @IBOutlet weak var lastStepButtonContentView: UIView!
    var nextButton: ImagetTextButton?
    var launchStep: GuideStep = .first 

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupUI() {
        titleLabel.text = launchStep.title()
        subtitleLabel.text = launchStep.subtitle()
        backgroundImageView.image = launchStep.image()
        switch launchStep {
        case .first, .second:
            nextButton = ImagetTextButton(title: "下一步", image: #imageLiteral(resourceName: "arrow-circle-right"))
            view.addSubview(nextButton!)
            nextButton?.snp.makeConstraints({ (make) in
                make.top.equalTo(subtitleLabel.snp.bottom).offset(48)
                make.width.equalToSuperview().multipliedBy(0.46)
                make.height.equalToSuperview().multipliedBy(0.06)
                make.centerX.equalToSuperview()
            })
            
        case .third:
            passButton.isHidden = true
            lastStepButtonContentView.isHidden = false
            let borderWidth: CGFloat = 1
            let borderColor: CGColor = UIColor.white.cgColor
            let cornerRadius: CGFloat = (view.frame.height * 0.06) / 2
            
            goMainButton.layer.cornerRadius = cornerRadius
            goMainButton.layer.borderWidth = borderWidth
            goMainButton.layer.borderColor = borderColor
            goMainButton.clipsToBounds = true

            goRegisterButton.layer.cornerRadius = cornerRadius
            goRegisterButton.layer.borderWidth = borderWidth
            goRegisterButton.layer.borderColor = borderColor
            goRegisterButton.clipsToBounds = true
        }
        
        
    }

    func binding(goMain: @escaping () -> (), goLogin: @escaping () -> (), next: @escaping (Int) -> (), pass: @escaping () -> ()) {
        goMainButton.rx
            .tap
            .subscribeSuccess {
                goMain()
            }.disposed(by: disposeBag)
        
        goRegisterButton.rx
            .tap
            .subscribeSuccess {
                goLogin()
            }.disposed(by: disposeBag)
        
        nextButton?.rx
            .tap
            .subscribeSuccess{
                next(self.launchStep.rawValue)
            }.disposed(by: disposeBag)
        passButton.rx
            .tap
            .subscribeSuccess {
                pass()
            }.disposed(by: disposeBag)
    }
}
