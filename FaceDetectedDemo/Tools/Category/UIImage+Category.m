//
//  UIImage+Category.m
//  Deppon
//
//  Created by MrChen on 2017/12/5.
//  Copyright © 2017年 MrChen. All rights reserved.
//

#import "UIImage+Category.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation UIImage (Category)

#pragma mark - 附加属性
/**
 *  图片转换成NSData类型
 *
 *  @return 最终转化的二进制数据
 */
- (NSData *)data
{
    // 区分是png格式还是jpg格式,有的图片用这两个方法都可以转换，但是转换出来的png格式图片明显大于jpg格式，所以优先按照jpg转换
    NSData *imageData;
    
    if (UIImageJPEGRepresentation(self, 1)) {
        // JPEG图片
        imageData = UIImageJPEGRepresentation(self, 1);
    }else{
        // PNG图片
        imageData = UIImagePNGRepresentation(self);
    }
    
    return imageData;
}

#pragma mark - 编码
/**
 * 图片base64编码
 */
- (NSString *)base64Encode
{
    NSData *data = self.data;
    NSString *imageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    return imageStr;
}

// 占用的存储空间
- (CGFloat)spaceSize
{
    NSData *data = self.data;
    
    return (CGFloat)data.length/1024.0;
}

#pragma mark - 获取截屏
/**
 * 获取全屏截图
 */
+ (UIImage *)imageFullScreen
{
    UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContext(screenWindow.frame.size);//全屏截图，包括window
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    return viewImage;
}

/**
 * 获取屏幕指定区域的图片
 */
+ (UIImage *)imageWithRect:(CGRect)rect
{
    // 先截取全屏
    UIImage *fullScreenImg = [self imageFullScreen];
    
    // 获取指定区域图片
    CGImageRef ref = CGImageCreateWithImageInRect(fullScreenImg.CGImage, rect);
    UIImage *resultImage = [[UIImage alloc]initWithCGImage:ref];

    return resultImage;
}


/**
 * 截取图片的某一部分
 * rect 截取的区域
 */
- (UIImage *)clipImageInRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbScale;
}


#pragma mark - 获取颜色值
//获取图片某一点的颜色
- (UIColor *)imageColorAtPixel:(CGPoint)point
{
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast |     kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


#pragma mark - 获取图片格式
/**
 * 根据第一个字节获取图片的格式
 * data 图片的二进制数据(通过图片路径找到原图片转换成二进制)
 */
+ (NSString *)imageTypeWithImageData:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            if ([data length] < 12) {
                return nil;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return nil;
    }
    return nil;
}

#pragma mark - 图片等比例缩放
/**
 *  获取等比例缩放后图片的尺寸(为了让图片不变形要等比例缩放,这个方法返回的是根据给定的size计算出缩放后的size)
 *
 *  @param tagetSize 用户设置的要缩放的尺寸
 *
 *  @return 计算后最终缩放的尺寸(宽或者高和tagetSize相等)
 */
- (CGSize)imageSizeAfterEqualscaleZoomWithTagetSize:(CGSize)tagetSize
{
    CGSize cgSize = tagetSize;
    CGSize orgSize = self.size;
    double rate;
    
    // 放大或缩小图片
    double hRate = (cgSize.height / orgSize.height);
    double wRate = (cgSize.width / orgSize.width);
    rate = (hRate >= wRate ? hRate : wRate);
    CGSize newSize = CGSizeMake(orgSize.width * rate, orgSize.height * rate);
    
    return newSize;
}

/**
 *  等比例缩放图片
 *
 *  @param tagetSize  要缩放的大小
 *
 *  @return 缩放后的图片
 */
- (UIImage *)imageAfterEqualscaleZoomWithTagetSize:(CGSize)tagetSize
{
    // 计算等比例缩放后的尺寸
    CGSize newSize = [self imageSizeAfterEqualscaleZoomWithTagetSize:tagetSize];
    
    //根据获得的缩放尺寸缩放图片，获得缩放后图片
    UIImage *ratedImg = [self imageZoomToSize:newSize];
    
    return ratedImg;
}


/**
 *  通过绘图缩放图片
 *
 *  @param tagetSize 要缩放的尺寸
 *
 *  @return 缩放后的图片
 */
