//
//  ZBFuzzyFooterView.h
//  ZB_FuzzyImageDemo
//
//  Created by Sangxiedong on 2018/8/11.
//  Copyright © 2018年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZBFuzzyFooterViewDelegate <NSObject>

- (void)changeSizeOfFuzzySliderValue:(CGFloat)value AndTag:(NSInteger)tag;
- (void)repealLastButtonAction;

@end

@interface ZBFuzzyFooterView : UIView

@property (nonatomic, assign) BOOL canRepeal; // 模糊操作是否可以撤回
@property (nonatomic, weak) id<ZBFuzzyFooterViewDelegate>delegate;

@end
