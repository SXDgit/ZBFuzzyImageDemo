//
//  ZBFuzzyImageView.h
//  ZB_FuzzyImageDemo
//
//  Created by Sangxiedong on 2018/8/11.
//  Copyright © 2018年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RepealButtonEnableClick)(BOOL canClick);
@interface ZBFuzzyImageView : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *nowImage;
@property (nonatomic, assign) CGFloat fuzzySizeValue;
@property (nonatomic, assign) CGFloat fuzzyDegreeValue;
@property (nonatomic, copy) RepealButtonEnableClick repealButtonEnableClick;

- (void)repealLastButtonAction;

@end