- (UIImage *)imageZoomToSize:(CGSize)tagetSize
{
    UIGraphicsBeginImageContext(tagetSize);
    [self drawInRect:CGRectMake(0, 0, tagetSize.width, tagetSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 *  等比例放大/缩小图片scale倍
 *
 *  @param scale 放大/缩小倍数
 *
 *  @return 处理后图片
 */
- (UIImage *)imageZoomToScale:(CGFloat)scale
{
    CIImage *image = self.CIImage;
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    CGSize newSize = CGSizeMake(self.size.width * scale, self.size.height * scale);
    UIGraphicsBeginImageContext(newSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    return codeImage;
}

#pragma mark - 图片裁剪
/**
 *  裁剪图片
 *
 *  @param tagetSize  目标大小
 *  @param edgeInsets 偏移区域
 *
 *  @return 裁剪后的图片
 */
- (UIImage *)imageAfterCutWithTagetSize:(CGSize)tagetSize edgeInsets:(UIEdgeInsets)edgeInsets
{
    // 获取等比例缩放后的尺寸
    CGSize newSize = [self imageSizeAfterEqualscaleZoomWithTagetSize:tagetSize];
    
    // 获取裁剪区域
    CGRect cutRect = [self getTailorImageRect:newSize size:tagetSize edgeInsets:edgeInsets];
    
    // 等比例缩放图片
    UIImage *ratedImg = [self imageAfterEqualscaleZoomWithTagetSize:tagetSize];
    
    // 裁剪图片
    UIImage *afterCutImage = [self cutImageFromImage:ratedImg inRect:cutRect];
    
    return afterCutImage;
}

/**
 *  获取图片裁剪区域，默认裁剪中间位置
 *
 *  @param zoomedSize 缩放后大小
 *  @param size       目标大小
 *  @param edgeInsets 偏移
 *
 *  @return 要裁减的区域
 */
- (CGRect)getTailorImageRect:(CGSize)zoomedSize size:(CGSize)size edgeInsets:(UIEdgeInsets )edgeInsets
{
    CGFloat edgeInsetsTop = edgeInsets.top;
    CGFloat edgeInsetsLeft = edgeInsets.left;
    CGFloat edgeInsetsBottom = edgeInsets.bottom;
    CGFloat edgeInsetsRight = edgeInsets.right;
    CGFloat horizontal = edgeInsetsRight - edgeInsetsLeft;  // 水平方向
    CGFloat Vertical = edgeInsetsBottom - edgeInsetsTop;    // 垂直方向
    
    int h = zoomedSize.height;
    int w = zoomedSize.width;
    
    
    CGFloat y;
    CGFloat x;
    
    // 如果图片被放大
    CGRect imageRect;
    if(h >= size.height || w >= size.width){
        y = (double)((h - size.height)/2) + Vertical;
        x = (double)((w - size.width)/2) + horizontal;
    }else{
        y = (double)((size.height - h)/2) + Vertical;
        x = (double)((size.width - w)/2) + horizontal;
    }
    
    // 如果制定区域越界
    x = x < 0 ? 0 : x;
    x = x > size.width ? size.width : x;
    
    y = y < 0 ? 0 : y;
    y = y > size.height ? size.height : y;
    
    imageRect = CGRectMake(x, y, size.width, size.height);
    
    return imageRect;
}

/**
 *  根据获取的裁剪区域裁剪图片
 *
 *  @param rect 裁剪区域
 *
 *  @return 裁剪后图片
 */
- (UIImage *)cutImageFromImage:newImage inRect:(CGRect)rect
{
    CGImageRef sourceImageRef = [newImage CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImg = [UIImage imageWithCGImage:newImageRef];
    return newImg;
}

#pragma mark - 图片存储和删除
/**
 *  存储图片,存储到document文件夹
 *
 *  @param imageName 存储的名字
 */
- (void)imageSaveToDocumentWithImageName:(NSString *)imageName
{
    // 路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingString:[NSString stringWithFormat:@"/%@",imageName]];
    
    
    // 存储图片
    NSData *data = self.data;
    [data writeToFile:path atomically:YES];
}

/**
 *  从document删除图片(对文件也适用)
 *
 *  @return 是否删除成功
 */
- (BOOL)deleteImageFromDocumentWithImageName:(NSString *)imageName
{
    // 获取路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingString:[NSString stringWithFormat:@"/%@",imageName]];
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL success = [fileManager removeItemAtPath:path error:&error];
    if (error) {
        success = NO;
    }
    
    return success;
}

/**
 *  保存图片到相册
 */
- (void)imageSaveToPhotoAlbum
{
    // 如果没有允许使用相册，提示设置为允许
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
        //无权限
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前相册不允许访问,请到设置->隐私->照片打开访问权限,开启后照片会自动存入相册" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 跳转到设置
            NSURL *url = [NSURL URLWithString:@"prefs:root=NOTIFICATI_ID"];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }]];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }else{
        UIImageWriteToSavedPhotosAlbum(self, nil, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

/**
 *  保存图片到相册回调方法
 *
 *  @param image       保存的图片
 *  @param error       错误
 *  @param contextInfo 其他信息
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - 图片拉伸
/**
 *  根据图片名字拉伸图片
 *
 *  @return 拉伸后的图片
 */
- (UIImage *)imageStretched
{
    UIImage *image;
    
    CGFloat TopCap = image.size.height * 0.5;
    CGFloat LeftCap = image.size.width * 0.5;
    
    image = [self stretchableImageWithLeftCapWidth:LeftCap topCapHeight:TopCap];
    return image;
}

#pragma mark - 根据图片URL获取图片的size
/**
 * 根据图片url获取图片尺寸
 * imageURL 图片url(NSString类型或者NSUrl类型)
 */
+ (CGSize)imageSizeWithURL:(id)imageURL
{
    // url处理
    NSURL* URL = nil;
    if([imageURL isKindOfClass:[NSURL class]]){
        URL = imageURL;
    }
    if([imageURL isKindOfClass:[NSString class]]){
        URL = [NSURL URLWithString:imageURL];
    }
    
    // url不正确返回CGSizeZero
    if(URL == nil)
        return CGSizeZero;
    
    
    // 判断图片类型
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    NSString* pathExtendsion = [URL.pathExtension lowercaseString];
    CGSize size = CGSizeZero;
    if([pathExtendsion isEqualToString:@"png"]){
        // png图片
        size =  [self getPNGImageSizeWithRequest:request];
    }else if([pathExtendsion isEqual:@"gif"]){
        // gif图片
        size =  [self getGIFImageSizeWithRequest:request];
    }else{
        // jpg等其他图片
        size = [self getJPGImageSizeWithRequest:request];
    }
    
    // 如果获取文件头信息失败,发送同步请求请求原图
    if(CGSizeEqualToSize(CGSizeZero, size) || size.width < 0 || size.height < 0){
        NSData* data = [NSData dataWithContentsOfURL:URL];
        UIImage* image = [UIImage imageWithData:data];
        if(image){
            size = image.size;
        }
    }
    
    return size;
}

//  请求文件头部信息获取PNG图片的大小
+ (CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest*)request
{
    // 只请求头部
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 8){
        int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        [data getBytes:&w3 range:NSMakeRange(2, 1)];
        [data getBytes:&w4 range:NSMakeRange(3, 1)];
        int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
        int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
        [data getBytes:&h1 range:NSMakeRange(4, 1)];
        [data getBytes:&h2 range:NSMakeRange(5, 1)];
        [data getBytes:&h3 range:NSMakeRange(6, 1)];
        [data getBytes:&h4 range:NSMakeRange(7, 1)];
        int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
        return CGSizeMake(w, h);
    }
    
    return CGSizeZero;
}

//  请求文件头部信息获取gif图片的大小
+ (CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 4){
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        short w = w1 + (w2 << 8);
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(2, 1)];
        [data getBytes:&h2 range:NSMakeRange(3, 1)];
        short h = h1 + (h2 << 8);
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}

//  请求文件头部信息获取jpg图片的大小
+ (CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if([data length] <= 0x58) {
        return CGSizeZero;
    }
    
    if([data length] < 210) {// 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    }else{
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {// 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}

#pragma mark - 图片压缩
/**
 * 二分法压缩图片质量(效率高)
 * 压缩图片质量尽量保留图片的清晰度，但是最终不一定能达到想要大小的图片,因为图片压缩到一定质量后就不会再被压缩
 * maxLength 限制的最大占用存储值(单位kb)
 */
- (UIImage *)imageCompressMidQualityWithLengthLimit:(NSInteger)maxLength
{
    NSData *data = [self compressMidQualityWithLengthLimit:maxLength * 1024];
    
    return [UIImage imageWithData:data];
}

// 压缩质量
- (NSData *)compressMidQualityWithLengthLimit:(NSInteger)maxLength{
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(self, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    return data;
}


/**
 * 压缩图片尺寸
 * 压缩图片尺寸可以达到想要大小的图片，但是图片的清晰度会变差，所以建议对清晰度要求高的只对图片进行质量压缩就可以了
 * maxLength 限制的最大占用存储值(单位kb)
 */
-(UIImage *)imageCompressBySizeWithLengthLimit:(NSInteger)maxLength
{
    NSData *data = [self compressBySizeWithLengthLimit:maxLength * 1024];
    
    return [UIImage imageWithData:data];
}

// 压缩尺寸
-(NSData *)compressBySizeWithLengthLimit:(NSUInteger)maxLength{
    UIImage *resultImage = self;
    NSData *data = UIImageJPEGRepresentation(resultImage, 1);
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        // Use image to draw (drawInRect:), image is larger but more compression time
        // Use result image to draw, image is smaller but less compression time
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, 1);
    }
    return data;
}

/**
 * 压缩图片(先压缩质量，再压缩尺寸,可以一定程度上保证图片的清晰度)
 * maxLength 限制的最大占用存储值(单位kb)
 */
- (UIImage *)imageCompressWithLengthLimit:(NSInteger)maxLength
{
    // 压缩质量
    NSData *data = [self compressMidQualityWithLengthLimit:maxLength * 1024];
    if (data.length/1024.0 < maxLength){

        // 只压缩质量获取到的二进制数据通过imageWithData重新转换成UIImage后大小大小和原图差不多，需要用compressBySizeWithLengthLimit压缩一下尺寸
        data = [self compressBySizeWithLengthLimit:data.length - 1];
        UIImage *image = [UIImage imageWithData:data];
        return image;
    }
    
    // 如果压缩完质量还没有达到想要的大小，压缩尺寸
    NSData *resultData = [self compressBySizeWithLengthLimit:maxLength * 1024];
    UIImage *newImage = [UIImage imageWithData:resultData];
    NSData *returnData = newImage.data;
    return newImage;
}

/**
 *  压缩图片
 *
 *  @param scale 图片压缩后的大小,单位kb
 *
 *  @return 压缩后的图片
 */
- (UIImage *)imageCompressWithScale:(NSUInteger)scale
{
    // 路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingString:@"/tempImage.jpg"];
//    HYLog(@"path:%@",path);
    
    // 存储图片
    NSData *data = [self dataFromImage];
    [data writeToFile:path atomically:YES];
//    HYLog(@"%lu",(unsigned long)data.length);
    
    // 取出存储后的jpg图片
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    NSData *da = [img dataFromImage];
    
    NSUInteger scal = scale * 1024;
    if (da.length <= scal)  return img;
    
    // 计算压缩比率
    CGFloat legth = [[NSString stringWithFormat:@"%lu",(unsigned long)da.length] floatValue];
    float f = (da.length - scal)/legth;
    
    // 压缩
    da = UIImageJPEGRepresentation(img, 1-f);
//    HYLog(@"length:%lu",(unsigned long)da.length);
    
    // 删除保存的图片
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL remove = [fileManager removeItemAtPath:path error:&error];
    
    if (!remove) {
//        HYLog(@"删除文件错误");
    }
    
    if (error) {
//        HYLog(@"删除文件错误：%@",error);
    }
    
    UIImage *resultImage = [UIImage imageWithData:da];
    NSData *resultData = [resultImage dataFromImage];
    return resultImage;
}

/**
 *  图片转换成NSData类型
 *
 *  @return 最终转化的二进制数据
 */
- (NSData *)dataFromImage
{
    NSData *imageData;
//    if (UIImagePNGRepresentation(self)) {
//        // PNG图片
//        imageData = UIImagePNGRepresentation(self);
//    }else{
//        // JPEG图片
//        imageData = UIImageJPEGRepresentation(self, 1);
//    }
    
    if (UIImageJPEGRepresentation(self, 1)) {
        // JPEG图片
        imageData = UIImageJPEGRepresentation(self, 1);
    }else{
        // PNG图片
        imageData = UIImagePNGRepresentation(self);
    }
    
    return imageData;
}

@end
