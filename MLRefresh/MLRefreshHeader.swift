//
//  MLRefreshHeadView.swift
//  Pro_YYJapDicFile_swift
//
//  Created by Mrlu-bjhl on 2016/11/30.
//  Copyright © 2016年 www.Mrlu.com. All rights reserved.
//

import UIKit

class MLRefreshHeader: MLRefreshComponent {
    
    var ignoredScrollViewContentInsertTop:CGFloat = 0.0
    var lastUpdatedTimeKey:String = "MLRefreshHeaderLastUpdatedTimeKey"
    var lastUpdatedData:NSDate? {
        get{
            return UserDefaults.standard.object(forKey:lastUpdatedTimeKey) as? NSDate
        }
    }
    var insertDelta:CGFloat = 0
    
    class func header(withRefreshingBlock refreshingBlock:@escaping MLRefreshComponentRefreshingBlock) -> MLRefreshHeader {
        let header = self.init()
        header.refreshingBlock = refreshingBlock;
        return header
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepare() {
        super.prepare()
        ml_h = MLRefreshConst.headerHeight
    }
    
    override func placeSubViews() {
        super.placeSubViews()
        ml_y = -ml_h - ignoredScrollViewContentInsertTop
    }
    
    override func scrollViewContentOffSetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffSetDidChange(change: change)
        if (self.state == .refreshing) {
//            if window == nil {return}
            var insetT = (-scrollView!.ml_offsetY) > scrollViewOriginalInset.top ? (-scrollView!.ml_offsetY) : scrollViewOriginalInset.top
            insetT = insetT > ml_h + scrollViewOriginalInset.top ? ml_h + scrollViewOriginalInset.top : insetT
            scrollView?.ml_insetT = insetT
            insertDelta = scrollViewOriginalInset.top - insetT
            return;
        }
        
        scrollViewOriginalInset = scrollView!.ml_inset
        
        let offsetY = scrollView!.ml_offsetY
        let happenOffsetY = -scrollViewOriginalInset.top
        
        if (offsetY > happenOffsetY) {return}
        
        // 普通 和 即将刷新 的临界点
        let normal2pullingOffsetY = happenOffsetY - ml_h;
        let pullingPercent = (happenOffsetY - offsetY) / ml_h;
        
        if (scrollView!.isDragging) { // 如果正在拖拽
            self.pullingPercent = pullingPercent;
            if (state == .normal && offsetY < normal2pullingOffsetY) {
                // 转为即将刷新状态
                state = .pulling;
            }
            else if (state == .pulling && offsetY >= normal2pullingOffsetY) {
                // 转为普通状态
                state = .normal;
            }
        } else if (state == .pulling) {// 即将刷新 && 手松开
            // 开始刷新
            beginRefreshing()
            
        } else if (pullingPercent < 1) {
            self.pullingPercent = pullingPercent;
        }
    }
    
    override var state: MLRefreshState {
        set{
            let oldValue:MLRefreshState = state
            if newValue == oldValue {
                return
            }
            super.state = newValue
            if newValue == .normal {
                if oldValue != .refreshing { return }
                UserDefaults.standard.set(NSDate(), forKey: lastUpdatedTimeKey)
                UserDefaults.standard.synchronize()
                UIView.animate(withDuration: 0.4, animations: {
                    self.scrollView?.ml_insetT += self.insertDelta;
                    if (self.isAutomaticallyChangeAlpha) {self.alpha = 0.0 }
                }, completion: { (finished) in
                    self.pullingPercent = 0.0
                    self.endRefreshBlock?()
                } );
            } else if (newValue == .refreshing) {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.25, animations: { 
                        let top = self.scrollViewOriginalInset.top + self.ml_h;
                        // 增加滚动区域top
                        self.scrollView!.ml_insetT = top
                        // 设置滚动位置
                        var offset = self.scrollView!.contentOffset
                        offset.y = -top;
                        self.scrollView?.setContentOffset(offset, animated: false)
                    }, completion: { (finished) in
                        self.executeRefreshingCallBlock()
                    })
                }
            }
        }
        get {
            return super.state
        }
    }
    
    override func scrollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change: change)
    }
    
    override func scrollViewPanStateDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewPanStateDidChange(change: change)
    }
}
