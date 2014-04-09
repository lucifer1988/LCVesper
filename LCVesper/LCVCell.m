//
//  LCVCell.m
//  LCVesper
//
//  Created by liuyi on 14-4-8.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "LCVCell.h"

NSString *const kVesperCell = @"VesperCell";

@implementation LCVCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addObserver:self forKeyPath:@"imgViewWidthLayoutConstraint" options:NSKeyValueObservingOptionInitial context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"imgViewWidthLayoutConstraint"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"imgViewWidthLayoutConstraint"]) {
        _oldWidthLayoutConstraint = _imgViewWidthLayoutConstraint.constant;
    }
}

@end
