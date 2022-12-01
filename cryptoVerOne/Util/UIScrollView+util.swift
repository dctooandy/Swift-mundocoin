//
//  UIScrollView+util.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/12/1.
//

import Foundation
extension UIScrollView {
    func getLongImage() -> UIImage? {
        let scale = UIScreen.main.scale
        let oldFrame = self.layer.frame
        let size = self.contentSize
        let savedContentOffet = self.contentOffset
        self.contentOffset = .zero
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        //这里需要你修改下layer的frame,不然只会截出在屏幕显示的部分
        self.layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.contentOffset = savedContentOffet
        self.layer.frame = oldFrame
        return screenshot
    }
    var captrue: UIImage? {
        var image:UIImage? = nil
        UIGraphicsBeginImageContext(self.contentSize)
        do {
            let scale = UIScreen.main.scale
            let oldFrame = self.layer.frame
            let size = self.contentSize
            let savedContentOffet = self.contentOffset
            self.contentOffset = .zero
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            
            self.layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            image = UIGraphicsGetImageFromCurrentImageContext()
            self.contentOffset = savedContentOffet
            self.layer.frame = oldFrame
        }
        UIGraphicsEndImageContext()
        if image != nil
        {
            return image
        }
        return nil
    }
}
