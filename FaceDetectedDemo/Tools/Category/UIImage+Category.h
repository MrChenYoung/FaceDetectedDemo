//
//  UIImage+Category.h
//  Deppon
//
//  Created by MrChen on 2017/12/5.
//  Copyright © 2017年 MrChen. All rights reserved.
//

/**
 * 功能列表
 * 1> 获取图片的二进制数据
 * 2> 获取屏幕的全屏截屏
 * 3> 获取屏幕指定区域的截屏
 * 4> 截取图片指定区域
 * 5> 获取图片指定像素点的颜色值
 * 6> 获取图片格式(png/jpg)
 * 7> 获取给定尺寸下等比例缩放后图片的尺寸
 * 8> 给定尺寸等比例缩放图片
 * 9> 给定尺寸裁剪图片
 * 10>存储到document文件夹
 * 11>删除document文件夹指定的图片
 * 12>保存图片到相册
 * 13>拉伸图片
 * 14>给定图片路径获取图片尺寸
 * 15>压缩图片到指定大小(kb)
 * 16>压缩图片质量到指定大小(kb)
 * 17>压缩图片尺寸到指定大小(kb)
 * 18>图片的base64编码
 * 19>图片占用的存储空间(kb)
 */

#import <UIKit/UIKit.h>

@interface UIImage (Category)

#pragma mark - 附加属性
// 获取图片的二进制数据
@property (nonatomic, strong) NSData *data;
// 获取图片的base64编码
@property (nonatomic, copy) NSString *base64Encode;
// 占用的存储空间(单位kb)
@property (nonatomic, assign) CGFloat spaceSize;

#pragma mark - 获取截屏
/**
 * 获取全屏截图
 */
+ (UIImage *)imageFullScreen;

/**
 * 获取屏幕指定区域的图片
 */
+ (UIImage *)imageWithRect:(CGRect)rect;

/**
 * 截取图片的某一部分
 * rect 截取的区域
 */
- (UIImage *)clipImageInRect:(CGRect)rect;

#pragma mark - 获取颜色值

//获取图片某一点的颜色
- (UIColor *)imageColorAtPixel:(CGPoint)point;

#pragma mark - 获取图片格式
/**
 * 根据第一个字节获取图片的格式
 * data 图片的二进制数据(通过图片路径找到原图片转换成二进制)
 */
+ (NSString *)imageTypeWithImageData:(NSData *)data;

#pragma mark - 图片等比例缩放
/**
 *  等比例缩放图片
 *
 *  @param tagetSize  要缩放的大小
 *
 *  @return 缩放后的图片
 */
- (UIImage *)imageAfterEqualscaleZoomWithTagetSize:(CGSize)tagetSize;

/**
 *  获取等比例缩放后图片的尺寸(为了让图片不变形要等比例缩放,这个方法返回的是根据给定的size计算出缩放后的size)
 *
 *  @param tagetSize 用户设置的要缩放的尺寸
 *
 *  @return 计算后最终缩放的尺寸(宽或者高和tagetSize相等)
 */
- (CGSize)imageSizeAfterEqualscaleZoomWithTagetSize:(CGSize)tagetSize;

/**
 *  等比例放大/缩小图片scale倍
 *
 *  @param scale 放大/缩小倍数
 *
 *  @return 处理后图片
 */
- (UIImage *)imageZoomToScale:(CGFloat)scale;

#pragma mark - 图片裁剪
/**
 *  裁剪图片
 *
 *  @param tagetSize  目标大小
 *  @param edgeInsets 偏移区域
 *
 *  @return 裁剪后的图片
 */
- (UIImage *)imageAfterCutWithTagetSize:(CGSize)tagetSize edgeInsets:(UIEdgeInsets)edgeInsets;

#pragma mark - 图片存储和删除
/**
 *  存储图片,存储到document文件夹
 *
 *  @param imageName 存储的名字
 */
- (void)imageSaveToDocumentWithImageName:(NSString *)imageName;

/**
 *  从document删除图片(对文件也适用)
 *
 *  @return 是否删除成功
 */
- (BOOL)deleteImageFromDocumentWithImageName:(NSString *)imageName;

/**
 *  保存图片到相册
 */
- (void)imageSaveToPhotoAlbum;

#pragma mark - 图片拉伸
/**
 *  根据图片名字拉伸图片
 *
 *  @return 拉伸后的图片
 */
- (UIImage *)imageStretched;

#pragma mark - 根据图片URL获取图片的size
/**
 * 根据图片url获取图片尺寸
 * imageURL 图片url(NSString类型或者NSUrl类型)
 */
+ (CGSize)imageSizeWithURL:(id)imageURL;

#pragma mark - 图片压缩
/**
 * 压缩图片(先压缩质量，再压缩尺寸,可以一定程度上保证图片的清晰度)
 * maxLength 限制的最大占用存储值(单位kb)
 */
- (UIImage *)imageCompressWithLengthLimit:(NSInteger)maxLength;

/**
 * 压缩图片尺寸
 * 压缩图片尺寸可以达到想要大小的图片，但是图片的清晰度会变差，所以建议对清晰度要求高的只对图片进行质量压缩就可以了
 * maxLength 限制的最大占用存储值(单位kb)
 */
-(UIImage *)imageCompressBySizeWithLengthLimit:(NSInteger)maxLength;

/**
 * 二分法压缩图片质量(效率高,建议优先使用)
 * 压缩图片质量尽量保留图片的清晰度，但是最终不一定能达到想要大小的图片,因为图片压缩到一定质量后就不会再被压缩
 * maxLength 限制的最大占用存储值(单位kb)
 */
- (UIImage *)imageCompressMidQualityWithLengthLimit:(NSInteger)maxLength;

- (UIImage *)imageCompressWithScale:(NSUInteger)scale;

@end
