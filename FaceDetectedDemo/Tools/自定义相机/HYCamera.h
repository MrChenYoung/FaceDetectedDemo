//
//  HYCamera.h
//  FaceDetectedDemo
//
//  Created by MrChen on 2018/4/25.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HYCamera : NSObject

- (instancetype)initWithPreviewFrame:(CGRect)frame;

- (void)showInView:(UIView *)view;

@end
