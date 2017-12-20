//
//  MLRefreshAutoNormalFooter.swift
//  Pro_YYJapDicFile_swift
//
//  Created by Mrlu-bjhl on 2016/12/2.
//  Copyright © 2016年 www.Mrlu.com. All rights reserved.
//

import UIKit

class MLRefreshAutoNormalFooter: MLRefreshAutoStateFooter {
    
    var activityIndicatorViewStyle:UIActivityIndicatorViewStyle = .gray {
        didSet {
            self.loadingView = nil
            setNeedsLayout()
        }
    }
    
    private var _loadingView:UIActivityIndicatorView?
    
    var loadingView:UIActivityIndicatorView? {
        set {
            _loadingView = newValue
        }
        get {
            if _loadingView == nil {
                _loadingView = UIActivityIndicatorView(activityIndicatorStyle: self.activityIndicatorViewStyle)
                _loadingView!.hidesWhenStopped = true
                addSubview(_loadingView!)
            }
            return _loadingView
        }
    }
    
    lazy var arrowView:UIImageView = {
        let arrowView = UIImageView(image: UIImage(named: "ml_arrow"))
        addSubview(arrowView)
        return arrowView
    }()

    override func prepare() {
        super.prepare()
        activityIndicatorViewStyle = .gray
    }
    
    override func placeSubViews() {
        super.placeSubViews()
        if let loadingView = self.loadingView, loadingView.constraints.count > 0 { return }
        var loadingCenterX = self.ml_w * 0.5
        if self.refreshingTitleHidden {
            loadingCenterX -= self.stateLabel.mj_textWidth() * 0.5 + self.labelLeftInset
        }
        let loadingCenterY = self.ml_h * 0.5;
        
        self.loadingView?.center = CGPoint(x: loadingCenterX, y: loadingCenterY);
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
            
            // 根据状态做事情
            if (state == .noMoreData || state == .normal) {
                self.loadingView?.stopAnimating()
            } else if (state == .refreshing) {
                self.loadingView?.startAnimating()
            }
        }
    }
    
}
