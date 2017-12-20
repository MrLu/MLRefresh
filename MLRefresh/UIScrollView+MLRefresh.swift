//
//  UIScrollView+MLRefresh.swift
//  Pro_YYJapDicFile_swift
//
//  Created by Mrlu-bjhl on 2016/11/30.
//  Copyright © 2016年 www.Mrlu.com. All rights reserved.
//

import UIKit

extension NSObject {
    class func exchangeInstance(from menthod1:Selector, to menthod2:Selector) {
        method_exchangeImplementations(class_getInstanceMethod(self, menthod1)!, class_getInstanceMethod(self, menthod2)!)
    }
    
    class func exchangeClass(from menthod1:Selector, to menthod2:Selector) {
        method_exchangeImplementations(class_getClassMethod(self, menthod1)!, class_getClassMethod(self, menthod2)!)
    }
}

//UIScrollView+MLRefresh

extension UIScrollView {
    
    fileprivate struct mlrefresh_associatedKeys {
        static var pullToRefreshView = "pullToRefreshViewKey"
        static var infiniteScrollView = "infiniteScrollViewKey"
        static var reloadDataBlock = "ReloadDataBlockKey"
    }
    
    var ml_header:MLRefreshHeader? {
        set {
            ml_header?.removeFromSuperview()
            if newValue != nil {
                insertSubview(newValue!, at: 0)
            }
            willChangeValue(forKey: "ml_header")
            objc_setAssociatedObject(self, &mlrefresh_associatedKeys.pullToRefreshView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            didChangeValue(forKey: "ml_header")
        }
        get {
            return objc_getAssociatedObject(self, &mlrefresh_associatedKeys.pullToRefreshView) as? MLRefreshHeader
        }
    }
    
    var ml_footer:MLRefreshFooter? {
        set {
            ml_footer?.removeFromSuperview()
            if newValue != nil {
                insertSubview(newValue!, at: 0)
            }
            willChangeValue(forKey: "ml_footer")
            objc_setAssociatedObject(self, &mlrefresh_associatedKeys.infiniteScrollView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            didChangeValue(forKey: "ml_footer")
        }
        get {
            return objc_getAssociatedObject(self, &mlrefresh_associatedKeys.infiniteScrollView) as? MLRefreshFooter
        }
    }
    
    func ml_totalDataCount() -> Int {
        
        var totalCount = 0
        
        if self.isKind(of: UITableView.self) {
            let tableView = self as! UITableView
            
            for section in 0 ..< tableView.numberOfSections {
                totalCount += tableView.numberOfRows(inSection: section)
            }
        } else if self.isKind(of: UICollectionView.self) {
            let collectionView = self as! UICollectionView
            
            for section in 0 ..< collectionView.numberOfSections {
                totalCount += collectionView.numberOfItems(inSection: section)
            }
        }
        
        return totalCount
    }
    
    var ml_reloadDataBlock:((Int)->Void)? {
        set {
            willChangeValue(forKey: "mj_reloadDataBlock")
            objc_setAssociatedObject(self, &mlrefresh_associatedKeys.reloadDataBlock, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            didChangeValue(forKey: "mj_reloadDataBlock")
        }
        get {
            return objc_getAssociatedObject(self, &mlrefresh_associatedKeys.reloadDataBlock) as? ((Int) -> Void)
        }
    }
    
    @discardableResult
    func ml_reloadDataBlock(closure:((Int)->Void)?) -> Self {
        self.ml_reloadDataBlock = closure
        return self
    }
    
    func executeReloadDataBlock() {
        self.ml_reloadDataBlock?(self.ml_totalDataCount())
    }
}

extension UITableView {
    @objc
    func ml_reloadData() {
        self.ml_reloadData()
        self.executeReloadDataBlock()
    }
}

extension UICollectionView {
    @objc
    func ml_reloadData() {
        self.ml_reloadData()
        self.executeReloadDataBlock()
    }
}

extension UIScrollView {
    
    var ml_inset:UIEdgeInsets {
        get {
            if #available(iOS 11.0, *) {
                return self.adjustedContentInset;
            } else {
                return self.contentInset;
            }
        }
    }
    
    var ml_insetT:CGFloat {
        set{
            var inset = contentInset
            inset.top = newValue
            if #available(iOS 11.0, *) {
                inset.top -= (adjustedContentInset.top - contentInset.top);
            }
            contentInset = inset
        }
        get{
            return ml_inset.top
        }
    }
    
    var ml_insetB:CGFloat {
        set{
            var inset = contentInset
            inset.bottom = newValue
            if #available(iOS 11.0, *) {
                inset.bottom -= (adjustedContentInset.bottom - contentInset.bottom);
            }
            contentInset = inset
        }
        get{
            return ml_inset.bottom
        }
    }
    
    var ml_insetL:CGFloat {
        set{
            var inset = contentInset
            inset.left = newValue
            if #available(iOS 11.0, *) {
                inset.left -= (adjustedContentInset.left - contentInset.left);
            }
            contentInset = inset
        }
        get{
            return ml_inset.left
        }
    }
    
    var ml_insetR:CGFloat {
        set{
            var inset = contentInset
            inset.right = newValue
            if #available(iOS 11.0, *) {
                inset.right -= (adjustedContentInset.right - contentInset.right);
            }
            contentInset = inset
        }
        get{
            return ml_inset.right
        }
    }
    
    var ml_offsetX:CGFloat {
        set{
            var offset = contentOffset
            offset.x = newValue
            contentOffset = offset
        }
        get{
            return contentOffset.x
        }
    }
    
    var ml_offsetY:CGFloat {
        set{
            var offset = contentOffset
            offset.y = newValue
            contentOffset = offset
        }
        get{
            return contentOffset.y
        }
    }
    
    var ml_contentW:CGFloat {
        set{
            var size = contentSize
            size.width = newValue
            contentSize = size
        }
        get{
            return contentSize.width
        }
    }
    
    var ml_contentH:CGFloat {
        set{
            var size = contentSize
            size.height = newValue
            contentSize = size
        }
        get{
            return contentSize.height
        }
    }
}

extension UIView {
    var ml_x:CGFloat {
        set{
            var f = frame
            f.origin.x = newValue
            frame = f
        }
        get{
            return frame.origin.x
        }
    }
    
    var ml_y:CGFloat {
        set{
            var f = frame
            f.origin.y = newValue
            frame = f
        }
        get{
            return frame.origin.y
        }
    }
    
    var ml_origin:CGPoint {
        set{
            var f = frame
            f.origin = newValue
            frame = f
        }
        get{
            return frame.origin
        }
    }
    
    var ml_w:CGFloat {
        set{
            var f = frame
            f.size.width = newValue
            frame = f
        }
        get{
            return frame.size.width
        }
    }
    
    var ml_h:CGFloat {
        set{
            var f = frame
            f.size.height = newValue
            frame = f
        }
        get{
            return frame.size.height
        }
    }
    
    var ml_size:CGSize {
        set{
            var f = frame
            f.size = newValue
            frame = f
        }
        get{
            return frame.size
        }
    }

}
