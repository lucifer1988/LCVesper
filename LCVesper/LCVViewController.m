//
//  LCVViewController.m
//  LCVesper
//
//  Created by liuyi on 14-4-8.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "LCVViewController.h"
#import "LCVCell.h"
#import "LCVItem.h"
#import "LCVDetailViewController.h"
#import "UITableView+Frames.h"

@interface LCVViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *items;

@end

NSString *const popToListNotification = @"kPopToListNotification";
static NSIndexPath *selectedIndex = nil;

@implementation LCVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _items = [NSMutableArray arrayWithCapacity:0];
    
    @autoreleasepool {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Assassins List" ofType:@"plist"];
        NSArray *items = [[NSArray alloc] initWithContentsOfFile:path];
        for (NSDictionary *dict in items) {
            LCVItem *item = [[LCVItem alloc] init];
            item.img = [UIImage imageNamed:[dict objectForKey:@"image"]];
            item.content = [dict objectForKey:@"content"];
            [_items insertObject:item atIndex:0];
        }
    }
    
    [_tableView registerNib:[UINib nibWithNibName:@"LCVCell" bundle:nil] forCellReuseIdentifier:kVesperCell];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToList:) name:popToListNotification object:NULL];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [_tableView addGestureRecognizer:longPress];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:popToListNotification object:NULL];
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LCVCell *cell = [tableView dequeueReusableCellWithIdentifier:kVesperCell];
    
    LCVItem *item = [_items objectAtIndex:indexPath.row];
    
    if (item.img) {
        cell.imgViewWidthLayoutConstraint.constant = cell.oldWidthLayoutConstraint;
        [cell layoutIfNeeded];
        cell.imgView.image = item.img;
    }
    else {
        cell.imgViewWidthLayoutConstraint.constant = 0.0;
        [cell layoutIfNeeded];
    }
    
    cell.titleLabel.text = item.content;
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[tableView cellForRowAtIndexPath:indexPath] setHidden:YES];
    selectedIndex = indexPath;
    
    LCVDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LCVDetailViewController"];
    controller.item = [_items objectAtIndex:indexPath.row];
    controller.sourceFrames = [tableView framesForRowAtIndexPath:indexPath];
    [self.navigationController pushViewController:controller animated:NO];
}

- (void)popToList:(id)sender
{
    [[_tableView cellForRowAtIndexPath:selectedIndex] setHidden:NO];
}

- (void)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [_tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    
                } completion:^(BOOL finished) {
                    cell.hidden = YES;
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                [_items exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [_tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:sourceIndexPath];
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                
            } completion:^(BOOL finished) {
                cell.hidden = NO;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            sourceIndexPath = nil;
            break;
        }
    }
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

@end
