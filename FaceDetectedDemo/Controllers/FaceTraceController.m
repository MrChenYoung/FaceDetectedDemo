//
//  FaceTraceController.m
//  FaceDetectedDemo
//
//  Created by MrChen on 2018/4/26.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import "FaceTraceController.h"
#import "HYCamera.h"

@interface FaceTraceController ()

@property (nonatomic, strong) HYCamera *came;
@end

@implementation FaceTraceController

- (void)viewDidLoad {
    [super viewDidLoad];

    HYCamera *came = [[HYCamera alloc]initWithPreviewFrame:self.view.bounds];
    self.came = came;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.came showInView:self.view];
}


@end
