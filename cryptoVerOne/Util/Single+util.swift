//
//  Single+util.swift
//  cryptoVerOne
//
//  Created by BBk on 5/24/22.
//

import Foundation
import RxSwift
import RxCocoa
import Toaster

extension PrimitiveSequence where TraitType == SingleTrait {
  public func subscribeSuccess(_ callback:((ElementType) -> Void)? = nil) -> Disposable {
    return subscribe(onSuccess: callback, onError: { error in
        ErrorHandler.show(error: error)
    })
  }
}

extension PrimitiveSequence {
    /// 觸發在主線程
    func observeOnMain() -> PrimitiveSequence<Trait, Element> {
        return observeOn(MainScheduler.instance)
    }
}
