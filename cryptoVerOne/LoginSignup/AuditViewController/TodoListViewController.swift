//
//  TodoListViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/6/12.
//

import Foundation
import RxCocoa
import RxSwift
import Parchment
enum AuditShowMode
{
    case pending
    case finished
}
class TodoListViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var currentShowMode: AuditShowMode = .pending {
        didSet{
            subPageVC.reloadPageMenu(currentMode: currentShowMode)            
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var backImageView: UIImageView!
    let logoImage : UIImageView = {
        let image = UIImageView(image: UIImage(named: "mundoLogo"))
        return image
    }()
    fileprivate let subPageVC = SubListPageViewController()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "ToDoList"
        naviBackBtn.isHidden = true
        self.navigationItem.titleView = logoImage

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSubPageVC()
        setupNavigation()
        currentShowMode = .pending
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    // MARK: -
    // MARK:業務方法
    func setupNavigation()
    {
        let bar = self.navigationController?.navigationBar
        bar?.isTranslucent = true
        bar?.backgroundColor = .lightGray
    }
    private func setupSubPageVC() {
        addChild(subPageVC)
        view.insertSubview(subPageVC.view, aboveSubview: backImageView)
        let naviBarHeight = self.navigationController?.navigationBar.frame.maxY ?? Views.topOffset + Views.topOffset
        subPageVC.view.snp.makeConstraints({ (make) in
            make.top.equalToSuperview().offset(naviBarHeight)
            make.left.bottom.right.equalToSuperview()
        })
    }
}
// MARK: -
// MARK: 延伸

