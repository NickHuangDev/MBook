//
//  CGLAddCategoryViewController.m
//  MBook - Just Accounting
//
//  Created by 黃琮淵 on 2014/10/3.
//  Copyright (c) 2014年 Nick. All rights reserved.
//

#import "CGLAddCategoryViewController.h"

#import "KindEntity.h"
#import "CategoryEntity.h"

@interface CGLAddCategoryViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *checkIconImageView;
@property (strong, nonatomic) IBOutlet UIView *checkMarkView;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UIImageView *colorWheelImageView;
@property (strong, nonatomic) UIColor *markColor;

- (IBAction)tapRecognizer:(UITapGestureRecognizer *)sender;
- (IBAction)panRecognizer:(UIPanGestureRecognizer *)sender;
- (IBAction)cancelAddCategory:(UIBarButtonItem *)sender;
- (IBAction)saveCategory:(UIBarButtonItem *)sender;


- (void)drawColorWheel;
- (void)checkPointOnColor:(CGPoint )point;
- (void)getRGBAFromImage:(UIImage *)image atX:(int)xx andY:(int)yy;
- (void)drawMarkAndColorInLayer:(CAShapeLayer *)shapeLayer withColor:(UIColor *)markColor;
@end

@implementation CGLAddCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.colorWheelImageView setUserInteractionEnabled:YES];
    [self drawColorWheel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapRecognizer:(UITapGestureRecognizer *)sender {
    [self checkPointOnColor:[sender locationInView:self.colorWheelImageView]];
}

- (IBAction)panRecognizer:(UIPanGestureRecognizer *)sender {
    [self checkPointOnColor:[sender locationInView:self.colorWheelImageView]];
}

- (IBAction)cancelAddCategory:(UIBarButtonItem *)sender {
    [self cancelAndDismiss];
}

- (IBAction)saveCategory:(UIBarButtonItem *)sender {
    //KeyedArchiver markcolor
    NSData *markColorData = [NSKeyedArchiver archivedDataWithRootObject:self.markColor];
    
    self.addCategoryEntity.kind = self.selectedKindEntity;
    self.addCategoryEntity.categoryName = self.nameField.text;
    self.addCategoryEntity.categoryColor = markColorData;
    [self saveAndDismiss];
}

#pragma mark - Custom Method
- (void)drawColorWheel {
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {1.0, 0.0, 0.0, 1.0,
        1.0, 1.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 1.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        1.0, 0.0, 1.0, 1.0,
        1.0, 0.0, 0.0, 1.0};
    
    CGFloat locations[] = {0.0, 0.16, 0.33, 0.50, 0.66, 0.82, 1.0};
    size_t count = 7;
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, components, locations, count);
    CGColorSpaceRelease(rgb);
    
    UIGraphicsBeginImageContext(self.colorWheelImageView.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, 125), 0);
    UIImage *paletteImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGFloat GrayComponents[] = {1.0, 1.0, 1.0, 1.0,
        0.5, 0.5, 0.5, 1.0,
        0.2, 0.2, 0.2, 1.0,
        0.0, 0.0, 0.0, 1.0};
    
    CGFloat GrayLocations[] = {0.0, 0.5, 0.9, 1.0};
    count = 4;
    
    gradient = CGGradientCreateWithColorComponents(rgb, GrayComponents, GrayLocations, count);
    CGColorSpaceRelease(rgb);
    
    UIGraphicsBeginImageContext(self.colorWheelImageView.bounds.size);
    context = UIGraphicsGetCurrentContext();
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0, 0.0), CGPointMake(320.0, 0), 0);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGRect drawRect = CGRectMake(0.0, 0.0, self.colorWheelImageView.frame.size.width, self.colorWheelImageView.frame.size.height);
    CGContextDrawImage(context, drawRect, paletteImage.CGImage);
    CGContextSaveGState(context);
    
    self.colorWheelImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

- (void)checkPointOnColor:(CGPoint )point {
    CGFloat x, y;
        
    x = point.x;
    y = point.y;
        
    if ((x >= 0) && (x <= self.colorWheelImageView.frame.size.width) && (y >= 0) && (y <= self.colorWheelImageView.frame.size.height)) {
        [self getRGBAFromImage:self.colorWheelImageView.image atX:x andY:y];
        }
}

- (void)getRGBAFromImage:(UIImage *)image atX:(int)xx andY:(int)yy {
    
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    NSUInteger byteIndex = (bytesPerRow * yy) + (bytesPerPixel * xx);
    
    float red   = (float)(rawData[byteIndex]) / 255;
    float green = (float)rawData[byteIndex + 1] / 255;
    float blue  = (float)rawData[byteIndex + 2] / 255;
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    self.markColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    [self drawMarkAndColorInLayer:shapeLayer withColor:self.markColor];
    [self.checkMarkView.layer addSublayer:shapeLayer];
    NSLog(@"%@", self.checkMarkView.layer);
    free(rawData);
}

- (void)drawMarkAndColorInLayer:(CAShapeLayer *)shapeLayer withColor:(UIColor *)markColor {
    //Draw BezierPath
    UIBezierPath *markPath=[[UIBezierPath alloc] init];
    UIBezierPath *detailMarkPath=[[UIBezierPath alloc] init];
    [markPath appendPath:detailMarkPath];
    
    [markPath moveToPoint:CGPointMake(0, 0)];
    [markPath addLineToPoint:CGPointMake(26, 0)];
    [markPath addLineToPoint:CGPointMake(26, 30)];
    [markPath addLineToPoint:CGPointMake(13, 50)];
    [markPath addLineToPoint:CGPointMake(0, 30)];
    [markPath addLineToPoint:CGPointMake(0, 0)];
    
    shapeLayer.path=markPath.CGPath;
    
    shapeLayer.strokeColor=markColor.CGColor;
    shapeLayer.fillColor=markColor.CGColor;
    shapeLayer.lineWidth=1.0;
}

@end
