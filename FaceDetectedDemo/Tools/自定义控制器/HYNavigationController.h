//
//  HYNavigationController.h
//  Test
//
//  Created by MrChen on 2018/3/8.
//  Copyright © 2018年 MrChen. All rights reserved.
//

/**
 * 功能:
 * 1.支持全屏右滑返回上个控制器
 * 2.支持隐藏指定控制器的导航栏
 * 3.对原生导航栏操作
 */

#import <UIKit/UIKit.h>

@interface HYNavigationController : UINavigationController

// 是否支持全屏右滑返回
@property (nonatomic,assign) BOOL canDragBack;

// 需要隐藏导航栏的控制器类名集合
@property (nonatomic, copy) NSArray <NSString *>*naviBarHiddenControllers;

// 去掉导航栏下面的默认线条
- (void)removeNavBarBottomLine;

@end
