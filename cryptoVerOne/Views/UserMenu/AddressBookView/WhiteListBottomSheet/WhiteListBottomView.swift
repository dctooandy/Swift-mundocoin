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
    var timer: Timer?
    var time: Float = 0.0
    var timeDiff: Float = 0.0
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var frontSliderView: UISlider!
    @IBOutlet weak var backProgressView: UIProgressView!
    @IBOutlet weak var finalCircleView: UIView!
    @IBOutlet weak var coverView: UIView!
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
        frontSliderView.setThumbImage(UIImage(named: "Rectangle14"), for: .normal)
        frontSliderView.setThumbImage(UIImage(named: "Rectangle14"), for: .highlighted)
        // 給 progressView 預設0.1
        backProgressView.setProgress(0.1, animated: true)
        // 給thumb 預設圓角
        backProgressView.layer.sublayers![1].cornerRadius = 25
        if #available(iOS 11.0, *) {
            backProgressView.layer.sublayers![1].maskedCorners = [.layerMaxXMaxYCorner , .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        backProgressView.subviews[1].layer.masksToBounds = true
        coverView.snp.updateConstraints { make in
            make.top.bottom.equalTo(backProgressView)
        }
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider ,forEvent event: UIEvent) {
        if let touchEvent = event.allTouches?.first
        {
            // progreeeView 的寬比slider 小 ,比例不同的情況下,依照比例微調 progreeeView長度
            var progressValue:Float = 0.1
            if sender.value < 0.25
            {
                progressValue = sender.value + 0.1
            }else if sender.value < 0.4
            {
                progressValue = sender.value + 0.05
            }else if sender.value < 0.7
            {
                progressValue = sender.value + 0.02
            }else {
                progressValue = sender.value
            }
           
            switch touchEvent.phase {
            case .began:
                print("touches began")
                backProgressView.setProgress(progressValue, animated: false)
            case .moved:
                print("touches moved")
                backProgressView.setProgress(progressValue, animated: false)
            case .ended:
                print("touches ended")
                if sender.value == 1.0
                {
                    //拉滿之後的動畫
                    finalCircleView.isHidden = false
                    UIView.animate(withDuration: 0.4, delay: 0, options: []) { [self] in
                        sliderView.transform = sliderView.transform.scaledBy(x: 0.1, y: 1)
                        backProgressView.setProgress(0.5, animated: true)
                        frontSliderView.setValue(0.5, animated: true)
                        sliderView.alpha = 0.0
                        finalCircleView.alpha = 1.0
                    } completion: { [self]success in
                        onSliderTrigger.onNext(())
                    }
                }else
                {
                    // 沒拉到底
                    // slider 會很認份依照druation 跑回原位
                    frontSliderView.setValue(0, animated: true)
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: { [self] in
                        frontSliderView.setValue(0.0, animated: true)
                    },completion: nil)
                    // progreeeView 需要用timer才能跑完
                    setTimerForProgress(value: backProgressView.progress)
                }
            default:
                break
            }
        }
    }
    func setTimerForProgress(value:Float)
    {
        // 設定 timer 給progressView 分段式縮減,看起來像動畫
        timeDiff = Float((Double(value) / 5.0))
        timer = Timer.scheduledTimer(timeInterval: 0.023, target: self, selector: #selector(setProgress), userInfo: nil, repeats: true)
        time = value
    }
    @objc func setProgress()
    {
        time -= timeDiff
        backProgressView.setProgress(time, animated: true)
        if time <= 0.1 {
            timer!.invalidate()
            timer = nil
        }
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

