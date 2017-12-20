//
//  MLRefreshAutoStateFooter.swift
//  Pro_YYJapDicFile_swift
//
//  Created by Mrlu-bjhl on 2016/12/2.
//  Copyright © 2016年 www.Mrlu.com. All rights reserved.
//

import UIKit

class MLRefreshAutoStateFooter: MLRefreshAutoFooter{
    var labelLeftInset:CGFloat = 25
    lazy var stateLabel:UILabel = {
        var label = UILabel.mj_label()
        self.addSubview(label)
        return label
    }()
    var refreshingTitleHidden:Bool = false
    var stateTitles:[MLRefreshState:String] = [MLRefreshState:String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ title:String, forState state:MLRefreshState) -> Void {
        stateTitles[state] = title
        stateLabel.text = title
    }
    
    @objc func stateLabelClick() -> Void {
        if state == .normal {
            beginRefreshing()
        }
    }
    
    override func prepare() {
        super.prepare()
        set("点击或上拉加载更多", forState: .normal)
        set("正在加载更多的数据...", forState: .refreshing)
        set("已经全部加载完毕", forState: .noMoreData)
        stateLabel.isUserInteractionEnabled = true
        stateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stateLabelClick)))
    }
    
    override func placeSubViews() {
        super.placeSubViews()
        if stateLabel.constraints.count > 0 {return}
        stateLabel.frame = bounds
    }
    
    override var state: MLRefreshState {
        get {
            return super.state
        }
        set {
            let oldValue:MLRefreshState = state
            if newValue == oldValue {
                return
            }
            super.state = newValue
            
            if (refreshingTitleHidden && state == .refreshing) {
                stateLabel.text = nil
            } else {
                stateLabel.text = stateTitles[state]
            }
        }
    }

}
