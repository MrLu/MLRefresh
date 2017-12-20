//
//  MLRefreshNormalHeader.swift
//  Pro_YYJapDicFile_swift
//
//  Created by Mrlu-bjhl on 2016/11/30.
//  Copyright © 2016年 www.Mrlu.com. All rights reserved.
//

import UIKit

class MLRefreshNormalHeader: MLRefreshStateHeader {
    
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
        // 箭头的中心点
        var arrowCenterX = self.ml_w * 0.5;
        if (!self.stateLabel.isHidden) {
            let stateWidth = self.stateLabel.mj_textWidth();
            var timeWidth:CGFloat = 0.0;
            if (!self.lastUpdatedTimeLabel.isHidden) {
                timeWidth = self.lastUpdatedTimeLabel.mj_textWidth();
            }
            let textWidth = max(stateWidth, timeWidth);
            arrowCenterX -= textWidth / 2 + self.labelLeftInset;
        }
        let arrowCenterY = self.ml_h * 0.5;
        let arrowCenter = CGPoint(x:arrowCenterX, y:arrowCenterY)
        
        // 箭头
        if (self.arrowView.constraints.count == 0) {
            self.arrowView.ml_size = self.arrowView.image?.size ?? CGSize.zero;
            self.arrowView.center = arrowCenter;
        }
        
        // 圈圈
        if let loadingView = self.loadingView, loadingView.constraints.count == 0 {
            self.loadingView?.center = arrowCenter;
        }
        
        self.arrowView.tintColor = self.stateLabel.textColor;
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
            
            if state == .normal {
                if oldValue == .refreshing {
                    arrowView.transform = CGAffineTransform.identity
                    
                    UIView.animate(withDuration: MLRefreshConst.slowAnimationDuration, animations: {
                        self.loadingView?.alpha = 0
                    }, completion: { (finished) in
                        // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                        if self.state != .normal { return }
                        
                        self.loadingView?.alpha = 1.0
                        self.loadingView?.stopAnimating()
                        self.arrowView.isHidden = false
                    })
                } else {
                    loadingView?.stopAnimating()
                    arrowView.isHidden = false
                    UIView.animate(withDuration: MLRefreshConst.fastAnimationDuration, animations: {
                        self.arrowView.transform = CGAffineTransform.identity
                    })
                }
                
            } else if state == .pulling {
                loadingView?.stopAnimating()
                arrowView.isHidden = false
                UIView.animate(withDuration: MLRefreshConst.fastAnimationDuration, animations: {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: CGFloat(0.000001 - Double.pi))
                })
            } else if state == .refreshing {
                loadingView?.alpha = 1.0
                loadingView?.startAnimating()
                arrowView.isHidden = true
            }
        }
    }
}
