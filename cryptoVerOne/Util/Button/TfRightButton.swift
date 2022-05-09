//
//  TfRightButton.swift
//  betlead
//
//  Created by Victor on 2019/6/21.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit

class TfRightButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func setImageTitle(image: UIImage?, title: String?) {
        setImage(image, for: .normal)
        setTitle(title, for: .normal)
        setTitleColor(Themes.primaryBase, for: .normal)
    }
    
    func setImage(_ image: UIImage?) {
        setImage(image, for: .normal)
    }
}
