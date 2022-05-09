//
//  Toast+util.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation
import Toaster
import RxSwift
import RxCocoa

extension Toast {
    
  static let subject = PublishSubject<String>()
  
    static func show(msg:String) {
    subject.onNext(msg)
  }
    
    static func bindSubject() {
        subject.throttle(2.5, latest:false, scheduler: MainScheduler.instance).subscribeSuccess { (msg) in
            DispatchQueue.main.async {
                let toast = Toast(text: msg)
                toast.duration = 2.5
                toast.show()
            }
            
        }.disposed(by: disposeBag)
    }
    static let disposeBag = DisposeBag()
    static func showSuccess(msg:String) {
        let toast = Toast(text: msg)
        toast.view.textColor = Themes.trueGreenLayerColor
        toast.show()
    }
    
}
