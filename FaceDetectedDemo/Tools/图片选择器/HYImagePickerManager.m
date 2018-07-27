//
//  HYImagePickerController.m
//  Demo
//
//  Created by MrChen on 2018/3/19.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import "HYImagePickerManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface HYImagePickerManager ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, copy) void (^saveImageComplete)(void);

// 拍照控制器
@property (nonatomic, weak) UIViewController *cameraController;

// 拍完照显示的使用照片按钮
@property (nonatomic, weak) UIButton *userPhotoBtn;

@end

@implementation HYImagePickerManager


#pragma mark - 原始
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static HYImagePickerManager *manager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];

        // create imagePickerCtr
        [manager createImagePicker];
    });
    
    return manager;
}

+ (instancetype)shareManager
{
    return [[self alloc]init];
}

- (void)setSourceType:(UIImagePickerControllerSourceType)sourceType
{
    _sourceType = sourceType;
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        self.imagePickerCtr.sourceType = sourceType;
    }
}

- (void)setCanEdite:(BOOL)canEdite
{
    _canEdite = canEdite;
    
    self.imagePickerCtr.allowsEditing = canEdite;
}

// 前置/后置摄像头
- (void)setCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice
{
    _cameraDevice = cameraDevice;
    
    if (self.sourceType != UIImagePickerControllerSourceTypeCamera) return;
    
    BOOL available = [UIImagePickerController isCameraDeviceAvailable:cameraDevice];
    
    if (available) {
        self.imagePickerCtr.cameraDevice = cameraDevice;
    }else if (cameraDevice == UIImagePickerControllerCameraDeviceRear){
        [self showTip:@"相机后置摄像头不可用" inController:nil];
    }else {
        [self showTip:@"相机前置摄像头不可用" inController:nil];
    }
}

- (UIView *)cameraOverlayView
{
    return self.imagePickerCtr.cameraOverlayView;
}

#pragma mark - 自定义
// create imagePickerCtr
- (void)createImagePicker
{
    UIImagePickerController *imagePickerCtr = [[UIImagePickerController alloc]init];
    imagePickerCtr.delegate = self;
    self.imagePickerCtr = imagePickerCtr;
}

/**
 * 弹出相机/相册
 * animated 是否以动画形式弹出
 */
- (void)showAnimated:(BOOL)animated
{
    [self showAnimated:animated complete:nil];
}

/**
 * 弹出相机/相册
 * animated 是否以动画形式弹出
 * complete 弹出完成回调
 */
- (void)showAnimated:(BOOL)animated complete:(void (^)(void))complete
{
    [self showInController:[UIApplication sharedApplication].keyWindow.rootViewController animated:animated complete:complete];
}

/**
 * 在制定控制器弹出相机/相册
 * vc 控制器
 * animated 是否以动画形式弹出
 * complete 弹出完成回调
 */
- (void)showInController:(UIViewController *)vc animated:(BOOL)animated complete:(void (^)(void))complete
{
    vc = !vc ? [UIApplication sharedApplication].keyWindow.rootViewController : vc;
    
    // 判断相机是否被授权
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        [self showTip:@"相机权限受限,请到设置中启用" inController:vc];
        return;
    }
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            // 允许使用相机
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![UIImagePickerController isSourceTypeAvailable:self.sourceType]) {
                    NSString *msg = (_sourceType == UIImagePickerControllerSourceTypeCamera ? @"相机不可用" : @"相册不可用");
                    [self showTip:msg inController:vc];
                }else {
                    [vc presentViewController:self.imagePickerCtr animated:animated completion:complete];
                }
            });
        }else {
            // 不允许使用相机
            
        }
    }];
}

// 获取从相册选择的图片名(异步获取)
- (void)getImageName:(NSDictionary<NSString *,id> *)info complete: (void (^)(NSString *imageName))complete
{
    __block NSString *imageFileName;
    // 拍照获取的照片imageURL为空,所以无法获取照片名字
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *representation = [myasset defaultRepresentation];
        imageFileName = [representation filename];
        
        if (complete) {
            complete(imageFileName);
        }
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:imageURL
                   resultBlock:resultblock
                  failureBlock:nil];
}

// 提示
- (void)showTip:(NSString *)msg inController:(UIViewController *)ctr
{
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    
    if (ctr == nil) {
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertCtr animated:YES completion:nil];
    }else {
        [ctr presentViewController:alertCtr animated:YES completion:nil];
    }
}

