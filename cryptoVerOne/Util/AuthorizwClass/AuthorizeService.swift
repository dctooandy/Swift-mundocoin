//
//  AuthorizeService.swift
//  cryptoVerOne
//
//  Created by BBk on 7/4/22.
//

import Foundation
import RxCocoa
import RxSwift
import Photos
import UIKit
class AuthorizeService {
    // MARK:業務設定
    // MARK: -
    private let onShowAlert = PublishSubject<UIAlertController>()
    static var share = AuthorizeService()
    // MARK:UI 設定
   
    // MARK: -
    // MARK:Life cycle
    func authorizePhoto() -> Bool {
        let photoLibraryStatus = PHPhotoLibrary.authorizationStatus() //相簿請求
        switch ( photoLibraryStatus){ //判斷狀態
        case .authorized: //兩個都允許
            return true
        case (.notDetermined): //相機允許，相簿未決定，相簿請求授權
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async(execute: {
                    _ = self.authorizePhoto()
                })
            })
        case (.denied): //相機允許，相簿拒絕，做出提醒
            DispatchQueue.main.async(execute: { [self] in
                let alertController = UIAlertController(title: "提醒", message: "您目前拍攝的照片並不會儲存至相簿，要前往設定嗎?", preferredStyle: .alert)
                let canceAlertion = UIAlertAction(title: "取消", style: .cancel, handler: {(status) in})
                let settingAction = UIAlertAction(title: "設定", style: .default, handler: { (action) in
                    let url = URL(string: UIApplication.openSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                print("跳至設定")
                                alertController.dismiss(animated: false)
                            })
                        } else {
                            UIApplication.shared.openURL(url)
                            alertController.dismiss(animated: false)
                        }
                    }
                })
                alertController.addAction(canceAlertion)
                alertController.addAction(settingAction)
                onShowAlert.onNext(alertController)
//                self.present(alertController, animated: true, completion: nil)
            })
        default: //預設，如都不是以上狀態
            DispatchQueue.main.async(execute: { [self] in
                let alertController = UIAlertController(title: "提醒", message: "請點擊允許才可於APP內開啟相機及儲存至相簿", preferredStyle: .alert)
                let canceAlertion = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let settingAction = UIAlertAction(title: "設定", style: .default, handler: { (action) in
                    let url = URL(string: UIApplication.openSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                print("跳至設定")
                                alertController.dismiss(animated: false)
                            })
                        } else {
                            UIApplication.shared.openURL(url)
                            alertController.dismiss(animated: false)
                        }
                    }
                })
                alertController.addAction(canceAlertion)
                alertController.addAction(settingAction)
                onShowAlert.onNext(alertController)
//                self.present(alertController, animated: true, Completion: nil)
            })
        }
        return false
    }
    func authorizeAVCapture() -> Bool {
        let camStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video) //相機請求
        switch (camStatus){ //判斷狀態
        case (.authorized): //兩個都允許
            return true
        case (.notDetermined): //兩個都還未決定,就請求授權
            AVCaptureDevice.requestAccess(for: AVMediaType.video,  completionHandler: { (status) in
                DispatchQueue.main.async(execute: {
                    _ = self.authorizeAVCapture()
                })
            })
        default: //預設，如都不是以上狀態
            DispatchQueue.main.async(execute: { [self] in
                let alertController = UIAlertController(title: "提醒", message: "請點擊允許才可於APP內開啟相機及儲存至相簿", preferredStyle: .alert)
                let canceAlertion = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let settingAction = UIAlertAction(title: "設定", style: .default, handler: { (action) in
                    let url = URL(string: UIApplication.openSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                print("跳至設定")
                                alertController.dismiss(animated: false)
                            })
                        } else {
                            UIApplication.shared.openURL(url)
                            alertController.dismiss(animated: false)
                        }
                    }
                })
                alertController.addAction(canceAlertion)
                alertController.addAction(settingAction)
                onShowAlert.onNext(alertController)
//                self.present(alertController, animated: true, Completion: nil)
            })
        }
        return false
    }
    func authorize() -> Bool {
        let photoLibraryStatus = PHPhotoLibrary.authorizationStatus() //相簿請求
        let camStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video) //相機請求
        switch (camStatus, photoLibraryStatus){ //判斷狀態
        case (.authorized,.authorized): //兩個都允許
            return true
        case (.notDetermined,.notDetermined): //兩個都還未決定,就請求授權
            AVCaptureDevice.requestAccess(for: AVMediaType.video,  completionHandler: { (status) in
                DispatchQueue.main.async(execute: {
                    _ = self.authorize()
                })
            })
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async(execute: {
                    _ = self.authorize()
                })
            })
        case (.authorized,.notDetermined): //相機允許，相簿未決定，相簿請求授權
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async(execute: {
                    _ = self.authorize()
                })
            })
        case (.authorized,.denied): //相機允許，相簿拒絕，做出提醒
            DispatchQueue.main.async(execute: { [self] in
                let alertController = UIAlertController(title: "提醒", message: "您目前拍攝的照片並不會儲存至相簿，要前往設定嗎?", preferredStyle: .alert)
                let canceAlertion = UIAlertAction(title: "取消", style: .cancel, handler: {(status) in})
                let settingAction = UIAlertAction(title: "設定", style: .default, handler: { (action) in
                    let url = URL(string: UIApplication.openSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                print("跳至設定")
                                alertController.dismiss(animated: false)
                            })
                        } else {
                            UIApplication.shared.openURL(url)
                            alertController.dismiss(animated: false)
                        }
                    }
                })
                alertController.addAction(canceAlertion)
                alertController.addAction(settingAction)
                onShowAlert.onNext(alertController)
//                self.present(alertController, animated: true, completion: nil)
            })
        default: //預設，如都不是以上狀態
            DispatchQueue.main.async(execute: { [self] in
                let alertController = UIAlertController(title: "提醒", message: "請點擊允許才可於APP內開啟相機及儲存至相簿", preferredStyle: .alert)
                let canceAlertion = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let settingAction = UIAlertAction(title: "設定", style: .default, handler: { (action) in
                    let url = URL(string: UIApplication.openSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                print("跳至設定")
                                alertController.dismiss(animated: false)
                            })
                        } else {
                            UIApplication.shared.openURL(url)
                            alertController.dismiss(animated: false)
                        }
                    }
                })
                alertController.addAction(canceAlertion)
                alertController.addAction(settingAction)
                onShowAlert.onNext(alertController)
//                self.present(alertController, animated: true, Completion: nil)
            })
        }
        return false
    }
    func rxShowAlert() -> Observable<UIAlertController>
    {
        onShowAlert.asObservable()
    }
    
}
