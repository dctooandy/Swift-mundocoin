//
//  UIStackView+util.swift
//  betlead
//
//  Created by Victor on 2019/6/5.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit

extension UIStackView {
    
    func addBackground(color: UIColor, cornerRadius: CGFloat = 18) {
        let backgroungView = UIView(frame: bounds)
        backgroungView.backgroundColor = color
        backgroungView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroungView.layer.cornerRadius = cornerRadius
        backgroungView.clipsToBounds = true
        insertSubview(backgroungView, at: 0)
    }
    
}
