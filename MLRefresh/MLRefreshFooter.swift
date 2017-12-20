//
//  MLRefreshFootView.swift
//  Pro_YYJapDicFile_swift
//
//  Created by Mrlu-bjhl on 2016/11/30.
//  Copyright © 2016年 www.Mrlu.com. All rights reserved.
//

import UIKit

class MLRefreshFooter: MLRefreshComponent {
    var ignoredScrollViewContentInsertBottom:CGFloat = 0.0
    
    private static let doOneTime: Void = {
        UITableView.exchangeInstance(from: #selector(UITableView.reloadData), to: #selector(UITableView.ml_reloadData))
        UICollectionView.exchangeInstance(from: #selector(UICollectionView.reloadData), to: #selector(UICollectionView.ml_reloadData))
    }()
    
    var automaticallyHidden:Bool = false {
        didSet {
            if automaticallyHidden {
                MLRefreshFooter.doOneTime
            }
        }
    }
    
    var lastUpdatedTimeKey:String = "MLRefreshHeaderLastUpdatedTimeKey"
    var lastUpdatedData:NSDate? {
        get{
            return UserDefaults.standard.object(forKey:lastUpdatedTimeKey) as? NSDate
        }
    }
    var insertDelta:CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func footer(withRefreshingBlock refreshingBlock:@escaping MLRefreshComponentRefreshingBlock) -> MLRefreshFooter {
        let footer = self.init()
        footer.refreshingBlock = refreshingBlock;
        return footer
    }
    
    override func prepare() {
        super.prepare()
        ml_h = MLRefreshConst.footerHeight
        // 默认不会自动隐藏
        self.automaticallyHidden = false
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let scrollView = self.scrollView,( scrollView.isKind(of: UITableView.self) || scrollView.isKind(of: UICollectionView.self)) {
            scrollView.ml_reloadDataBlock(closure: { (totalDataCount) in
                if self.automaticallyHidden {
                    self.isHidden = (totalDataCount == 0)
                }
            })
        }
    }
    
    //MARK - 公共方法
    func endRefreshingWithNoMoreData() -> Void {
        DispatchQueue.main.async {
            self.state = .noMoreData;
        }
    }
    
    func resetNoMoreData() -> Void {
        DispatchQueue.main.async {
            self.state = .normal;
        }
    }
}
