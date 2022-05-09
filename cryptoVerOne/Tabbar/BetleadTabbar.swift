//
//  BetleadTabbar.swift
//  betlead
//
//  Created by Andy Chen on 2019/5/23.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

enum MenuType: Int {
    case system
    case service
    case info
    case vip
    case sponsor
    var title: String {
        switch self {
        case .info:
            return "關於"
        case .system:
            return "助手"
        case .service:
            return "客服"
        case .vip:
            return "VIP"
        case .sponsor:
            return "贊助"
        }
    }
    var urlStr: String {
        switch self {
        case .info:
            return "https://mstage.betlead.com/forApp/about"
        case .service:
            return ""
        case .system:
            return "https://mstage.betlead.com/forApp/faq"
        default:
            return ""
        }
    }
    
}
class BetleadTabbar:UIView {
    @IBOutlet weak var mainPageStackView:UIStackView!
    @IBOutlet weak var promoteStackView:UIStackView!
    @IBOutlet weak var moneyStackView:UIStackView!
    @IBOutlet weak var myPageStackView:UIStackView!
    
    @IBOutlet weak var mainPageLabel:UILabel!
    @IBOutlet weak var promoteLabel:UILabel!
    @IBOutlet weak var moneyPageLabel:UILabel!
    @IBOutlet weak var myPageLabel:UILabel!
    
    @IBOutlet weak var mainPageIcon:UIImageView!
    @IBOutlet weak var promoteIcon:UIImageView!
    @IBOutlet weak var moneyIcon:UIImageView!
    @IBOutlet weak var myPageIcon:UIImageView!
    private lazy var icons = [mainPageIcon,promoteIcon,moneyIcon,myPageIcon]
    private lazy var labels = [mainPageLabel,promoteLabel,moneyPageLabel,myPageLabel]
    @IBOutlet weak var backgroundView:UIImageView!
    @IBOutlet weak var bottomConstraints: NSLayoutConstraint!
    
    let rxItemClick = PublishSubject<Int>()
    let rxMenuClick = PublishSubject<MenuType>()
    
//    var fanMenu: FanMenu!
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        bindStackView()
        bottomConstraints.constant =  Views.bottomOffset
        backgroundView.image = Views.isIPhoneWithNotch() ? UIImage(named: "tabbar-bg") : UIImage(named: "tabbar-bg-short")
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 35
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.3
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        backgroundView.roundCorner(corners: [.topLeft, .topRight], radius: 20)
        backgroundView.clipsToBounds = true
    }
    
    func selected(_ index:Int ){
        rxItemClick.onNext(index)
        guard index != 2 ,
        UserStatus.share.isLogin || index < 2 else {return}
        icons.forEach({$0?.image = $0?.image?.blendedByColor(.white)})
        icons[index]?.image = icons[index]?.image?.blendedByColor(Themes.secondaryYellow)
        labels.forEach({$0?.textColor = .white})
        labels[index]?.textColor = Themes.secondaryYellow
        
        
    }
    
//    func setupFanMenu() {
//        let mainSize: CGFloat = 64
//        let mainBtnStyle = MainStyle(size: mainSize,
//                                        imageName: "tabbar-betlead",
//                                        selectedImageName: "icon-fanmenu-main-selected",
//                                        backgroundColor: UIColor(red: 1,
//                                                                 green: 1,
//                                                                 blue: 1,
//                                                                 alpha: 0.3))
//
//        let menus = [MenuStyle(imageName: "icon-fanmenu-1",
//                               backgroundColor: nil,
//                               title: "助手"),
//                     MenuStyle(imageName: "icon-fanmenu-2",
//                               backgroundColor: nil,
//                               title: "客服"),
//                     MenuStyle(imageName: "icon-fanmenu-3",
//                               backgroundColor: nil,
//                               title: "关于")]
//        let openArea:(CGFloat,CGFloat) = (220,320)
//
//
//        fanMenu = FanMenu(mainStyle: mainBtnStyle,
//                          menuButtons: menus,
//                          shape: .circle,
//                          interval: openArea)
//        bindFanMenu()
//
//        if let superView = superview {
//            superView.addSubview(fanMenu)
//            fanMenu.snp.makeConstraints { (maker) in
//                maker.centerX.equalToSuperview()
//                maker.bottom.equalToSuperview().offset(Views.isIPhoneWithNotch() ? -34.0 : -6.0)
//                maker.size.equalTo(CGSize(width: mainSize, height: mainSize) )
//            }
//        }
//    }
    
    func bringToFront(){
        superview?.bringSubviewToFront(self)
//        superview?.bringSubviewToFront(fanMenu)
    }
//    private func bindFanMenu() {
//        fanMenu.rxClick()
//            .subscribe { [weak self] (event) in
//                guard let type = MenuType(rawValue: event.element!) else { return }
//                self?.rxMenuClick.onNext(type)
//            }.disposed(by: disposeBag)
//    }
    
    private func bindStackView(){
        let mainTap = UITapGestureRecognizer()
        mainPageStackView.addGestureRecognizer(mainTap)
        mainTap.rx.event.subscribe(onNext: {[weak self] (_) in
            guard let weakSelf = self else {return}
            weakSelf.selected(0)
        }).disposed(by: disposeBag)
        
        let promoteTap = UITapGestureRecognizer()
        promoteStackView.addGestureRecognizer(promoteTap)
        promoteTap.rx.event.subscribe(onNext: {[weak self] (_) in
            guard let weakSelf = self else {return}
            weakSelf.selected(1)
        }).disposed(by: disposeBag)
        
        let moneyTap = UITapGestureRecognizer()
        moneyStackView.addGestureRecognizer(moneyTap)
        moneyTap.rx.event.subscribe(onNext: {[weak self] (_) in
            guard let weakSelf = self  else { return }
            weakSelf.selected(2)
        }).disposed(by: disposeBag)
        
        let myPageTap = UITapGestureRecognizer()
        myPageStackView.addGestureRecognizer(myPageTap)
        myPageTap.rx.event.subscribe(onNext: {[weak self] (_) in
            guard let weakSelf = self else {return}
            weakSelf.selected(3)
        }).disposed(by: disposeBag)
    }
    
    
    
}


extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
