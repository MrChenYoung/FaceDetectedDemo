//
//  HYViewController.m
//  Test
//
//  Created by MrChen on 2018/3/8.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import "HYViewController.h"

@interface HYViewController ()

@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *rightItem;

@end

@implementation HYViewController
#pragma mark - 懒加载

#pragma mark - 原始方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.backImg = [UIImage imageNamed:@"back"];
}

#pragma mark - 导航栏标题
// 标题
- (UILabel *)titleView
{
    if (_titleView == nil) {
        _titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 12, 44)];
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.font = [UIFont systemFontOfSize:18];
        _titleView.textColor = [UIColor whiteColor];
    }
    return _titleView;
}

- (void)setNavTitle:(NSString *)navTitle
{
    self.titleView.text = navTitle;
    self.navigationItem.titleView = self.titleView;
}

#pragma mark - 返回按钮
- (UIButton *)backBtn
{
    if (_backBtn == nil) {
        _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 32)];
        [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_backBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

// 设置返回按钮图片
- (void)setBackImg:(UIImage *)backImg
{
    self.navigationItem.leftBarButtonItem = self.backItem;
    
    UIImageView *backArrowImgV = (UIImageView *)[self.backBtn viewWithTag:2000];
    if (!backArrowImgV) {
        CGFloat w = 20;
        CGFloat h = 20;
        CGFloat x = 0;
        CGFloat y = (CGRectGetHeight(self.backBtn.frame) - h) * 0.5;
        backArrowImgV = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, w, h)];
        backArrowImgV.tag = 2000;
        [self.backBtn addSubview:backArrowImgV];
    }
    backArrowImgV.image = backImg;
}

// 设置返回按钮标题
- (void)setBackTitle:(NSString *)backTitle
{
    self.backImg = nil;
    NSDictionary *attributes = @{NSFontAttributeName:self.backBtn.titleLabel.font};
    CGFloat width = [backTitle boundingRectWithSize:CGSizeMake(320, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
    self.backBtn.frame = CGRectMake(10, 0, width, 16);
    [self.backBtn setTitle:backTitle forState:UIControlStateNormal];
    [self.backBtn setTitle:backTitle forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = self.backItem;
}

// 返回按钮item
- (UIBarButtonItem *)backItem
{
    // 创建返回按钮
    if (_backImg == nil) {
        _backItem = [[UIBarButtonItem alloc]initWithCustomView:self.backBtn];
    }
    return _backItem;
}

#pragma mark - 右边按钮
// rightItem
- (UIBarButtonItem *)rightItem
{
    // 创建rightItem按钮
    if (_rightItem == nil) {
        _rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightBtn];
    }
    
    return _rightItem;
}

// 右边按钮
- (UIButton *)rightBtn
{
    if (_rightBtn == nil) {
        _rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 32)];
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

// 设置右边图片
- (void)setRightImg:(UIImage *)rightImg
{
    self.navigationItem.rightBarButtonItem = self.rightItem;
    UIButton *btn = (UIButton *)self.rightItem.customView;
    UIImageView *backArrowImgV = (UIImageView *)[btn viewWithTag:3000];
    if (!backArrowImgV) {
        CGFloat w = 20;
        CGFloat h = 20;
        CGFloat x = CGRectGetWidth(btn.frame) - 20;
        CGFloat y = (CGRectGetHeight(btn.frame) - h) * 0.5;
        backArrowImgV = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, w, h)];
        backArrowImgV.tag = 3000;
        [btn addSubview:backArrowImgV];
    }
    backArrowImgV.image = rightImg;
}

// 设置右边标题
- (void)setRightTitle:(NSString *)rightTitle
{
    self.navigationItem.rightBarButtonItem = self.rightItem;
    UIButton *btn = (UIButton *)self.rightItem.customView;
    NSDictionary *attributes = @{NSFontAttributeName:btn.titleLabel.font};
    CGFloat width = [rightTitle boundingRectWithSize:CGSizeMake(320, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
    btn.bounds = CGRectMake(0, 0, width, 16);
    [btn setTitle:rightTitle forState:UIControlStateNormal];
    [btn setTitle:rightTitle forState:UIControlStateHighlighted];
}
/**
 *  右边多个按钮
 */
- (void)setRightImages:(NSArray *)rightImages
{
    NSMutableArray *arr = [NSMutableArray array];
    
    for (int i = 0; i < rightImages.count; i++) {
        UIButton *rightB = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 23, 23)];
        rightB.tag = 2000 + i;
        [rightB setBackgroundImage:[UIImage imageNamed:rightImages[i]] forState:UIControlStateNormal];
        [rightB addTarget:self action:@selector(rightBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:rightB];
        [arr addObject:item];
    }
    
    self.navigationItem.rightBarButtonItems = arr;
}

#pragma mark - 按钮事件
/**
 *  左边按钮点击事件
 */
- (void)leftBtnClick
{
    if (self.leftCallBlock) {
        self.leftCallBlock();
        return;
    }
    
    // 默认是返回上个页面
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  右边按钮点击事件
 */
- (void)rightBtnClick
{
    if (self.rightCallBlock) {
        self.rightCallBlock();
    }
}

/**
 *  右边多个按钮点击
 */
- (void)rightBtnsClick:(UIButton *)btn
{
    if (self.rightClick) {
        self.rightClick(btn.tag - 2000);
    }
}

#pragma mark - 公用方法
// 点击屏幕收起键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}

@end
