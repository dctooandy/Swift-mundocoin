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

class CheckBoxView: UIControl {
    let disposeBag = DisposeBag()
    private var title: String? = nil
    
    private var font: UIFont = UIFont.systemFont(ofSize: 20)
    
    private var titleColor: UIColor = .red
    
    private var checkBoxSize: CGFloat = 15.0
    
    private var checkBox: CheckBox?
    
    private var checkBoxColor: UIColor = .black
    private let accountCheckPassed = BehaviorSubject(value: false)
    var isCheck: Bool {
        get {
            return self.checkBox?.isCheck ?? false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func rxCheckBoxPassed() -> Observable<Bool> {
        return accountCheckPassed.asObserver()
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
                self.accountCheckPassed.onNext(self.isSelected)
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
            self.accountCheckPassed.onNext(self.isSelected)
        }
    }
    
}
