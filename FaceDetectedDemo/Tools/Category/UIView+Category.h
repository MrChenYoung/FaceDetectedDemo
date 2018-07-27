//
//  UIView+Category.h
//  Deppon
//
//  Created by MrChen on 2017/12/7.
//  Copyright © 2017年 MrChen. All rights reserved.
//

/**
 * 功能列表
 * 1> 直接获取/设置view的frame相关属性
 * 2> 直接获取/设置view的layer属性
 * 3> 给view设置渐变背景色
 * 4> 获取view的当前控制器
 */

#import <UIKit/UIKit.h>

@interface UIView (Category)

#pragma mark - frame相关
@property (assign, nonatomic) CGFloat viewX;
@property (assign, nonatomic) CGFloat viewY;
@property (assign, nonatomic) CGFloat viewMaxX;
@property (assign, nonatomic) CGFloat viewMaxY;
@property (assign, nonatomic) CGFloat viewWidth;
@property (assign, nonatomic) CGFloat viewHeight;
@property (assign, nonatomic) CGSize viewSize;
@property (assign, nonatomic) CGPoint viewOrigin;
@property (nonatomic, assign) CGFloat viewCenterX;
@property (nonatomic, assign) CGFloat viewCenterY;

#pragma mark - IB
@property (nonatomic, assign) IB_DESIGNABLE CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable UIColor *borderColor;

#pragma mark - 设置背景色渐变
/**
 * 设置view背景色渐变
 * colors 渐变色
 * fromPoint 起始位置
 * toPoint 终点位置
 * 注: (0,0)~(1,0) 水平方向渐变,(0,0)~(0,1)垂直方向渐变
 */
- (void)backGroundColorGraded:(NSArray <UIColor *>*)colors fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

#pragma mark - 获取当前View的控制器对象
/**
 * 获取当前View的控制器对象
 */
-(UIViewController *)getCurrentViewController;


#pragma mark - 展示提示框
/**
 * 展示提示框
 * alert            是alert还是actionSheet
 * title            标题
 * msg              提示信息
 * btnTitles        按钮标题集合
 * actions          按钮事件集合
 * showCtr          要在哪个控制器内显示(传空在主控制器内展示)
 * presentComplete  展示完成回调
 */
+ (void)showAlert:(BOOL)alert title:(NSString *)title message:(NSString *)msg btnTitles:(NSArray *)btnTitles actions:(NSArray *)actions showCtr:(UIViewController *)showCtr presentComplete:(void (^)(void))presentComplete;

@end
