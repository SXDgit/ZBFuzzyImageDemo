//
//  ZBFuzzyFooterView.m
//  ZB_FuzzyImageDemo
//
//  Created by Sangxiedong on 2018/8/11.
//  Copyright © 2018年 ZB. All rights reserved.
//
#define ScreenWidth               [UIScreen mainScreen].bounds.size.width
#define ScreenHeight              [UIScreen mainScreen].bounds.size.height
#import "ZBFuzzyFooterView.h"

@interface ZBFuzzyFooterView () {
    UIButton *_fuzzyRepealButton;
    UILabel *_numberLabel;
    BOOL _enableClick;
}

@property (nonatomic, strong) UIView *contentView;

@end

@implementation ZBFuzzyFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self configFuzzyView];
    }
    return self;
}

#pragma mnark - CreateUI
- (void)configFuzzyView {
    _enableClick = NO;
    UILabel *brushLabel = [self createLabelWithTitle:@"画笔" AndFrame:CGRectMake(20, 24, 30, 13)];
    [self addSubview:brushLabel];
    
    _fuzzyRepealButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _fuzzyRepealButton.frame = CGRectMake(ScreenWidth - 60, 11, 40, 40);
    [_fuzzyRepealButton setImage:[UIImage imageNamed:@"icon_photo_repealLast_normal"] forState:UIControlStateNormal];
    [_fuzzyRepealButton addTarget:self action:@selector(withdrawButtonAction) forControlEvents:UIControlEventTouchUpInside];
    _fuzzyRepealButton.imageEdgeInsets = UIEdgeInsetsMake(12.5, 23, 12.5, 0);
    [self addSubview:_fuzzyRepealButton];
    
    UISlider *brushSlider = [self createSliderWithFrame:CGRectMake(CGRectGetMaxX(brushLabel.frame) + 10, 21, ScreenWidth - 60 - 70, 20) AndTag:60];
    [self addSubview:brushSlider];
    
    UILabel *fuzzyLabel = [self createLabelWithTitle:@"硬度" AndFrame:CGRectMake(20, CGRectGetMaxY(brushLabel.frame) + 24, 30, 13)];
    [self addSubview:fuzzyLabel];
    
    UISlider *fuzzySlider = [self createSliderWithFrame:CGRectMake(CGRectGetMaxX(brushLabel.frame) + 10, CGRectGetMaxY(brushSlider.frame) + 19, ScreenWidth - 60 - 70, 20) AndTag:61];
    [self addSubview:fuzzySlider];
    
    _numberLabel = [self createLabelWithTitle:@"50%" AndFrame:CGRectMake(ScreenWidth - 50, CGRectGetMaxY(brushLabel.frame) + 24, 50, 13)];
    [self addSubview:_numberLabel];
}

#pragma mark - Action
- (void)changeFuzzySliderValue:(UISlider *)slider {
    NSInteger index = slider.tag - 60;
    NSInteger value = slider.value * 100;
    if (index == 0) {
        if ([self.delegate respondsToSelector:@selector(changeSizeOfFuzzySliderValue:AndTag:)]) {
            [self.delegate changeSizeOfFuzzySliderValue:slider.value AndTag:index];
        }
    }else if (index == 1) {
        _numberLabel.text = [NSString stringWithFormat:@"%ld%%", value];
        if ([self.delegate respondsToSelector:@selector(changeSizeOfFuzzySliderValue:AndTag:)]) {
            [self.delegate changeSizeOfFuzzySliderValue:slider.value AndTag:index];
        }
    }
}

- (void)withdrawButtonAction {
    if (!_enableClick) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(repealLastButtonAction)]) {
        [self.delegate repealLastButtonAction];
    }
}

- (void)setCanRepeal:(BOOL)canRepeal {
    _canRepeal = canRepeal;
    _enableClick = _canRepeal;
    if (canRepeal) {
        [_fuzzyRepealButton setImage:[UIImage imageNamed:@"icon_photo_repealLast_selected"] forState:UIControlStateNormal];
    }else {
        [_fuzzyRepealButton setImage:[UIImage imageNamed:@"icon_photo_repealLast_normal"] forState:UIControlStateNormal];
    }
}

#pragma mark - Methods
- (UILabel *)createLabelWithTitle:(NSString *)title AndFrame:(CGRect)frame {
    UILabel *label = [[UILabel alloc]init];
    label.frame = frame;
    label.text = title;
    label.font = [UIFont systemFontOfSize:13];
    return label;
}

- (UISlider *)createSliderWithFrame:(CGRect)frame AndTag:(NSInteger)tag {
    UISlider *slider = [[UISlider alloc] initWithFrame:frame];
    slider.maximumTrackTintColor = [UIColor lightTextColor];
    slider.minimumTrackTintColor = [UIColor blueColor];
    slider.minimumValue = 0.0;
    slider.maximumValue = 1.0;
    slider.value = 0.5;
    slider.tag = tag;
    [slider setThumbImage:[UIImage imageNamed:@"icon_slider_button"] forState:UIControlStateNormal];
    [slider addTarget:self action:@selector(changeFuzzySliderValue:) forControlEvents:UIControlEventValueChanged];
    return slider;
}

@end
