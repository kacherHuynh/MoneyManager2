//
//  UserDataView.h
//  MoneyManager
//
//  Created by hh.tai on 2/23/15.
//  Copyright (c) 2015 hh.tai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLabel.h"
@interface UserDataView : UIView

@property (nonatomic) NSMutableArray *userData;
@property (nonatomic) UIFont *font;
- (void)refreshData:(NSArray *)record;

@end
