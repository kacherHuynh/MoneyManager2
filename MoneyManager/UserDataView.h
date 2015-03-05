//
//  UserDataView.h
//  MoneyManager
//
//  Created by hh.tai on 2/23/15.
//  Copyright (c) 2015 hh.tai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLabel.h"
#import "ViewController.h"
@interface UserDataView : UIView

@property (nonatomic) NSMutableArray *userData;
@property (nonatomic) NSArray *colorList;
@property (nonatomic) UIFont *font;
@property (nonatomic) ViewController *mainView;
- (void)refreshData:(NSArray *)record;
@end
