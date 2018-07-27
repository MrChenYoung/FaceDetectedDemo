//
//  HYNavigationController.m
//  Test
//
//  Created by MrChen on 2018/3/8.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import "HYNavigationController.h"

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define TOP_VIEW  [[UIApplication sharedApplication]keyWindow].rootViewController.view

// 手指在屏幕上滑动的最短相应返回距离
#define KPANDISTANCE 50

// 左滑以后动画返回的时间
#define KANIMATDURATION 0.3

// 屏幕宽度
#define KSCREENW [UIScreen mainScreen].bounds.size.width

@interface HYNavigationController ()<UIGestureRecognizerDelegate>

// 屏幕快照存储
@property (nonatomic,retain) NSMutableArray *screenShotsList;

// 右滑返回手势
@property (nonatomic, weak) UIPanGestureRecognizer *backPanGesture;

// 右滑返回手势起始点
@property (nonatomic, assign) CGPoint startTouch;

// 是否正在右滑返回
@property (nonatomic,assign) BOOL isMoving;

// 右滑返回背景视图
@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *blackMask;

// 最后一次屏幕快照
@property (nonatomic, strong) UIImageView *lastScreenShotView;

@end

@implementation HYNavigationController

#pragma mark - 初始化
- (instancetype)init
{
    if (self = [super init]) {
        // 初始化样式设置
        [self SetInitializeStayle];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // 初始化样式设置
        [self SetInitializeStayle];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // 初始化样式设置
        [self SetInitializeStayle];
    }
    
    return self;
}

#pragma mark - 原始方法
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 左滑返回的快照
    if (self.screenShotsList.count == 0) {
        UIImage *capturedImage = [self capture];
        if (capturedImage) {
            [self.screenShotsList addObject:capturedImage];
        }
    }
}

#pragma mark - 重写系统方法
// 重写push方法
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIImage *capturedImage = [self capture];
    
    if (capturedImage) {
        [self.screenShotsList addObject:capturedImage];
    }
    
    [self setNavigationBarStateWithViewCtr:viewController];
    
    [super pushViewController:viewController animated:animated];
}

// 重写pop方法
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.screenShotsList removeLastObject];
    UIViewController *viewController = self.viewControllers[self.viewControllers.count - 2];
    [self setNavigationBarStateWithViewCtr:viewController];
    return [super popViewControllerAnimated:animated];
}

// 重写popTORoot方法
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    UIViewController *viewCtr = self.viewControllers[0];
    [self setNavigationBarStateWithViewCtr:viewCtr];
    [self.screenShotsList removeAllObjects];
    return [super popToRootViewControllerAnimated:animated];
}

#pragma mark - 自定义
// 初始化样式设置
- (void)SetInitializeStayle
{
    // 导航栏背景色(默认色)
    self.navigationBar.barTintColor = [UIColor colorWithRed:42/255.0 green:92/255.0 blue:170/255.0 alpha:1.0];
    
    // 导航栏上添加文字的着色
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    // 导航栏标题默认字体大小和颜色
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor] ,NSFontAttributeName:[UIFont systemFontOfSize:18]};
    
    // 屏幕快照存储
    self.screenShotsList = [[NSMutableArray alloc]initWithCapacity:2];
}

// 去掉导航栏下面的默认线条
- (void)removeNavBarBottomLine
{
    // 去掉导航栏下边缘的线条
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
}

// 设置指定的控制器出现的时候，tabbar的状态
- (void)setNavigationBarStateWithViewCtr:(UIViewController *)viewController
{
    // 设置指定控制器的导航栏隐藏
    NSString *className = NSStringFromClass([viewController class]);
    BOOL hiddenNavBar = [self.naviBarHiddenControllers containsObject:className];
    if (hiddenNavBar) {
        self.navigationBarHidden = YES;
    }else{
        self.navigationBarHidden = NO;
    }
    
    // 设置tabbar的隐藏状态
    if (self.viewControllers.count == 0) return;
    if (viewController != self.viewControllers[0]) {
        self.tabBarController.tabBar.hidden = YES;
    }else{
        self.tabBarController.tabBar.hidden = NO;
    }
}

#pragma mark - 全屏左滑返回
// 是否支持右滑返回
- (void)setCanDragBack:(BOOL)canDragBack
{
    _canDragBack = canDragBack;
    
    if (canDragBack && self.backPanGesture == nil) {
        [self addPanGesture];
    }
}

// 获取当前屏幕快照
- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(TOP_VIEW.bounds.size, TOP_VIEW.opaque, 0.0);
    [TOP_VIEW.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

// 添加右滑返回手势
- (void)addPanGesture
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(paningGestureReceive:)];
    recognizer.delegate = self;
    [recognizer delaysTouchesBegan];
    [self.view addGestureRecognizer:recognizer];
    self.backPanGesture = recognizer;
}

// 动画公用方法
- (void)animation:(void (^)(void))animat complete:(void (^)(void))complete
{
    [UIView animateWithDuration:KANIMATDURATION animations:^{
        if (animat) {
            animat();
        }
    } completion:^(BOOL finished) {
        if (complete) {
            complete();
        }
    }];
}

- (void)moveViewWithX:(float)x
{
    x = x > KSCREENW ? KSCREENW : x;
    x = x<0?0:x;
    
    CGRect frame = TOP_VIEW.frame;
    frame.origin.x = x;
    TOP_VIEW.frame = frame;
    
    float scale = (x/6400)+0.95;
    float alpha = 0.4 - (x/800);
    
    self.lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    self.blackMask.alpha = alpha;
}

#pragma mark - 滑动手势事件
- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    // 到主控制器或者禁止了滑动返回不响应手势
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    // 获取手指的位置
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    // begin paning, show the backgroundView(last screenshot),if not exist, create it.
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        self.startTouch = touchPoint;
        
        if (!self.backgroundView){
            CGRect frame = TOP_VIEW.frame;
            
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            [TOP_VIEW.superview insertSubview:self.backgroundView belowSubview:TOP_VIEW];
            
            self.blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            self.blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:self.blackMask];
        }
        
        self.backgroundView.hidden = NO;
        
        if (self.lastScreenShotView) [self.lastScreenShotView removeFromSuperview];
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        self.lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        [self.backgroundView insertSubview:self.lastScreenShotView belowSubview:self.blackMask];
        
        //End paning, always check that if it should move right or move left automatically
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        // 屏幕上滑动的距离大于KPANDISTANCE触发返回
        if (touchPoint.x - self.startTouch.x > KPANDISTANCE){
            [self animation:^{
                [self moveViewWithX:KSCREENW];
            } complete:^{
                [self popViewControllerAnimated:NO];
                CGRect frame = TOP_VIEW.frame;
                frame.origin.x = 0;
                TOP_VIEW.frame = frame;
                
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
        }else{
            [self animation:^{
                [self moveViewWithX:0];
            } complete:^{
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
        }
        return;
        
        // cancal panning, alway move to left side automatically
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        [self animation:^{
            [self moveViewWithX:0];
        } complete:^{
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }
    
    // it keeps move with touch
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - self.startTouch.x];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 到主控制器或者禁止了滑动返回不响应手势
    if (self.viewControllers.count <= 1 || !self.canDragBack) return NO;
    
    return YES;
}

@end
