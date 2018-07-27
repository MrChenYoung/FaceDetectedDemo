//
//  CoreImageViewController.m
//  FaceDetectedDemo
//
//  Created by MrChen on 2018/4/24.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import "CoreImageViewController.h"


@interface CoreImageViewController ()

@end

@implementation CoreImageViewController

#pragma mark - 自定义
// 人脸识别
- (void)faceDetected
{
    NSArray <FaceModel *>*faceInfo = [HYFaceDetectedManager faceDetectedCoreImage:self.imageView.image imageView:self.imageView];
    self.faceInfoArr = faceInfo;
}

@end
