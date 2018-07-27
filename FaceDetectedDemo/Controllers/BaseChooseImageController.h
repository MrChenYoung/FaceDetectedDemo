//
//  BaseChooseImageController.h
//  FaceDetectedDemo
//
//  Created by MrChen on 2018/4/24.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import "HYViewController.h"
#import "HYFaceDetectedManager.h"

@interface BaseChooseImageController : HYViewController

@property (nonatomic, strong, readonly) UIImage *image;

@property (nonatomic, strong,readonly) UIImageView *imageView;

@property (nonatomic, strong) NSArray <FaceModel *>*faceInfoArr;

// 人脸识别
- (void)faceDetected;

@end
