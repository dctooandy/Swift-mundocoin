//
//  NotiViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/9.
//

import Foundation
import RxCocoa
import RxSwift

class NotiViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    private lazy var editBarBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-icedit")
        btn.addTarget(self, action:#selector(editNotiAction), for:.touchUpInside)
        return btn
    }()
    private lazy var cancelBarBtn:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Cancel".localized, for: .normal)
        btn.setTitleColor(Themes.blue6149F6, for: .normal)
        btn.addTarget(self, action:#selector(cancelEditAction), for:.touchUpInside)
        return btn
    }()
    private lazy var selectBarBtn:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Select All".localized, for: .normal)
        btn.setTitleColor(Themes.blue2B3674, for: .normal)
        btn.addTarget(self, action:#selector(selectAllAction), for:.touchUpInside)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editBarBtn)
        view.backgroundColor = Themes.grayF4F7FE
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
    @objc func editNotiAction()
    {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: selectBarBtn)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelBarBtn)
    }
    @objc func cancelEditAction()
    {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editBarBtn)
    }
    @objc func selectAllAction()
    {
        Log.v("選擇全部")
    }
}
// MARK: -
// MARK: 延伸
