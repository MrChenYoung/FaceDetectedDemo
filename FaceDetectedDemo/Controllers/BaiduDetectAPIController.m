//
//  BaiduDetectAPIController.m
//  FaceDetectedDemo
//
//  Created by MrChen on 2018/6/20.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import "BaiduDetectAPIController.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "UIImage+Category.h"


@interface BaiduDetectAPIController ()

@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation BaiduDetectAPIController

- (MBProgressHUD *)hud
{
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:_hud];
    }
    
    return _hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

// 获取token
- (void)getAccessTokenSuccess:(void (^)(NSString *token))success
{
    NSString *url = @"https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=R5p7YA9Urg9k7aO4uyLvwm9T&client_secret=5W97FK8w5F2IgyALwlzWMQp9KqPQBtmp";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",nil];
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *tok = responseObject[@"access_token"];
            if (success) {
                success(tok);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败");
    }];
}

// 发送人脸识别请求
- (void)faceDetactRequestWithToken:(NSString *)token success:(void (^)(id response))success
{
    NSString *imageString = [self.image base64Encode];
    NSString *url = [NSString stringWithFormat:@"https://aip.baidubce.com/rest/2.0/face/v3/detect?access_token=%@",token];
    NSDictionary *para = @{@"image_type":@"BASE64",
                           @"image":imageString
                           };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",nil];
    [manager POST:url parameters:para progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败:%@",error);
    }];
}

// 人脸识别
- (void)faceDetected
{
    [super faceDetected];
    NSLog(@"%@",self.hud);
    [self.view bringSubviewToFront:self.hud];
    [self.hud showAnimated:YES];
    // 防止token失效，发送人脸识别错误，每次请求一次token
    [self getAccessTokenSuccess:^(NSString *token) {
        [self faceDetactRequestWithToken:token success:^(id response) {
            NSArray *faces = response[@"result"][@"face_list"];
            
            NSMutableArray *arrM = [NSMutableArray array];
            CGFloat scale = self.imageView.frame.size.width/self.image.size.width;
            for (NSDictionary *dic in faces) {
                NSDictionary *faceLocation = dic[@"location"];
                CGRect frame = CGRectMake([faceLocation[@"left"] floatValue] * scale, [faceLocation[@"top"] floatValue] * scale, [faceLocation[@"width"] floatValue] * scale, [faceLocation[@"height"] floatValue] * scale);
                FaceModel *model = [[FaceModel alloc]init];
                model.faceFrame = frame;
                [arrM addObject:model];
            }
            
            [self.hud hideAnimated:YES];
            self.faceInfoArr = arrM;
        }];
    }];
}

@end
