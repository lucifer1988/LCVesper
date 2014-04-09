//
//  LCVCell.h
//  LCVesper
//
//  Created by liuyi on 14-4-8.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kVesperCell;

@interface LCVCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgViewWidthLayoutConstraint;
@property (nonatomic) CGFloat oldWidthLayoutConstraint;

@end
