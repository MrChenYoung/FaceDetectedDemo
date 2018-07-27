//
//  HYImagePickerController.h
//  Demo
//
//  Created by MrChen on 2018/3/19.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYImagePickerManager : NSObject

// imagepicker
@property (nonatomic, strong) UIImagePickerController *imagePickerCtr;

// 人脸检测结果回调
@property (nonatomic, copy) void (^detectedFaceResult)(BOOL haveFaceInfo);

// 类型(相机/相册)
@property (nonatomic, assign) UIImagePickerControllerSourceType sourceType;

// 前置/后置摄像头
@property (nonatomic, assign) UIImagePickerControllerCameraDevice cameraDevice;

// 是否禁用后摄像头
@property (nonatomic, assign) BOOL forbiddenRearCamera;

// 照片是否可编辑
@property (nonatomic, assign) BOOL canEdite;

// 是否获取图片名称
@property (nonatomic, assign) BOOL getImageName;

// 拍照界面
@property (nonatomic, strong) UIView *cameraOverlayView;

/**
 * 拍照/选择照片完成回调
 * originImage:原始图片
 * editedImage:编辑后的图片(只有canEdite设置为true的时候才有值)
 * imageName:图片名字(只有getImageName设置为true的时候才有值)
 */
@property (nonatomic, copy) void (^imagePickComplete)(UIImage *originImage,UIImage *editedImage,NSString *imageName);

+ (instancetype)shareManager;

/**
 * 弹出相机/相册
 * animated 是否以动画形式弹出
 */
- (void)showAnimated:(BOOL)animated;

/**
 * 弹出相机/相册
 * animated 是否以动画形式弹出
 * complete 弹出完成回调
 */
- (void)showAnimated:(BOOL)animated complete:(void (^)(void))complete;

/**
 * 在制定控制器弹出相机/相册
 * vc 控制器
 * animated 是否以动画形式弹出
 * complete 弹出完成回调
 */
- (void)showInController:(UIViewController *)vc animated:(BOOL)animated complete:(void (^)(void))complete;

@end


