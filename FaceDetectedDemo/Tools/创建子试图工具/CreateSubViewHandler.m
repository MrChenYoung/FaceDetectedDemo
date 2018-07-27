//
//  CreateSubViewHandler.m
//  RuntimeDemo
//
//  Created by sphere on 2017/9/14.
//  Copyright © 2017年 sphere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateSubViewHandler.h"

@implementation CreateSubViewHandler
// 创建按钮
+ (void)createBtn:(NSArray *)titles fontSize:(CGFloat)fontSize target:(id)target sel: (SEL)selector superView:(UIView *)superView baseTag: (NSInteger)baseTag
{
    CGFloat padding = 20;
    CGFloat topPadding = 20;
    CGFloat btnW = [UIScreen mainScreen].bounds.size.width - padding * 2;
    CGFloat btnH = 40;
    
    for (NSString *title in titles) {
        NSInteger index = [titles indexOfObject:title];
        CGFloat btnX = padding;
        CGFloat btnPadding = ([UIScreen mainScreen].bounds.size.height - topPadding * 2 - btnH * titles.count - 64)/(titles.count + 1);
        CGFloat btnY = topPadding +  btnPadding * (index + 1) + btnH * index + 64;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        btn.backgroundColor = [UIColor colorWithRed:0/255.0 green:150/255.0 blue:255/255.0 alpha:1];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.tag = baseTag + index;
        [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        [superView addSubview:btn];
    }
}
@end
