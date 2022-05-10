//
//  UserMenuViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/9.
//

import Foundation
import RxCocoa
import RxSwift

class UserMenuViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
   
    @IBOutlet weak var rightArrowImage: UIImageView!
    private lazy var backBtn:UIButton = {
        let btn = UIButton(type: .custom)
        let image = UIImage(named:"back")?.reSizeImage(reSize: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        btn.setTitle("", for:.normal)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "User Menu"
        setupUI()
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
    func setupUI()
    {
        let image = UIImage(named:"back")?.reSizeImage(reSize: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
        rightArrowImage.image = image
        rightArrowImage.tintColor = .black
        rightArrowImage.transform = rightArrowImage.transform.rotated(by: .pi)
    }
}
// MARK: -
// MARK: 延伸
