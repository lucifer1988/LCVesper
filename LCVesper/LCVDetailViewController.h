//
//  LCVDetailViewController.h
//  LCVesper
//
//  Created by liuyi on 14-4-8.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LCVItem;

@interface LCVDetailViewController : UIViewController

@property (strong, nonatomic) LCVItem *item;
@property (strong, nonatomic) NSDictionary *sourceFrames;

@end
