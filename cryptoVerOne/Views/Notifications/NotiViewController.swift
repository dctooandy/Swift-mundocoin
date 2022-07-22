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
    var notiData:[NotificationDto] = []
    
    @IBOutlet weak var deleteViewBottomConstraint: NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteButton: CornerradiusButton!
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
        btn.setTitleColor(Themes.gray2B3674, for: .normal)
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
        setupUI()
        bindButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
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
        tableView.tableFooterView = nil
        tableView.registerXibCell(type: AddressBookViewCell.self)
        tableView.separatorStyle = .none
        tableView.backgroundView = NoDataView(image: UIImage(named: "empty-notofications"), title: "No Notifications Yet" , subTitle: "You have no notifications right now. Come back later")
        tableView.backgroundView?.isHidden = true
        
        deleteButton.setTitle("Delete".localized, for: .normal)
        deleteButton.titleLabel?.font = Fonts.PlusJakartaSansRegular(16)
    }
    func bindButton()
    {
        deleteButton.rx.tap
            .subscribeSuccess { [weak self] in
                Log.v("點擊刪除")
            }.disposed(by: dpg)
    }
    func setData(dtos:[NotificationDto])
    {
        self.notiData = dtos
        tableView.backgroundView?.isHidden = dtos.count > 0 ? true : false
        editBarBtn.isHidden = dtos.count > 0 ? false : true
    }
    @objc func editNotiAction()
    {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: selectBarBtn)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelBarBtn)
        deleteViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func cancelEditAction()
    {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editBarBtn)
        deleteViewBottomConstraint.constant = -114
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func selectAllAction()
    {
        Log.v("選擇全部")
    }
}
// MARK: -
// MARK: 延伸
extension NotiViewController:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notiData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: AddressBookViewCell.self, indexPath: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 98
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}
