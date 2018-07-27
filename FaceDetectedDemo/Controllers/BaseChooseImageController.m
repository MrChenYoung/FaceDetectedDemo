//
//  BaseChooseImageController.m
//  FaceDetectedDemo
//
//  Created by MrChen on 2018/4/24.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import "BaseChooseImageController.h"
#import "UIView+Category.h"
#import "HYImagePickerManager.h"
#import "UIImage+Category.h"

@interface BaseChooseImageController ()

@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, strong,readwrite) UIImageView *imageView;

@property (nonatomic, weak) UILabel *faceNumLabel;

@end

@implementation BaseChooseImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建子试图
    [self createSubviews];
    
    [HYImagePickerManager shareManager].imagePickComplete = ^(UIImage *originImage, UIImage *editedImage, NSString *imageName) {
    
        self.image = originImage;
        
        // 选择照片/拍照完成
        CGFloat maxW = self.view.bounds.size.width - 20;
        CGSize targetSize = CGSizeMake(maxW, maxW);
        
        do {
            if (targetSize.width > maxW || targetSize.height > maxW) {
                targetSize = CGSizeMake(targetSize.width - 20, targetSize.height - 20);
            }
            
            targetSize = [originImage imageSizeAfterEqualscaleZoomWithTagetSize:targetSize];
        } while (targetSize.width > maxW || targetSize.height > maxW);
        self.imageView.viewSize = targetSize;
        self.imageView.center = self.view.center;
        self.imageView.image = originImage;
        self.faceNumLabel.viewY = self.imageView.viewMaxY + 20;
        
        [self faceDetected];
    };
    
    // 检测人脸
    [self faceDetected];
}

- (void)setFaceInfoArr:(NSArray<FaceModel *> *)faceInfoArr
{
    _faceInfoArr = faceInfoArr;
    
    // 移除图片上以前所有的标注
    for (UIView *view in self.imageView.subviews) {
        [view removeFromSuperview];
    }
    
    if (faceInfoArr.count == 0) {
        [UIView showAlert:YES title:nil message:@"没有检测到脸部信息" btnTitles:@[@"确定"] actions:nil showCtr:self presentComplete:nil];
        return;
    }
    
    self.faceNumLabel.text = [NSString stringWithFormat:@"检测到%lu张人脸",(unsigned long)faceInfoArr.count];
    
    for (FaceModel *faceM in faceInfoArr) {
        // 标出脸部
        [self rectangleViewWithFrame:faceM.faceFrame];
        
        // 标出眼部位置
        if (faceM.hasLeftEyePosition) {
            [self rectangleViewWithFrame:faceM.leftEyeFrame];
        }
        if (faceM.hasRightEyePosition) {
            [self rectangleViewWithFrame:faceM.rightEyeFrame];
        }
        
        // 标出嘴的位置
        if (faceM.hasMouthPosition) {
            [self rectangleViewWithFrame:faceM.mouthFrame];
        }
    }
}

#pragma mark - createSubviews
- (void)createSubviews
{
    __weak typeof(self) weakSelf = self;
    
    self.navTitle = self.title;
    
    // 初始化图片
    UIImage *image = [UIImage imageNamed:@"fanbingbing.jpg"];
    self.image = image;
    self.imageView = [[UIImageView alloc]initWithImage:image];
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.imageView.center = self.view.center;
    [self.view addSubview:self.imageView];
    
    // 设置naviBar
    self.rightTitle = @"选择照片";
    self.rightCallBlock = ^{
        void (^openCamera)(void) = ^{
            [HYImagePickerManager shareManager].sourceType = UIImagePickerControllerSourceTypeCamera;
            [[HYImagePickerManager shareManager] showInController:weakSelf animated:YES complete:nil];
        };
        
        void (^openAlbum)(void) = ^{
            [HYImagePickerManager shareManager].sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [[HYImagePickerManager shareManager] showInController:weakSelf animated:YES complete:nil];
        };
        
        [UIView showAlert:NO title:nil message:nil btnTitles:@[@"打开相机",@"从相册选择"] actions:@[openCamera,openAlbum] showCtr:weakSelf presentComplete:nil];
    };
    
    UILabel *faceNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    faceNumLabel.viewY = self.imageView.viewMaxY + 20;
    faceNumLabel.text = @"人脸数量";
    faceNumLabel.textColor = [UIColor blueColor];
    faceNumLabel.font = [UIFont systemFontOfSize:15.0];
    faceNumLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:faceNumLabel];
    self.faceNumLabel = faceNumLabel;
}

// 脸部，眼睛和嘴的标注view
- (void)rectangleViewWithFrame:(CGRect)frame
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.layer.borderWidth = 2;
    view.layer.borderColor = [UIColor redColor].CGColor;
    [self.imageView addSubview:view];
}

// 人脸识别
- (void)faceDetected
{
    // 子类去实现具体识别代码
    
}


@end
