//
//  MLRefreshAutoFooter.swift
//  Pro_YYJapDicFile_swift
//
//  Created by Mrlu-bjhl on 2016/12/2.
//  Copyright © 2016年 www.Mrlu.com. All rights reserved.
//

import UIKit

class MLRefreshAutoFooter: MLRefreshFooter {
    var automaticallyRefresh:Bool = true
    var triggerAutomaticallyRefreshPercent:CGFloat = 1
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil {
            if self.isHidden == false {
                scrollView?.ml_insetB += ml_h
            }
            // 设置位置
            ml_y = scrollView!.ml_contentH
        } else {
            if isHidden == false {
                scrollView!.ml_insetB -= ml_h
            }
        }
    }
    
    override func prepare() {
        super.prepare()
        // 默认底部控件100%出现时才会自动刷新
        triggerAutomaticallyRefreshPercent = 1.0
        
        // 设置为默认状态
        automaticallyRefresh = true
    }
    
    override func scrollViewContentOffSetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffSetDidChange(change: change)
        if (self.state != .normal || !automaticallyRefresh || ml_y == 0) {return}
        
        if (scrollView!.ml_insetT + scrollView!.ml_contentH > scrollView!.ml_h) { // 内容超过一个屏幕
            // 这里的_scrollView.mj_contentH替换掉self.mj_y更为合理
            if (scrollView!.ml_offsetY >= scrollView!.ml_contentH - scrollView!.ml_h + ml_h * self.triggerAutomaticallyRefreshPercent + scrollView!.ml_insetB - self.ml_h) {
                // 防止手松开时连续调用
                let old = change?[NSKeyValueChangeKey.oldKey] as! CGPoint;
                let new = change?[NSKeyValueChangeKey.newKey] as! CGPoint;
                if (new.y <= old.y) {return}
                
                // 当底部刷新控件完全出现时，才刷新
                beginRefreshing()
            }
        }
    }
    
    override func scrollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change: change)
        // 设置位置
        ml_y = scrollView!.ml_contentH
    }
    
    override func scrollViewPanStateDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewPanStateDidChange(change: change)
        if (state != .normal) {return}
        if (scrollView!.panGestureRecognizer.state == .ended) {// 手松开
            if (scrollView!.ml_insetT + scrollView!.ml_contentH <= scrollView!.ml_h) {  // 不够一个屏幕
                if (scrollView!.ml_offsetY >= -scrollView!.ml_insetT) { // 向上拽
                    beginRefreshing()
                }
            } else { // 超出一个屏幕
                if (scrollView!.ml_offsetY >= scrollView!.ml_contentH + scrollView!.ml_insetB - scrollView!.ml_h) {
                    beginRefreshing()
                }
            }
        }
    }
    
    override var state: MLRefreshState {
        get {return super.state}
        set {
            let oldValue:MLRefreshState = state
            if newValue == oldValue {
                return
            }
            super.state = newValue
            if (newValue == .refreshing) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.25, execute: { 
                    self.executeRefreshingCallBlock()
                })
            } else if (newValue == .noMoreData || newValue == .normal) {
                if (oldValue == .refreshing) {
                    if (endRefreshBlock != nil) {
                        endRefreshBlock!()
                    }
                }
            }
        }
    }
    
    override var isHidden: Bool {
        didSet{
            if (!oldValue && isHidden) {
                self.state = .normal;
                scrollView!.ml_insetB -= self.ml_h;
            } else if (oldValue && !isHidden) {
                scrollView!.ml_insetB += ml_h;
                // 设置位置
                ml_y = scrollView!.ml_contentH;
            }
        }
    }

}
