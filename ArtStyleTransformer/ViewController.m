//
//  ViewController.m
//  ArtStyleTransformer
//
//  Created by terence on 2019/7/1.
//  Copyright © 2019年 terence. All rights reserved.
//

#import "ViewController.h"
#import "la_muse.h"
#import "rain_princess.h"
#import "udnie.h"
#import "wave.h"
#import "StyleTransfer.h"
#import <CoreML/CoreML.h>
#import <Vision/Vision.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>

#define WeakSelf __weak typeof(self) weakSelf = self;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UIImage *image=[UIImage imageNamed:@"imgtest.jpeg"];
    [self changeImage:image toStyle:4];
    
}


    
    
    
-(void)changeImage:(UIImage *)image toStyle:(int)style{
    CGSize osize = image.size;
    CVPixelBufferRef img = [self scaleToSize:image size:CGSizeMake(883, 720)];
    CVPixelBufferRef img2 = [self scaleToSize:image size:CGSizeMake(256, 256)];

    
    
    VNCoreMLModel *vnCoreMMModel;
    NSError *error = nil;
    
    
    if (style==0) {
        la_muse *model = [[la_muse alloc]init];
        la_museInput *input = [[la_museInput alloc]initWithImg_placeholder__0:img];
        
        la_museOutput *output =[model predictionFromFeatures:input error:nil];
        
        UIImage *resultImage = [self imageFromPixelBuffer:[output featureValueForName:@"add_37__0"].imageBufferValue];
        UIImageView *imgView = [[UIImageView alloc]initWithImage:resultImage];
        imgView.frame=CGRectMake(10, 10, osize.width, osize.height);
        [self.view addSubview:imgView];
        
    }
    if (style==1) {
        rain_princess *model = [[rain_princess alloc]init];
        rain_princessInput *input = [[rain_princessInput alloc]initWithImg_placeholder__0:img];
        
        rain_princessOutput *output =[model predictionFromFeatures:input error:nil];
        
        rain_princessOutput *output2 = [model predictionFromImg_placeholder__0:img error:nil];
        
        
        UIImage *resultImage = [self convert:output2.add_37__0];
        UIImageView *imgView = [[UIImageView alloc]initWithImage:resultImage];
        imgView.frame=CGRectMake(10, 10, osize.width, osize.height);
        [self.view addSubview:imgView];
    }
    if (style==2) {
        udnie *model = [[udnie alloc]init];
        vnCoreMMModel = [VNCoreMLModel modelForMLModel:model.model error:&error];
    }
    if (style==3) {
        wave *model = [[wave alloc]init];
        vnCoreMMModel = [VNCoreMLModel modelForMLModel:model.model error:&error];

    }
    if(style == 4){
        StyleTransfer *model = [[StyleTransfer alloc]init];
        MLMultiArray *styleArray = [[MLMultiArray alloc]initWithShape:@[@3] dataType:MLMultiArrayDataTypeDouble error:nil];
        
        for (int i = 0; i<styleArray.count; i++) {
            styleArray[i]=@0.0;
            
        }
        styleArray[0]=@1.0;
        StyleTransferOutput *output = [model predictionFromImage:img2 index:styleArray error:nil];
        
        UIImage *resultImage = [self imageFromPixelBuffer:output.stylizedImage];
        UIImageView *imgView = [[UIImageView alloc]initWithImage:resultImage];
        imgView.frame=CGRectMake(10, 10, osize.width, osize.height);
        [self.view addSubview:imgView];
        
        
        
        
    }

    
    
    
    
    
    // 创建处理requestHandler
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:img options:@{}];
    
    WeakSelf
    // 创建request
    VNCoreMLRequest *request = [[VNCoreMLRequest alloc] initWithModel:vnCoreMMModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        //CGImageRef image=[weakSelf imageFromCVPixelBufferRef0:request.results[0]];
        NSArray *array = request.results;
        NSLog([array objectAtIndex:0]);

        //CFBridgingRetain([request.results objectAtIndex:0]);

    }];
    
    
    
    // 发送识别请求
    [handler performRequests:@[request] error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
}

    
    
    

    

    

    
    
    
    
    
    
/***
    private func pixelBuffer(cgImage: CGImage, width: Int, height: Int) -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
        if status != kCVReturnSuccess {
            fatalError("Cannot create pixel buffer for image")
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue)
        let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer!
    }
***/

    
    
-(CVPixelBufferRef)makePixelBufferFromCGImage:(CGImageRef)cgImage{
    CVPixelBufferRef pxbuffer = NULL;
    CGFloat frameWidth = CGImageGetWidth(cgImage);
    CGFloat frameHeight = CGImageGetHeight(cgImage);

    //let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32BGRA,
                                          nil,
                                          &pxbuffer);
    if (status != kCVReturnSuccess) {
        NSLog(@"Cannot create pixel buffer for image");
    }

    CVPixelBufferLockBaseAddress(pxbuffer, 1);
    void *data = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();

    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little|kCGImageAlphaFirst;


    
//    let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
    CGContextRef context = CGBitmapContextCreate(data,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 bitmapInfo);

    //NSParameterAssert(context);
    CGContextDrawImage(context, CGRectMake(0, 0, frameWidth, frameHeight), cgImage);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 1);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    return pxbuffer;

}
    


    

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
{
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    NSDictionary *options = @{
                              (__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey: @(NO),
                              (__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @(NO)
                              };
    CVPixelBufferRef pixelBuffer;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height,  kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pixelBuffer);
    if (status != kCVReturnSuccess) {
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *data = CVPixelBufferGetBaseAddress(pixelBuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, frameSize.width, frameSize.height,
                                                 8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace,
                                                 (CGBitmapInfo) kCGImageAlphaNoneSkipFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return pixelBuffer;
}










    
    
//改变图片的size
- (CVPixelBufferRef)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    
    return [self pixelBufferFromCGImage:scaledImage.CGImage];
    //return scaledImage;
    
    
}







- (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef {
    
    CGImageRef img = NULL;
    

//    VTCreateCGImageFromCVPixelBuffer(pixelBufferRef, nil, img);
//    UIImage *image = [UIImage imageWithCGImage:img];
//    CGImageRelease(img);
//    size_t bufferSize = CVPixelBufferGetDataSize(pixelBufferRef);
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBufferRef, 0);
//    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
//    CGDataProviderRelease(provider);
//    CGColorSpaceRelease(rgbColorSpace);
//    CVPixelBufferUnlockBaseAddress(pixelBufferRef, 0);
//    return image;
    
    
    CVPixelBufferRef imageBuffer =  pixelBufferRef;
    

    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, rgbColorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrderDefault, provider, NULL, true, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(rgbColorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return image;
}
    
    
    
    
    
    //other
    
- (UIImage *)convert:(CVPixelBufferRef)pixelBuffer {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
    
    UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    return uiImage;
}

@end
