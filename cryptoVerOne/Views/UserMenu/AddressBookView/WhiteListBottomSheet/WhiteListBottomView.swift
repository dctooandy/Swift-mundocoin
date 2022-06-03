//
//  WhiteListBottomView.swift
//  cryptoVerOne
//
//  Created by BBk on 5/31/22.


import Foundation
import RxCocoa
import RxSwift
import UIKit

class WhiteListBottomView: UIView {
    // MARK:業務設定
    private let onSliderTrigger = PublishSubject<Any>()
    private let dpg = DisposeBag()
    
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var frontSliderView: UISlider!
    @IBOutlet weak var backProgressView: UIProgressView!
    @IBOutlet weak var finalCircleView: UIView!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
//        setupSwitch()
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        titleLabel.text = "Whitelist".localized
        topLabel.text = "When this function is turned on, your account will only be able to withdraw to whitelisted withdrawal addresses. When this function is turned off, your account is able to withdraw to any withdrawal addresses.".localized

        if KeychainManager.share.getWhiteListOnOff() == true
        {
            switchValueChange(true)
            turnLabel.text = "Turn Off".localized
        }else
        {
            switchValueChange(false)
            turnLabel.text = "Turn On".localized
        }
        frontSliderView.setValue(0, animated: true)
        backProgressView.setProgress(0, animated: true)
        frontSliderView.setThumbImage(UIImage(named: "Rectangle14"), for: .normal)
        frontSliderView.setThumbImage(UIImage(named: "Rectangle14"), for: .highlighted)
        backProgressView.transform = backProgressView.transform.scaledBy(x: 1, y: 13)
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider ,forEvent event: UIEvent) {
        if let touchEvent = event.allTouches?.first
        {
            switch touchEvent.phase {
            case .began:
                print("touches began")

            case .ended:
                print("touches ended")
                if sender.value == 1.0
                {
                    finalCircleView.isHidden = false
                    UIView.animate(withDuration: 0.3, delay: 0, options: []) { [self] in
                        sliderView.transform = sliderView.transform.scaledBy(x: 0.1, y: 1)
                        backProgressView.setProgress(0.5, animated: true)
                        frontSliderView.setValue(0.5, animated: true)
                        sliderView.alpha = 0.0
                        finalCircleView.alpha = 1.0
                    } completion: { [self]success in
//                        switchValueChange(!KeychainManager.share.getWhiteListOnOff())
                        onSliderTrigger.onNext(())
                    }

                }else
                {
                    frontSliderView.setValue(0, animated: true)
                    backProgressView.setProgress(0, animated: true)
                }
            default:
                break
            }
        }
        backProgressView.setProgress(sender.value, animated: true)
    }
    func switchValueChange(_ sender: Bool) {
        if sender == true
        {
            TwoSideStyle.share.acceptWhiteListTopImageStyle(.whiteListOn)
            KeychainManager.share.saveWhiteListOnOff(true)
        }else
        {
            TwoSideStyle.share.acceptWhiteListTopImageStyle(.whiteListOff)
            KeychainManager.share.saveWhiteListOnOff(false)
        }
    }
  

    func rxSliderTrigger() -> Observable<Any>
    {
        return onSliderTrigger.asObserver()
    }
}
// MARK: -
// MARK: 延伸

