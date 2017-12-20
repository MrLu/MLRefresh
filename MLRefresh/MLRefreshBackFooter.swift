//
//  MLRefreshBackFooter.swift
//  SuperLearn_toelf
//
//  Created by Mrlu on 04/12/2017.
//  Copyright © 2017 xdf. All rights reserved.
//

import UIKit

class MLRefreshBackFooter: MLRefreshFooter {

    private var lastRefreshCount:Int = 0
    private var lastBottomDelta:CGFloat = 0
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        scrollViewContentSizeDidChange(change: nil)
    }
    
    override func scrollViewContentOffSetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffSetDidChange(change: change)
        
        if state != .refreshing { return }
        
        scrollViewOriginalInset = scrollView!.ml_inset
        // 当前的contentOffset
        let currentOffsetY = scrollView!.ml_offsetY
        // 尾部控件刚好出现的offsetY
        let happenOffsetY = self.happenOffsetY()
        // 如果是向下滚动到看不见尾部控件，直接返回
        if currentOffsetY <= happenOffsetY  { return }
        
        let pullingPercent = currentOffsetY - happenOffsetY / self.ml_h
        // 如果已全部加载，仅设置pullingPercent，然后返回
        if state == .noMoreData {
            self.pullingPercent = pullingPercent
            return
        }
        
        if scrollView!.isDragging {
            self.pullingPercent = pullingPercent
            // 普通 和 即将刷新 的临界点
            let normal2pullingOffsetY =  happenOffsetY + self.ml_h
            
            if state == .normal && currentOffsetY > normal2pullingOffsetY {
                // 转为即将刷新状态
                state = .pulling
            } else if state == .pulling && currentOffsetY <= normal2pullingOffsetY{
                // 转为普通状态
                state = .normal
            }
        } else if state == .pulling {
            // 开始刷新
            beginRefreshing()
        } else if pullingPercent < 1 {
            self.pullingPercent = pullingPercent
        }
    }
    
    override func scrollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change: change)
        let contentHeight = scrollView!.ml_contentH + ignoredScrollViewContentInsertBottom
        
        let scrollheight = scrollView!.ml_h - scrollViewOriginalInset.top - scrollViewOriginalInset.bottom + ignoredScrollViewContentInsertBottom
        // 设置位置
        self.ml_y = max(contentHeight, scrollheight)
    }
    
    override var state: MLRefreshState {
        get {return super.state}
        set {
            let oldValue:MLRefreshState = state
            if newValue == oldValue {
                return
            }
            super.state = newValue
            
            if newValue == .noMoreData || newValue == .normal {
                if (.refreshing == oldValue) {
                    UIView.animate(withDuration: MLRefreshConst.slowAnimationDuration, animations: {
                        self.scrollView?.ml_insetB -= self.lastBottomDelta
                        // 自动调整透明度
                        if self.isAutomaticallyChangeAlpha {
                            self.alpha = 0.0
                        }
                    },  completion: { (finished) in
                        self.pullingPercent = 0.0
                        self.endRefreshBlock?()
                    })
                }
                
                let deltaH = self.heightForContentBreakView()
                
                if .refreshing == oldValue && deltaH > 0 && scrollView!.ml_totalDataCount() != lastRefreshCount {
                    scrollView!.ml_offsetY = scrollView!.ml_offsetY
                }
            } else if (newValue == .refreshing) {
                lastRefreshCount = scrollView!.ml_totalDataCount()
                
                UIView.animate(withDuration: MLRefreshConst.fastAnimationDuration, animations: {
                    var bottom = self.ml_h + self.scrollViewOriginalInset.bottom
                    let deltaH = self.heightForContentBreakView()
                    if deltaH < 0 {
                        bottom -= deltaH
                    }
                    self.lastBottomDelta = bottom - self.scrollView!.ml_insetB
                    self.scrollView?.ml_insetB = bottom
                    self.scrollView?.ml_offsetY = self.happenOffsetY() + self.ml_h
                }, completion: { (finished) in
                    self.executeRefreshingCallBlock()
                })
            }
        }
    }
    
    //MARK: - Private
    //MARK: 获得scrollView的内容 超出 view 的高度
    func heightForContentBreakView() -> CGFloat {
        let h = scrollView!.frame.height - scrollViewOriginalInset.bottom - scrollViewOriginalInset.top
        return scrollView!.contentSize.height - h
    }
    
    func happenOffsetY() -> CGFloat {
        let deltaH = heightForContentBreakView()
        if (deltaH > 0) {
            return deltaH - scrollViewOriginalInset.top;
        }
        return -scrollViewOriginalInset.top;
    }
}
