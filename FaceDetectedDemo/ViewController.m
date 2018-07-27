//
//  ViewController.m
//  FaceDetectedDemo
//
//  Created by MrChen on 2018/4/24.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import "ViewController.h"
#import "CreateSubViewHandler.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"人脸识别";
    
    NSArray *btnTitles = @[@"CoreImage识别",@"人脸追踪",@"百度人脸识别API"];
    
    [CreateSubViewHandler createBtn:btnTitles fontSize:18 target:self sel:@selector(click:) superView:self.view baseTag:1000];
}

- (void)click:(UIButton *)btn
{
    NSInteger tag = btn.tag - 1000;
    NSString *className = @"CoreImageViewController";
    
    switch (tag) {
        case 0:
            // CoreImage人脸识别
            className = @"CoreImageViewController";
            break;
        case 1:
            // 脸部追踪
            className = @"FaceTraceController";
            break;
        case 2:
            // 百度人脸识别API
            className = @"BaiduDetectAPIController";
            break;
            
        default:
            break;
    }
    
    UIViewController *ctr = [[NSClassFromString(className) alloc] init];
    ctr.title = btn.currentTitle;
    [self.navigationController pushViewController:ctr animated:YES];
}

@end
