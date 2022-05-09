//
//  UICollectionView+util.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/9.
//


import Foundation
import UIKit

extension UICollectionView {
    func dequeueCell<T>(type:T.Type, indexPath:IndexPath) -> T {
        let cell = self.dequeueReusableCell(withReuseIdentifier:NSStringFromClass(type as! AnyClass),
                                            for:indexPath) as! T
        return cell
    }
    
    func dequeueHeader<T>(type:T.Type, indexPath:IndexPath) -> T {
        let header = self.dequeueReusableSupplementaryView(ofKind:UICollectionView.elementKindSectionHeader,
                                                           withReuseIdentifier:NSStringFromClass(type as! AnyClass), for:indexPath) as! T
        return header
    }
    
    func dequeueFooter<T>(type:T.Type, indexPath:IndexPath) -> T {
        let footer = self.dequeueReusableSupplementaryView(ofKind:UICollectionView.elementKindSectionFooter,
                                                           withReuseIdentifier:NSStringFromClass(type as! AnyClass), for:indexPath) as! T
        return footer
    }
    
    func registerCell(type:AnyClass) {
        self.register(type, forCellWithReuseIdentifier:NSStringFromClass(type))
    }
    
    func registerXibCell(type:AnyClass) {
        self.register(UINib(nibName: "\(type)", bundle: nil), forCellWithReuseIdentifier: NSStringFromClass(type))
    }
    
    func registerHeader(type:AnyClass) {
        self.register(type,
                      forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier:NSStringFromClass(type))
    }
    func registerXibHeader(type:AnyClass) {
        self.register(UINib(nibName: "\(type)", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(type))
    
    }
    
    func registerFooter(type:AnyClass) {
        self.register(type,
                      forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter,
                      withReuseIdentifier:NSStringFromClass(type))
    }
    func registerXibFooter(type:AnyClass) {
          self.register(UINib(nibName: "\(type)", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(type))
    }
    
    
    func pagingInCenter(_ scrollView:UIScrollView,
                        targetContentOffset:UnsafeMutablePointer<CGPoint>,
                        cellWidth:CGFloat,
                        itemSpacing:CGFloat,
                        leftEdgeInset:CGFloat) {
        let pageWidth:Float = Float(cellWidth + itemSpacing)
        // width + space
        let currentOffset:Float = Float(scrollView.contentOffset.x)
        let targetOffset:Float = Float(targetContentOffset.pointee.x)
        var newTargetOffset:Float = 0
        if targetOffset > currentOffset {
            newTargetOffset = ceilf(targetOffset / pageWidth) * pageWidth
        } else if (targetOffset == currentOffset) {
            newTargetOffset = roundf(targetOffset / pageWidth) * pageWidth
        } else {
            newTargetOffset = floorf(targetOffset / pageWidth) * pageWidth
        }
        if newTargetOffset < 0 {
            newTargetOffset = 0
        } else if (newTargetOffset > Float(scrollView.contentSize.width)) {
            newTargetOffset = Float(Float(scrollView.contentSize.width))
        }
        
        let leftGap = Float((UIScreen.main.bounds.width - cellWidth) / 2 - leftEdgeInset)
        targetContentOffset.pointee.x = CGFloat(newTargetOffset - leftGap)
    }
    
}
