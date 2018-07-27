//
//  HYFaceDetectedManager.h
//  BaiduPanoDemo
//
//  Created by MrChen on 2018/4/23.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FaceModel:NSObject

// 人脸frame
@property (nonatomic, assign) CGRect faceFrame;

// 是否有左眼
@property (nonatomic, assign) BOOL hasLeftEyePosition;

// 左眼位置
@property (nonatomic, assign) CGPoint leftEyePosition;
// 左眼frame
@property (nonatomic, assign) CGRect leftEyeFrame;

// 是否有右眼
@property (nonatomic, assign) BOOL hasRightEyePosition;

// 右眼位置
@property (nonatomic, assign) CGPoint rightEyePosition;
//右眼frame
@property (nonatomic, assign) CGRect rightEyeFrame;

// 是否有嘴
@property (nonatomic, assign) BOOL hasMouthPosition;

// 嘴的位置
@property (nonatomic, assign) CGPoint mouthPosition;
// 嘴frame
@property (nonatomic, assign) CGRect mouthFrame;

@end

@interface HYFaceDetectedManager : NSObject

// 人脸检测回调(经测试不太耗时，所以就在主线程做了，没有主回调)
//@property (nonatomic, copy) void (^faceDetectedBlock)(NSArray <FaceModel *>*arr);

/**
 * 人脸检测
 * originImage 原始图片
 * imageView   图片所在imageView
 * return      人脸信息
 */
+ (NSArray <FaceModel *>*)faceDetectedCoreImage:(UIImage *)originImage imageView:(UIImageView *)imageView;

@end
