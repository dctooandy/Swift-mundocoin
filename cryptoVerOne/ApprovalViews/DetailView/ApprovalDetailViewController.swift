//
//  ApprovalDetailViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 6/9/22.
//

import Foundation
import RxCocoa
import RxSwift

class ApprovalDetailViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    static let share: ApprovalDetailViewController = ApprovalDetailViewController.loadNib()
    var dataDto : AddressBookDto!
    // MARK: -
    // MARK:UI 設定
    
    @IBOutlet weak var okView: UIView!
    @IBOutlet weak var cancelView: UIView!
    var cancelBtn: CancelButton = CancelButton()
    var okBtn: CornerradiusButton = CornerradiusButton()
    @IBOutlet weak var topLabal: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var textView: UITextView!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        textView.isEditable = false
        textView.isSelectable = false
        view.backgroundColor = Themes.grayE0E5F2
        okBtn.setTitle("Approve".localized, for: .normal)
        okBtn.titleLabel?.font = Fonts.pingFangTCRegular(16)
        okBtn.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        okBtn.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        self.okView.addSubview(okBtn)
        okBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        cancelBtn.setTitle("Deny".localized, for: .normal)
        self.cancelView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    func configData(data:AddressBookDto)
    {
        self.dataDto = data
        topLabal.text = data.name
        textView.text = data.address
    }
    
}
// MARK: -
// MARK: 延伸
