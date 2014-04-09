//
//  LCVDetailViewController.m
//  LCVesper
//
//  Created by liuyi on 14-4-8.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "LCVDetailViewController.h"
#import "LCVViewController.h"
#import "LCVItem.h"

@interface LCVDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *detailBgView;
@property (weak, nonatomic) IBOutlet UIScrollView *detailScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *detailImgView;
@property (weak, nonatomic) IBOutlet UILabel *detailContentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailImgHeightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailLabelHeightLayoutConstraint;

@property (strong, nonatomic) UIColor *backgroundColor;
@property (assign, nonatomic) CGFloat animationDuration;
@property (strong, nonatomic) NSDictionary *targetFrames;

@end


@implementation LCVDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_item) {
        if (_item.img) {
           _detailImgView.image = _item.img;
        }
        else {
           _detailImgHeightLayoutConstraint.constant = 0.0;
        }
        
        _detailContentLabel.text = _item.content;
        
        CGRect textViewFrame = _detailContentLabel.frame;
        NSDictionary *attribute = @{NSFontAttributeName:_detailContentLabel.font};
        CGRect rect = [_item.content boundingRectWithSize:CGSizeMake(textViewFrame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil];
        _detailScrollView.contentSize = CGSizeMake(CGRectGetWidth(_detailScrollView.frame), CGRectGetMaxY(_detailContentLabel.frame)+rect.size.height+30);
        
        _detailLabelHeightLayoutConstraint.constant = rect.size.height;
        [_detailContentLabel layoutIfNeeded];
    }
    
    _detailBgView.backgroundColor = _backgroundColor;
    [self __buildTargetFrames];
    [self __switchToSourceFrames:YES];
    [UIView animateWithDuration:_animationDuration animations:^{
        [self __switchToSourceFrames:NO];
    }];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, YES, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [window.layer renderInContext:context];
        _backgroundColor = [UIColor colorWithPatternImage:UIGraphicsGetImageFromCurrentImageContext()];
        UIGraphicsEndImageContext();
        
        _animationDuration = 0.3f;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close:(id)sender
{
    [UIView animateWithDuration:_animationDuration animations:^{
        [self __switchToSourceFrames:YES];
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:popToListNotification object:NULL];
        _detailScrollView.alpha = 0;
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

#pragma mark - Private

- (void)__buildTargetFrames
{
    NSMutableDictionary *frames = [NSMutableDictionary dictionary];
    
    [frames setObject:[NSValue valueWithCGRect:_detailImgView.frame] forKey:@"img"];
    [frames setObject:[NSValue valueWithCGRect:_detailContentLabel.frame] forKey:@"content"];
    
    _targetFrames = [NSDictionary dictionaryWithDictionary:frames];
}

- (void)__switchToSourceFrames:(BOOL)isSource
{
    NSDictionary *frames = nil;
    if (isSource) {
        frames = _sourceFrames;
        _detailBgView.alpha = 1;
    } else {
        frames = _targetFrames;
        _detailBgView.alpha = 0;
    }
    
    _detailImgView.frame = [[frames objectForKey:@"img"] CGRectValue];
    _detailContentLabel.frame = [[frames objectForKey:@"content"] CGRectValue];
}

@end
