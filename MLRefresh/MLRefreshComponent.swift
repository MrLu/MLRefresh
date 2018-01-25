//
//  MLRefreshComponent.swift
//  Pro_YYJapDicFile_swift
//
//  Created by Mrlu-bjhl on 2016/11/30.
//  Copyright © 2016年 www.Mrlu.com. All rights reserved.
//

import UIKit

public typealias MLRefreshComponentRefreshingBlock = () -> Void
public typealias MJRefreshComponentBeginRefreshingCompletionBlock = () -> Void
public typealias MJRefreshComponentEndRefreshingCompletionBlock = () -> Void

enum MLRefreshState {
    case normal
    case pulling
    case refreshing
    case willRefreshing
    case noMoreData
}

protocol MLRefreshComponentProtol {
    func prepare() -> Void
    func placeSubViews() -> Void
    func scrollViewContentOffSetDidChange(change:[NSKeyValueChangeKey:Any]?) -> Void
    func scrollViewContentSizeDidChange(change:[NSKeyValueChangeKey:Any]?) -> Void
    func scrollViewPanStateDidChange(change:[NSKeyValueChangeKey:Any]?) -> Void
}

class MLRefreshComponent: UIView {
    
    var refreshingBlock:MLRefreshComponentRefreshingBlock?
    var beginRefreshBlock:MJRefreshComponentBeginRefreshingCompletionBlock?
    var endRefreshBlock:MJRefreshComponentEndRefreshingCompletionBlock?
    var _state:MLRefreshState = .normal
    var _isRefreshing: Bool = false
    var isRefreshing : Bool {
        get{
            return (self.state == .refreshing || self.state == .willRefreshing)
        }
        set{
            _isRefreshing = newValue;
        }
    }
    
    var state:MLRefreshState {
        get{
            return _state
        }
        set{
            _state = newValue;
            DispatchQueue.main.async { [weak self] in
                self?.setNeedsLayout()
            }
        }
    }
    
    var scrollView:UIScrollView?
    var scrollViewOriginalInset:UIEdgeInsets = UIEdgeInsets.zero
    var pullingPercent:CGFloat = 0.0
    var isAutomaticallyChangeAlpha:Bool = false
    
    private var pan:UIGestureRecognizer?
    
    deinit {
        removeObserver()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard let _ = newSuperview, newSuperview!.isKind(of: UIScrollView.self) else {
            return
        }
        
        removeObserver()
    
        if newSuperview != nil {
            scrollView = newSuperview as? UIScrollView
            scrollView?.alwaysBounceVertical = true
            
            // 设置宽度
            self.ml_w = newSuperview!.ml_w;
            // 设置位置
            self.ml_x = -scrollView!.ml_insetL;
            
            if scrollView != nil {
                scrollViewOriginalInset = self.scrollView!.ml_inset
            }
            
            addObservers()
        }
    }
    
    override func layoutSubviews() {
        placeSubViews()
        super.layoutSubviews()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if state == .willRefreshing {
            state = .refreshing
        }
    }

    //MARK - 属性监听
    func addObservers() -> Void {
        if scrollView != nil {
            scrollView!.addObserver(self, forKeyPath: "contentOffset", options: [.new,.old], context: nil)
            scrollView!.addObserver(self, forKeyPath: "contentSize", options: [.new, .old], context: nil)
            pan = scrollView?.panGestureRecognizer;
            pan?.addObserver(self, forKeyPath: "state", options: [.new,.old], context: nil)
        }
    }
    
    func removeObserver() -> Void {
        if scrollView != nil {
            scrollView!.removeObserver(self, forKeyPath: "contentOffset")
            scrollView!.removeObserver(self, forKeyPath: "contentSize")
            if pan != nil {
                pan!.removeObserver(self, forKeyPath: "state")
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // 遇到这些情况就直接返回
        if !isUserInteractionEnabled { return }
        
        // 这个就算看不见也需要处理
        if keyPath == "contentSize" {
            scrollViewContentSizeDidChange(change: change)
        }
        
        // 看不见
        if (isHidden) {return}
        
        if keyPath == "contentOffset" {
            scrollViewContentOffSetDidChange(change: change)
        } else if keyPath == "state" {
            scrollViewPanStateDidChange(change: change)
        }
    }
    
    func executeRefreshingCallBlock() -> Void {
        DispatchQueue.main.async {  [weak self] in
            self?.refreshingBlock?();
            self?.beginRefreshBlock?();
        }
    }
    
    public func beginRefreshing() -> Void {
        UIView.animate(withDuration: 0.25, animations: {
           [weak self] in
            self?.alpha = 1.0
        })
        pullingPercent = 1.0
        
        if (window != nil) {
            state = .refreshing;
        } else {
            if state != .refreshing {
                state = .willRefreshing
                setNeedsDisplay()
            }
        }
    }
    
    public func beginRefreshing(completionBlock:@escaping MJRefreshComponentBeginRefreshingCompletionBlock) -> Void {
        beginRefreshBlock = completionBlock
        beginRefreshing()
    }
    
    public func endRefreshing() -> Void {
        DispatchQueue.main.async {
            self.state = .normal
        }
    }
    
    public func endRefreshing(completionBlock:@escaping MJRefreshComponentEndRefreshingCompletionBlock) ->Void {
        endRefreshBlock = completionBlock
        endRefreshing()
    }
    //MARK -- 子类继承重写
    func prepare() {
        autoresizingMask = .flexibleWidth
        backgroundColor = UIColor.clear
    }
    
    func placeSubViews() {
        
    }
    
    func scrollViewContentOffSetDidChange(change: [NSKeyValueChangeKey : Any]?) {
 
    }
    
    func scrollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        
    }
    
    func scrollViewPanStateDidChange(change: [NSKeyValueChangeKey : Any]?) {
        
    }
}

extension UILabel {
    class func mj_label() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 90/256.0, green: 90/256.0, blue: 90/256.0, alpha: 1)
        label.autoresizingMask = .flexibleWidth
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        return label
    }
    
    func mj_textWidth() -> CGFloat {
        var stringWidth:CGFloat = 0;
        let size = CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT))
        if text != nil {
            if ((text! as NSString).length > 0) {
                stringWidth = (text! as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:font], context: nil).size.width
            }
        }
        return stringWidth
    }
}
