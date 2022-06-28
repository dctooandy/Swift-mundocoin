//
//  CheckBoxView.swift
//  betlead
//
//  Created by Victor on 2019/5/28.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
enum CheckViewType
{
    case defaultType
    case checkType
    case invalidType
}
class CheckBoxView: UIControl {
    // MARK:業務設定
    let disposeBag = DisposeBag()
    var checkType :CheckViewType = .checkType {
        didSet{
            resetUIByType(type: checkType)
        }
    }
    private let checkPassed = PublishSubject<Bool>()
    // MARK: -
    // MARK:UI 設定
    private var iconImageView : UIImageView!
    private var title: String? = nil
    
    private var font: UIFont = UIFont.systemFont(ofSize: 20)
    
    private var titleColor: UIColor = .red
    
    private var checkBoxSize: CGFloat = 15.0
    
    private var checkBox: CheckBox?
    
    private var checkBoxColor: UIColor = .black
    
    var isCheck: Bool {
        get {
            return self.checkBox?.isCheck ?? false
        }
    }
    // MARK: -
    // MARK:Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        resetUIByType(type: .checkType)
        bindUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
        resetUIByType(type: .checkType)
        bindUI()
    }
    
    func rxCheckBoxPassed() -> Observable<Bool> {
        return checkPassed.asObserver()
    }
    init(title: String? = nil,
         font: UIFont = UIFont.systemFont(ofSize: 15),
         titleColor: UIColor = .blue,
         checkBoxSize: CGFloat = 15,
         checkBoxColor: UIColor = .blue) {
        super.init(frame: .zero)
        self.title = title
        self.font = font
        self.titleColor = titleColor
        self.checkBoxSize = checkBoxSize
        self.checkBoxColor = checkBoxColor
        setupViews()
    }
    init(type:CheckViewType = .defaultType) {
        super.init(frame: .zero)
        setupUI()
        resetUIByType(type: .checkType)
        bindUI()
    }
    func setupUI()
    {
        iconImageView = UIImageView(image: UIImage(named: "icon-checkbox"))
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.edges.equalToSuperview()
        }
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }
    func resetUIByType(type:CheckViewType)
    {
        switch type {
        case .defaultType:
            backgroundColor = .white
            layer.borderWidth = 2
            layer.borderColor = Themes.grayE0E5F2.cgColor
        case .checkType:
            backgroundColor = Themes.purple6149F6
            layer.borderWidth = 2
            layer.borderColor = Themes.purple6149F6.cgColor
        case .invalidType:
            backgroundColor = .white
            layer.borderWidth = 2
            layer.borderColor = Themes.redEE5D50.cgColor
        }

    }
    func bindUI()
    {
        iconImageView.rx.click.subscribeSuccess { (_) in
            self.isSelected = !self.isSelected
            self.checkType = (self.isSelected ? .checkType: . defaultType)
//            self.checkPassed.onNext(self.isSelected)
            
            print("check \(self.isSelected ? "選":"不選")")
        }.disposed(by: disposeBag)
    }
    
    
    func setupViews() {
        checkBox = CheckBox(boxColor: checkBoxColor ,borderColor: checkBoxColor,alwaysShowTick: false)
        checkBox?.layer.cornerRadius = checkBoxSize / 4
        checkBox?.clipsToBounds = true
        checkBox?.isUserInteractionEnabled = true
        addSubview(checkBox!)
        checkBox?.snp.makeConstraints({ (make) in
            make.width.height.equalTo(checkBoxSize)
            make.left.centerY.equalToSuperview()
        })
        
        checkBox?.rx.click
            .subscribeSuccess { (_) in
                self.isSelected = !self.isSelected
                self.checkPassed.onNext(self.isSelected)
                print("check \(self.isSelected ? "選":"不選")")
            }.disposed(by: disposeBag)
        
        if title != nil {
            let label = UILabel()
            label.text = title!
            label.font = font
            label.textColor = titleColor
            label.numberOfLines = 0
            addSubview(label)
            label.snp.makeConstraints { (make) in
                make.left.equalTo(checkBox!.snp.right).offset(8)
                make.top.bottom.right.equalToSuperview()
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            checkBox?.isCheck = self.isSelected
            self.checkPassed.onNext(self.isSelected)
        }
    }
    
}
