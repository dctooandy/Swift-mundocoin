//
//  PersonalInfoViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/11.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

class PersonalInfoViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    static let share: PersonalInfoViewController = PersonalInfoViewController.loadNib()
    private var textIsEditing:Bool = false
    @IBOutlet weak var topTextWidthConstraint: NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var tableView: UITableView!
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var editNameImageView: UIImageView!
    @IBOutlet weak var saveNameImageView: UIImageView!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Personal info".localized
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        setupUI()
        bindUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
        textIsEditing = false
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
        tableView.registerXibCell(type: UserMenuTableViewCell.self)
        tableView.separatorStyle = .none
        if let nickName = MemberAccountDto.share?.nickName
        {
            Log.i("nickName:\(nickName)")
            userNameTextField.text = nickName
        }
        calculateTextWidth()
    }
    func calculateTextWidth()
    {
        if let testString = userNameTextField.text
        {
            let textWidth = testString.width(withConstrainedHeight: 20, font:  Fonts.PlusJakartaSansMedium(17))
            topTextWidthConstraint.constant = textWidth + 10
        }
    }
    func bindUI()
    {
        editNameImageView.rx.click.subscribeSuccess { [self] _ in
            if textIsEditing == false
            {
                turnOnImageView(editFlag: true)
                userNameTextField.isUserInteractionEnabled = true
                userNameTextField.becomeFirstResponder()
            }
        }.disposed(by: dpg)
        saveNameImageView.rx.click.subscribeSuccess { [self] _ in
            if textIsEditing == true
            {
                turnOnImageView(editFlag: false)
                userNameTextField.resignFirstResponder()
                userNameTextField.isUserInteractionEnabled = false
                calculateTextWidth()
            }
        }.disposed(by: dpg)
    }
    func turnOnImageView(editFlag:Bool)
    {
        UIView.animate(withDuration: 0.3) {
            if editFlag == true
            {
                self.editNameImageView.alpha = 0.0
                self.saveNameImageView.alpha = 1.0
                self.textIsEditing = true
            }else
            {
                self.editNameImageView.alpha = 1.0
                self.saveNameImageView.alpha = 0.0
                self.textIsEditing = false
            }
        }
    }
}
// MARK: -
// MARK: 延伸
extension PersonalInfoViewController:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueCell(type: UserMenuTableViewCell.self, indexPath: indexPath)
        switch indexPath.row {
        case 0:
            cell.cellData = .registrationInfo
        case 1:
            cell.cellData = .email
        case 2:
            cell.cellData = .mobile
        case 3:
            cell.cellData = .memberSince
        default:
            break
        }
            return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.dequeueCell(type: UserMenuTableViewCell.self, indexPath: indexPath)
        let cell = tableView.cellForRow(at: indexPath) as! UserMenuTableViewCell
        switch indexPath.row {
        case 0:
            Log.i("registrationInfo")
        //registrationInfo
        case 1:
            Log.i("email")
            if cell.cellData.arrowHidden == false
            {
                let authVC = AuthenticationViewController.loadNib()
                authVC.authenInputViewMode = .email(withStar: false)
                self.navigationController?.pushViewController(authVC, animated: true)
            }
        case 2:
            Log.i("mobile")
            if cell.cellData.arrowHidden == false
            {
                let authVC = AuthenticationViewController.loadNib()
                authVC.authenInputViewMode = .phone(withStar: false)
                self.navigationController?.pushViewController(authVC, animated: true)
            }
        case 3:
            Log.i("memberSince")
        //memberSince
        default:
            break
        }
      
//        guard let presentingVC = presentingViewController else {return}
//        DispatchQueue.main.async {
//            self.dismiss(animated: true) {
//                NewsDetailBottomSheet(newsDto: self.newsDtos[indexPath.row]).start(viewController: presentingVC)
//            }
//        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
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
extension PersonalInfoViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var returnTag = true
        guard let text = textField.text else {
            calculateTextWidth()
            return returnTag
        }
        if string == ""
        {
            calculateTextWidth()
            return returnTag
        }
        var textNumber = 0
        var stringNumber = 0
        for char in text.unicodeScalars{
            if char.isASCII{
                textNumber += 1
            }else
            {
                textNumber += 2
            }
        }
        for char in string.unicodeScalars{
            if char.isASCII{
                stringNumber += 1
            }else
            {
                stringNumber += 2
            }
        }
        if textNumber >= 20 {
            returnTag = false
        }else if textNumber + stringNumber >= 20
        {
            returnTag = false
        }
        calculateTextWidth()
        return returnTag
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textIsEditing
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        turnOnImageView(editFlag: false)
        MemberAccountDto.share?.nickName = textField.text ?? ""
        calculateTextWidth()
    }
}
