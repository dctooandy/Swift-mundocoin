//
//  WalletViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import UIKit
import UPCarouselFlowLayout
import SnapKit
import RxCocoa
import RxSwift
import UserNotifications
import SafariServices
import SDWebImage

class WalletViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
   
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
}
// MARK: -
// MARK: 延伸
