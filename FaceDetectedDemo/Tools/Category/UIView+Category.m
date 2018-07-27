//
//  UIView+Category.m
//  Deppon
//
//  Created by MrChen on 2017/12/7.
//  Copyright © 2017年 MrChen. All rights reserved.
//

#import "UIView+Category.h"

@implementation UIView (Category)
#pragma mark - frame相关
- (void)setViewX:(CGFloat)viewX
{
    CGRect frame = self.frame;
    frame.origin.x = viewX;
    self.frame = frame;
}

- (CGFloat)viewX
{
    return self.frame.origin.x;
}

- (void)setViewY:(CGFloat)viewY
{
    CGRect frame = self.frame;
    frame.origin.y = viewY;
    self.frame = frame;
}

- (CGFloat)viewY
{
    return self.frame.origin.y;
}

- (void)setViewMaxX:(CGFloat)viewMaxX
{
    CGRect frame = self.frame;
    frame.origin.x = viewMaxX - frame.size.width;
    self.frame = frame;
}

- (CGFloat)viewMaxX
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setViewMaxY:(CGFloat)viewMaxY
{
    CGRect frame = self.frame;
    frame.origin.y = viewMaxY - frame.size.height;
    self.frame = frame;
}

- (CGFloat)viewMaxY
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setViewWidth:(CGFloat)viewWidth
{
    CGRect frame = self.frame;
    frame.size.width = viewWidth;
    self.frame = frame;
}

- (CGFloat)viewWidth
{
    return self.frame.size.width;
}

- (void)setViewHeight:(CGFloat)viewHeight
{
    CGRect frame = self.frame;
    frame.size.height = viewHeight;
    self.frame = frame;
}

- (CGFloat)viewHeight
{
    return self.frame.size.height;
}

- (void)setViewSize:(CGSize)viewSize
{
    CGRect frame = self.frame;
    frame.size = viewSize;
    self.frame = frame;
}

- (CGSize)viewSize
{
    return self.frame.size;
}

- (void)setViewOrigin:(CGPoint)viewOrigin
{
    CGRect frame = self.frame;
    frame.origin = viewOrigin;
    self.frame = frame;
}

- (CGPoint)viewOrigin
{
    return self.frame.origin;
}

- (void)setViewCenterX:(CGFloat)viewCenterX
{
    CGPoint center = self.center;
    center.x = viewCenterX;
    self.center = center;
}

- (CGFloat)viewCenterX
{
    return self.center.x;
}

- (void)setViewCenterY:(CGFloat)viewCenterY
{
    CGPoint center = self.center;
    center.y = viewCenterY;
    self.center = center;
}

- (CGFloat)viewCenterY
{
    return self.center.y;
}

#pragma mark - IB
- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setBorderColor:(UIColor *)borderColor{
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth{
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)cornerRadius{
    return self.layer.cornerRadius;
}

- (UIColor *)borderColor{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (CGFloat)borderWidth{
    return self.layer.borderWidth;
}

#pragma mark - 设置背景色渐变
/**
 * 设置view背景色渐变
 * colors 渐变色
 * fromPoint 起始位置
 * toPoint 终点位置
 * 注: (0,0)~(1,0) 水平方向渐变,(0,0)~(0,1)垂直方向渐变
 */
- (void)backGroundColorGraded:(NSArray <UIColor *>*)colors fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    // 设置颜色渐变
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    NSMutableArray *colorsM = [NSMutableArray array];
    for (UIColor *col in colors) {
        CGColorRef transColor = col.CGColor;
        [colorsM addObject:((__bridge id)transColor)];
    }
    gradientLayer.colors = colorsM;
    
    //位置x,y    自己根据需求进行设置   使其从不同位置进行渐变
    gradientLayer.startPoint = fromPoint;
    gradientLayer.endPoint = toPoint;
    gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.layer addSublayer:gradientLayer];
}

#pragma mark - 获取当前View的控制器对象
/** 获取当前View的控制器对象 */
- (UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

#pragma mark - 显示系统提示框
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
+ (void)showAlert:(BOOL)alert title:(NSString *)title message:(NSString *)msg btnTitles:(NSArray *)btnTitles actions:(NSArray *)actions showCtr:(UIViewController *)showCtr presentComplete:(void (^)(void))presentComplete
{
    UIAlertControllerStyle style = alert ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet;
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:style];
    
    for (NSString *btnTitle in btnTitles) {
        NSInteger index = [btnTitles indexOfObject:btnTitle];
        void (^btnAction)(void) = nil;
        if (actions.count > index) {
            btnAction = actions[index];
        }
        
        [alertCtr addAction:[UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (btnAction) {
                btnAction();
            }
        }]];
    }
    
    if (!alert) {
        [alertCtr addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    }
    
    if (!showCtr) {
        showCtr = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    [showCtr presentViewController:alertCtr animated:YES completion:presentComplete];
}

@end
