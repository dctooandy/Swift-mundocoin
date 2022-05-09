//
//  Reactive+util.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
extension Reactive where Base:UIView {
    
    var click:Observable<Void> {
        let tap = UITapGestureRecognizer()
        base.addGestureRecognizer(tap)
        base.isUserInteractionEnabled = true
        return tap.rx.event.map{ _ -> Void  in
            return
        }
    }
}
