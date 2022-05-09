//
//  MainViewController.swift
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
class MainViewController: BaseViewController {
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var scrollViweTop: NSLayoutConstraint!
    // MARK: - life cycle
    init() {
        super.init()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setupUI()
    {
//        self.view
    }
}
