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
    //
    //  func subscribeResultSuccess<T>(onNext: ((T) -> Void)? = nil)
    //          -> Disposable {
    //    return subscribe(onNext:{ result in
    //      if let result = result as? Result<T> {
    //        switch result {
    //        case .success(let value):
    //          onNext?(value)
    //        case .failure(let error):
    //          if let error = error as? ApiServiceError {
    //            switch error {
    //            case .domainError(let msg):
    //              Toast.show(msg:"domainError: \(msg ?? "")")
    //            case .networkError(let msg):
    //              Toast.show(msg:"networkError: \(msg ?? "")")
    //            case .unknownError(let msg):
    //              Toast.show(msg:"unknownError: \(msg ?? "")")
    //            }
    //          } else {
    //            Toast.show(msg:"unDefine error type")
    //          }
    //        }
    //      }
    //
    //
    //    }, onError:{ error in
    //      if let error = error as? ApiServiceError {
    //        switch error {
    //        case .domainError(let msg):
    //          Toast.show(msg:"domainError: \(msg ?? "")")
    //        case .networkError(let msg):
    //          Toast.show(msg:"networkError: \(msg ?? "")")
    //        case .unknownError(let msg):
    //          Toast.show(msg:"unknownError: \(msg ?? "")")
    //        }
    //      } else {
    //        Toast.show(msg:"unDefine error type")
    //      }
    //
    //    })
    //  }
}
