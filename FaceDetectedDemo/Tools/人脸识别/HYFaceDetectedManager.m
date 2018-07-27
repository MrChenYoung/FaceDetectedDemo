//
//  HYFaceDetectedManager.m
//  BaiduPanoDemo
//
//  Created by MrChen on 2018/4/23.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import "HYFaceDetectedManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation FaceModel

@end

@implementation HYFaceDetectedManager

/**
 * 人脸检测
 * originImage 原始图片
 * imageView   图片所在imageView
 * return      人脸信息
 */
+ (NSArray <FaceModel *>*)faceDetectedCoreImage:(UIImage *)originImage imageView:(UIImageView *)imageView
{
    //1 将UIImage转换成CIImage
    CIImage *personciImage = [CIImage imageWithCGImage:originImage.CGImage];
    
    // 设置识别参数(能够识别相机拍的原始照片)
    NSDictionary *imageOptions =  [NSDictionary dictionaryWithObject:@(5) forKey:CIDetectorImageOrientation];
    
    // 设置识别精度
    NSDictionary *opts = [NSDictionary dictionaryWithObject:
                          CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    
    // 创建识别器
    CIDetector *faceDetector=[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    
    /**
     * 这里检测使用两种方法结合，保证检测的准确性，只用一种的话，有的照片可能不能检测出来
     */
    
    // 不带options检测,不能检测相机拍的原始照片
    NSArray *features = [faceDetector featuresInImage:personciImage];
    
    if (features == nil || features.count == 0) {
        // 带options检测,能检测相机拍的原始照片,有时候不能检测保存的照片的人脸
        features = [faceDetector featuresInImage:personciImage options:imageOptions];
    }
    
    
    // 得到图片的尺寸
    CGSize inputImageSize = [personciImage extent].size;
    //将image沿y轴对称
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, -1);
    //将图片上移
    transform = CGAffineTransformTranslate(transform, 0, -inputImageSize.height);
    
    // 获取缩放倍率
    CGSize viewSize = imageView.bounds.size;
    CGFloat scale = MIN(viewSize.width / inputImageSize.width,
                        viewSize.height / inputImageSize.height);
    CGFloat offsetX = (viewSize.width - inputImageSize.width * scale) / 2;
    CGFloat offsetY = (viewSize.height - inputImageSize.height * scale) / 2;
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    
    NSMutableArray *arrM = [NSMutableArray array];
    // 取出所有人脸
    for (CIFaceFeature *faceFeature in features){
        
        //获取人脸的frame
        CGRect faceViewBounds = CGRectApplyAffineTransform(faceFeature.bounds, transform);
        
        // 修正
        faceViewBounds = CGRectApplyAffineTransform(faceViewBounds,scaleTransform);
        faceViewBounds.origin.x += offsetX;
        faceViewBounds.origin.y += offsetY;
        
        // 人脸模型转换
        FaceModel *faceM = [[FaceModel alloc]init];
        
        // 脸部frame
        CGFloat faceWidth = faceFeature.bounds.size.width;
        faceM.faceFrame = faceViewBounds;
        
        CGFloat eyeW = faceWidth * 0.3;
        CGFloat eyeH = eyeW * 0.5;
        // 判断是否有左眼位置
        if(faceFeature.hasLeftEyePosition){
            faceM.hasLeftEyePosition = YES;
            faceM.leftEyePosition = faceFeature.leftEyePosition;
            
            CGFloat leftEyeX = faceFeature.leftEyePosition.x - eyeW * 0.5;
            CGFloat leftEyeY = faceFeature.leftEyePosition.y - eyeH * 0.5;
            CGRect leftEyeFrame = CGRectMake(leftEyeX, leftEyeY, eyeW, eyeH);
            
            // 校正
            leftEyeFrame = CGRectApplyAffineTransform(leftEyeFrame, transform);
            leftEyeFrame = CGRectApplyAffineTransform(leftEyeFrame,scaleTransform);
            faceM.leftEyeFrame = leftEyeFrame;
        }
        // 判断是否有右眼位置
        if(faceFeature.hasRightEyePosition){
            faceM.hasRightEyePosition = YES;
            faceM.rightEyePosition = faceFeature.rightEyePosition;
            
            CGFloat rightEyeX = faceFeature.rightEyePosition.x - eyeW * 0.5;
            CGFloat rightEyeY = faceFeature.rightEyePosition.y - eyeH * 0.5;
            CGRect rightEyeFrame = CGRectMake(rightEyeX, rightEyeY, eyeW, eyeH);
            
            // 校正
            rightEyeFrame = CGRectApplyAffineTransform(rightEyeFrame, transform);
            rightEyeFrame = CGRectApplyAffineTransform(rightEyeFrame,scaleTransform);
            faceM.rightEyeFrame = rightEyeFrame;
        }
        
        // 判断是否有嘴位置
        if(faceFeature.hasMouthPosition){
            faceM.hasMouthPosition = YES;
            faceM.mouthPosition = faceFeature.mouthPosition;
            
            CGFloat mouthW = faceWidth * 0.4;
            CGFloat mouthH = mouthW * 0.5;
            CGFloat mouthX = faceFeature.mouthPosition.x - mouthW * 0.5;
            CGFloat mouthY = faceFeature.mouthPosition.y - mouthH * 0.5;
            CGRect mouthFrame = CGRectMake(mouthX, mouthY, mouthW, mouthH);
            
            // 校正
            mouthFrame = CGRectApplyAffineTransform(mouthFrame, transform);
            mouthFrame = CGRectApplyAffineTransform(mouthFrame,scaleTransform);
            faceM.mouthFrame = mouthFrame;
        }
        
        [arrM addObject:faceM];
    }
    
    return [arrM copy];
}

@end
