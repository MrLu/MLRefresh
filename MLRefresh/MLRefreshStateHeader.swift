//
//  MLRefreshStateHeader.swift
//  Pro_YYJapDicFile_swift
//
//  Created by Mrlu-bjhl on 2016/11/30.
//  Copyright © 2016年 www.Mrlu.com. All rights reserved.
//

import UIKit

class MLRefreshStateHeader: MLRefreshHeader {

    var labelLeftInset:CGFloat = MLRefreshConst.labelLeftInset

    lazy var stateLabel:UILabel = {
        var label = UILabel.mj_label()
        self.addSubview(label)
        return label
    }()
    
    lazy var lastUpdatedTimeLabel:UILabel = {
        let label = UILabel.mj_label()
        self.addSubview(label)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var stateTitles:[MLRefreshState:String] = [MLRefreshState:String]()
    
    var lastUpdatedTimeText:((_ lastUpdatedTime:Date) -> String)?
    
    func set(_ title:String?, forState aState:MLRefreshState) -> Void {
        if title == nil { return }
        self.stateTitles[aState] = title
        self.stateLabel.text = self.stateTitles[state]
    }
    
    override func prepare() {
        super.prepare()
        labelLeftInset = MLRefreshConst.labelLeftInset
        set("下拉可以刷新", forState: .normal)
        set("松开立即刷新", forState: .pulling)
        set("正在刷新数据中...", forState: .refreshing)
    }
    
    override func placeSubViews() {
        super.placeSubViews()
        if stateLabel.isHidden {return}
        let noConstrainsOnStatusLabel = stateLabel.constraints.count == 0
        if lastUpdatedTimeLabel.isHidden {
            if noConstrainsOnStatusLabel {
                stateLabel.frame = self.bounds
            }
        } else {
            let stateLabelH = self.ml_h * 0.5
            if noConstrainsOnStatusLabel {
                stateLabel.ml_x = 0
                stateLabel.ml_y = 0
                stateLabel.ml_w = self.ml_w
                stateLabel.ml_h = stateLabelH
            }
            
            if (lastUpdatedTimeLabel.constraints.count == 0) {
                lastUpdatedTimeLabel.ml_x = 0
                lastUpdatedTimeLabel.ml_y = stateLabelH
                lastUpdatedTimeLabel.ml_w = self.ml_w
                lastUpdatedTimeLabel.ml_h = self.ml_h - self.lastUpdatedTimeLabel.ml_y
            }
        }
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
            
            stateLabel.text = stateTitles[newValue]
            
            let temp = self.lastUpdatedTimeKey
            lastUpdatedTimeKey = temp
        }
    }
    
    //MARK: 日历获取在9.x之后的系统使用currentCalendar会出异常。在8.0之后使用系统新API。
    func currentCalendar() -> Calendar? {
        if NSCalendar.responds(to: #selector(NSCalendar.init(calendarIdentifier:))) {
            return Calendar(identifier: Calendar.Identifier.gregorian)
        }
        return Calendar.current
    }
    
    override var lastUpdatedTimeKey: String {
        didSet {
            if lastUpdatedTimeLabel.isHidden {return}
            
            let lastUpdatedTime = UserDefaults.standard.object(forKey: lastUpdatedTimeKey) as? Date
            
            if let _ = lastUpdatedTimeText, let _ = lastUpdatedTime {
                lastUpdatedTimeLabel.text = self.lastUpdatedTimeText?(lastUpdatedTime!)
                return
            }
            
            if let _ = lastUpdatedTime {
                let calendar = currentCalendar()

                let comp1 = calendar?.dateComponents([.year,.month,.day,.hour,.minute], from: lastUpdatedTime!)
                let comp2 = calendar?.dateComponents([.year,.month,.day,.hour,.minute], from: Date())
                
                let formatter = DateFormatter()
                var isToday = false
                
                if comp1?.day == comp2?.day {
                    formatter.dateFormat = " HH:mm"
                    isToday = true
                } else if comp1?.year == comp2?.year {
                    formatter.dateFormat = "MM-dd HH:mm"
                } else {
                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                }
                let time = formatter.string(from: lastUpdatedTime!)
                lastUpdatedTimeLabel.text = "最后更新:" + (isToday ? "今天" : "") + time
            } else {
                lastUpdatedTimeLabel.text = "最后更新:" + "无记录"
            }
        }
    }
}
