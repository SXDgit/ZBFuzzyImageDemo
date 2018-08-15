//
//  ZBFuzzyImageView.m
//  ZB_FuzzyImageDemo
//
//  Created by Sangxiedong on 2018/8/11.
//  Copyright © 2018年 ZB. All rights reserved.
//

#import "ZBFuzzyImageView.h"
#import <Accelerate/Accelerate.h>

@interface ZBFuzzyImageView () {
    BOOL _fuzzyStatus;
    CGPoint _currentPoint;
    CGFloat _fuzzyWith;
    NSMutableArray *_pathArray;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *editImageArray;
@property (nonatomic, strong) UIView *brushView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) CGMutablePathRef path;

@end

@implementation ZBFuzzyImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        _fuzzySizeValue = 0.7;
        _fuzzyDegreeValue = 0.5;
        _fuzzyStatus = NO;
        self.editImageArray = [NSMutableArray arrayWithCapacity:0];
        _pathArray = [NSMutableArray arrayWithCapacity:0];
        [self addSubview:self.imageView];
        [self configBrushView];
        
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _imageView.image = _image;
    [_editImageArray addObject:_image];
}

- (void)setFuzzySizeValue:(CGFloat)fuzzySizeValue {
    _fuzzySizeValue = fuzzySizeValue;
}

- (void)setFuzzyDegreeValue:(CGFloat)fuzzyDegreeValue {
    _fuzzyDegreeValue = fuzzyDegreeValue;
}

#pragma mark - 添加图层
- (void)addCAShapeLayer {
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = self.imageView.bounds;
    [self.imageView.layer addSublayer:imageLayer];
    
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.frame = self.imageView.bounds;
    _shapeLayer.lineCap = kCALineCapRound;
    _shapeLayer.lineJoin = kCALineJoinRound;
    _fuzzyWith = (34 * _fuzzySizeValue) + 8;
    _shapeLayer.lineWidth = _fuzzyWith;
    _shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
    _shapeLayer.fillColor = nil;
    [self.imageView.layer addSublayer:_shapeLayer];
    
    imageLayer.mask = _shapeLayer;
    
    self.path = CGPathCreateMutable();
    UIImage *img1 = [self blurryImage:self.imageView.image withBlurLevel:_fuzzyDegreeValue];
    imageLayer.contents = (id)img1.CGImage;
}

#pragma mark - 高斯模糊
- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    NSData *imageData = UIImageJPEGRepresentation(image, 1); // convert to jpeg
    UIImage* destImage = [UIImage imageWithData:imageData];
    
    int boxSize = (int)(blur * 100);
    if (blur > 0.5) {
        boxSize = (int)(blur * 100) + 50;
    }else if (blur <= 0.5) {
        boxSize = (int)(blur * 100);
    }
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = destImage.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    
    //create vImage_Buffer with data from CGImageRef
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self addCAShapeLayer];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.imageView];
    //开始一条可变路径，
    CGPathMoveToPoint(self.path, NULL, point.x, point.y);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
    _shapeLayer.path = path;
    CGPathRelease(path);
    
    _brushView.hidden = NO;
    _currentPoint = point;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.imageView];
    //路径追加
    CGPathAddLineToPoint(self.path, NULL, point.x, point.y);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
    _shapeLayer.path = path;
    CGPathRelease(path);
    
    _brushView.frame = CGRectMake(point.x - _fuzzyWith / 2, point.y - _fuzzyWith / 2, _fuzzyWith, _fuzzyWith);
    _brushView.layer.cornerRadius = _fuzzyWith / 2;
    [_brushView bringSubviewToFront:self];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.imageView.image = [self saveImage];
    self.nowImage = self.imageView.image;
    _brushView.hidden = YES;
    [_editImageArray addObject:self.nowImage];
    if (!_fuzzyStatus) {
        if (self.repealButtonEnableClick) {
            self.repealButtonEnableClick(YES);
        }
    }
    _fuzzyStatus = YES;
}

-  (UIImage *)saveImage {
    CGSize size = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [self.imageView.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)configBrushView {
    self.brushView = [[UIView alloc]init];
    _brushView.backgroundColor = [UIColor clearColor];
    _brushView.layer.masksToBounds = YES;
    _brushView.layer.borderWidth = 1;
    _brushView.layer.borderColor = [UIColor whiteColor].CGColor;
    _brushView.hidden = YES;
    [self addSubview:_brushView];
}

#pragma mark - 撤销操作
- (void)repealLastButtonAction {
    NSInteger index = [_editImageArray indexOfObject:self.imageView.image];
    if (index != 0) {
        self.imageView.layer.sublayers = nil;
        self.imageView.image = _editImageArray[index - 1];
        self.nowImage = self.imageView.image;
        [_editImageArray removeLastObject];
        
        if (_editImageArray.count == 1) {
            if (self.repealButtonEnableClick) {
                self.repealButtonEnableClick(NO);
            }
            _fuzzyStatus = NO;
        }
    }
}

#pragma mark - 懒加载
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

@end
