//
//  HYViewController.h
//  Test
//
//  Created by MrChen on 2018/3/8.
//  Copyright © 2018年 MrChen. All rights reserved.
//

/**
 * 功能: 设置导航栏上的按钮和标题
 */

#import <UIKit/UIKit.h>

typedef void (^CallBackBlock)(void);
@interface HYViewController : UIViewController
/**
 *  导航栏标题
 */
@property (nonatomic, copy) NSString *navTitle;
@property (nonatomic, strong) UILabel *titleView;

/**
 *  返回按钮标题/图片
 */
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, copy) NSString *backTitle;
@property (nonatomic, strong) UIImage *backImg;

/**
 *  右边按钮的标题/图片
 */
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, copy) NSString *rightTitle;
@property (nonatomic, strong) UIImage *rightImg;

/*
 * 右边多个按钮
 */
@property (nonatomic, strong) NSArray *rightImages;
@property (nonatomic, copy) void (^rightClick)(NSInteger index);

/**
 *  左/右按钮点击时间回调
 */
@property (nonatomic, copy) CallBackBlock leftCallBlock;
@property (nonatomic, copy) CallBackBlock rightCallBlock;

// 返回按钮点击方法
- (void)leftBtnClick;

@end
