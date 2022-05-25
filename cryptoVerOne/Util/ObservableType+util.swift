//
//  ObservableType+util.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation
import RxCocoa
import RxSwift
import Toaster

extension ObservableType {
    public func subscribeSuccess(_ callback:((E) -> Void)? = nil) -> Disposable {
        return subscribe(onNext: callback, onError: { (error) in
            ErrorHandler.show(error: error)
            })
    }
    public func subscribeSuccess<Observer>(_ observer: Observer) -> Disposable where Observer : ObserverType, Self.E == Observer.E {
        return  subscribeSuccess(observer.onNext)
        
    }
}