// 使用照片处理
- (void)usePhotoHandleWithPickCtr:(UIImagePickerController *)pickerCtr originImge:(UIImage *)originImage editedImage:(UIImage *)editedImage imageInfo:(NSDictionary *)info
{
    __weak typeof(self) weakSelf = self;
    [pickerCtr dismissViewControllerAnimated:YES completion:^{
        if (self.imagePickComplete) {
            if (self.getImageName) {
                // 获取照片名字
                if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
                    // 拍照,用时间戳命名照片
                    NSString *fileName = [NSString stringWithFormat:@"%.f.JPG",[[NSDate date] timeIntervalSince1970]];
                    self.imagePickComplete(originImage, editedImage, fileName);
                }else {
                    // 从相册获取照片,通过info获取照片名字
                    [weakSelf getImageName:info complete:^(NSString *imageName) {
                        weakSelf.imagePickComplete(originImage, editedImage, imageName);
                    }];
                }
            }else {
                // 不获取照片名字
                self.imagePickComplete(originImage, editedImage, nil);
            }
        }
    }];
}

#pragma mark - actions
// 切换前后摄像头
- (void)switchClick
{
    [self showTip:@"只能使用前置摄像头" inController:self.imagePickerCtr];
}

// 拍照
- (void)takePicture
{
    // 获取使用照片按钮
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        UIImage *originImage = nil;
//        UIButton *userPhotoBtn = nil;
//        UIImageView *imageView = nil;
//        for (UIView *tmpView in self.cameraController.view.subviews) {
//            for (UIView *tmpView2 in tmpView.subviews) {
//                if ([[[tmpView2 class] description] isEqualToString:@"PLImageScrollView"]) {
//                    for (UIView *subView in tmpView2.subviews) {
//                        if ([[[subView class] description] isEqualToString:@"PLExpandableImageView"]) {
//                            for (UIView *imageSubView in subView.subviews) {
//                                if ([[[imageSubView class] description] isEqualToString:@"PLImageView"]) {
//                                    UIImageView *imageV = (UIImageView *)imageSubView;
//                                    imageView = imageV;
//                                    originImage = imageV.image;
//                                    break;
//                                }
//                            }
//                            break;
//                        }
//                        break;
//                    }
//                }else if ([[[tmpView2 class] description] isEqualToString:@"PLCropOverlayBottomBar"]) {
//                    for (UIView *mySubView in tmpView2.subviews) {
//                        if ([[[mySubView class] description] isEqualToString:@"PLCropOverlayPreviewBottomBar"]) {
//                            for (UIView *afterSubview in mySubView.subviews) {
//                                UIButton *btn = (UIButton *)afterSubview;
//                                if ([btn.currentTitle isEqualToString:@"使用照片"]) {
//                                    userPhotoBtn = btn;
//                                    break;
//                                }
//                            }
//                            break;
//                        }
//                    }
//                    break;
//                }
//            }
//        }
//        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
//        view.backgroundColor = [UIColor redColor];
//        [self.userPhotoBtn addSubview:view];
//        userPhotoBtn.backgroundColor = [UIColor orangeColor];
//
//        // 人脸检测
//        BOOL haveFaceInfo = [self detectedFace:imageView.image];
//
//        if (haveFaceInfo) {
//            // 检测到人脸
//            [self showTip:@"检测到人脸" inController:self.cameraController];
//            if (self.detectedFaceResult) {
//                self.detectedFaceResult(YES);
//            }
//        }else {
//            [self showTip:@"未检测到人脸" inController:self.cameraController];
//
//            // 未检测到人脸
//            if (self.detectedFaceResult) {
//                self.detectedFaceResult(NO);
//            }
//        }
//    });
}

#pragma mark - UIImagePickerControllerDelegate
// 选择照片/拍照完成
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *originImage = info[@"UIImagePickerControllerOriginalImage"];
    UIImage *editedImage = info[@"UIImagePickerControllerEditedImage"];
    
    // 使用照片
    [self usePhotoHandleWithPickCtr:picker originImge:originImage editedImage:editedImage imageInfo:info];
}

// 取消选择
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.cameraController = viewController;
    
    if (self.forbiddenRearCamera) {
        // 禁用后摄像头
        for (UIView *tmpView in viewController.view.subviews) {
            for (UIView *tmpView2 in tmpView.subviews) {
                for (UIView *subView in tmpView2.subviews) {
                    if ([[[subView class] description]isEqualToString:@"CUShutterButton"]) {
                        // 系统拍照按钮
                        UIButton *shutButton = (UIButton *)subView;
                        [shutButton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
                    }else if ([[[subView class] description]isEqualToString:@"CAMFlipButton"]) {
                        // 前后摄像头切换按钮
                        UIButton *switchButton = (UIButton *)subView;
                        
                        // 禁用系统按钮
                        UIView *coverV = [switchButton viewWithTag:3000];
                        if (!coverV) {
                            UIButton *cv = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
                            cv.tag = 3000;
                            cv.backgroundColor = [UIColor clearColor];
                            [cv addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventTouchUpInside];
                            [switchButton addSubview:cv];
                        }
                    }
                }
            }
        }
    }
}

@end

