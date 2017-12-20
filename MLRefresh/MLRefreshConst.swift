//
//  MLRefreshConst.swift
//  Pro_YYJapDicFile_swift
//
//  Created by Mrlu-bjhl on 2016/11/30.
//  Copyright © 2016年 www.Mrlu.com. All rights reserved.
//

import UIKit

struct MLRefreshConst {
    static let labelLeftInset:CGFloat = 25;
    static let headerHeight:CGFloat = 54.0;
    static let footerHeight:CGFloat = 44.0;
    static let fastAnimationDuration:TimeInterval = 0.25;
    static let slowAnimationDuration:TimeInterval = 0.4;
    
    static let keyPathContentOffset:NSString = "contentOffset";
    static let keyPathContentInset:NSString = "contentInset";
    static let keyPathContentSize:NSString = "contentSize";
    static let keyPathPanState:NSString = "state";
    
    static let headerLastUpdatedTimeKey:NSString = "MJRefreshHeaderLastUpdatedTimeKey";
    
    static let headerIdleText:NSString = "MJRefreshHeaderIdleText";
    static let headerPullingText:NSString = "MJRefreshHeaderPullingText";
    static let headerRefreshingText:NSString = "MJRefreshHeaderRefreshingText";
    
    static let autoFooterIdleText:NSString = "MJRefreshAutoFooterIdleText";
    static let autoFooterRefreshingText:NSString = "MJRefreshAutoFooterRefreshingText";
    static let autoFooterNoMoreDataText:NSString = "MJRefreshAutoFooterNoMoreDataText";
    
    static let backFooterIdleText:NSString = "MJRefreshBackFooterIdleText";
    static let backFooterPullingText:NSString = "MJRefreshBackFooterPullingText";
    static let backFooterRefreshingText:NSString = "MJRefreshBackFooterRefreshingText";
    static let backFooterNoMoreDataText:NSString = "MJRefreshBackFooterNoMoreDataText";
    
    static let headerLastTimeText:NSString = "MJRefreshHeaderLastTimeText";
    static let headerDateTodayText:NSString = "MJRefreshHeaderDateTodayText";
    static let headerNoneLastDateText:NSString = "MJRefreshHeaderNoneLastDateText";
}
