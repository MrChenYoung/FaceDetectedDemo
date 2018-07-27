//
//  CreateSubViewHandler.h
//  RuntimeDemo
//
//  Created by sphere on 2017/9/14.
//  Copyright © 2017年 sphere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateSubViewHandler : NSObject
// 创建按钮
+ (void)createBtn:(NSArray *)titles fontSize:(CGFloat)fontSize target:(id)target sel: (SEL)selector superView:(UIView *)superView baseTag: (NSInteger)baseTag;
@end
