//
//  ZBFuzzyImageViewController.m
//  ZB_FuzzyImageDemo
//
//  Created by Sangxiedong on 2018/8/11.
//  Copyright © 2018年 ZB. All rights reserved.
//
#define ScreenWidth               [UIScreen mainScreen].bounds.size.width
#define ScreenHeight              [UIScreen mainScreen].bounds.size.height
#import "ZBFuzzyImageViewController.h"
#import "ZBFuzzyImageView.h"
#import "ZBFuzzyFooterView.h"

@interface ZBFuzzyImageViewController () <ZBFuzzyFooterViewDelegate> {
    CGRect _imageViewFrame;
}

@property (nonatomic, strong) UIImage *editingImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) ZBFuzzyImageView *fuzzyImageView;
@property (nonatomic, strong) ZBFuzzyFooterView *footerView;

@end

@implementation ZBFuzzyImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"模糊";
    self.view.backgroundColor = [UIColor whiteColor];
    self.editingImage = [UIImage imageNamed:@"textImage.jpg"];
    [self configImageViewFrame];
    [self configImageView];
    [self configFooterView];
}

#pragma mark - CreateUI
- (void)configImageViewFrame {
    CGFloat height = ScreenHeight - 105 - 20; // 中间空白区域的总高度（展示图片区域）
    CGFloat imageWidth = self.editingImage.size.width;
    CGFloat imageHeight = self.editingImage.size.height;
    CGFloat scale = imageWidth / imageHeight;
    CGRect frame;
    if (scale >= 1) {
        frame = CGRectMake(0, 74 + (height - ScreenWidth / scale) / 2, ScreenWidth, ScreenWidth / scale);
    }else {
        CGFloat tempWidth = height * scale;
        if (tempWidth <= ScreenWidth) {
            frame = CGRectMake((ScreenWidth - tempWidth) / 2, 74, tempWidth, height);
        }else {
            CGFloat tempHeight = ScreenWidth / scale;
            frame = CGRectMake(0, 74 + (height - ScreenWidth / scale) / 2, ScreenWidth, tempHeight);
        }
    }
    _imageViewFrame = frame;
}

- (void)configImageView {
    self.fuzzyImageView = [[ZBFuzzyImageView alloc]initWithFrame:_imageViewFrame];
    self.fuzzyImageView.image = self.editingImage;
    __weak typeof(self) weakSelf = self;
    self.fuzzyImageView.repealButtonEnableClick = ^(BOOL canClick) {
        weakSelf.footerView.canRepeal = canClick;
    };
    [self.view addSubview:self.fuzzyImageView];
}

- (void)configFooterView {
    CGFloat height = 105;
    self.footerView = [[ZBFuzzyFooterView alloc]initWithFrame:CGRectMake(0, ScreenHeight - height, ScreenWidth, height)];
    self.footerView.delegate = self;
    [self.view addSubview:self.footerView];
}

#pragma mark - FuzzyImageViewDelegate
- (void)changeSizeOfFuzzySliderValue:(CGFloat)value AndTag:(NSInteger)tag {
    if (tag == 0) {
        self.fuzzyImageView.fuzzySizeValue = value;
    }else if (tag == 1) {
        self.fuzzyImageView.fuzzyDegreeValue = value;
    }
}

- (void)repealLastButtonAction {
    [self.fuzzyImageView repealLastButtonAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
