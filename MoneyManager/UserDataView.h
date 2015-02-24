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

@property (nonatomic) MyLabel *foodsValue, *trainValue, *shoppingValue, *generalValue, *viewTitle;

- (void)refreshData:(NSArray *)record;

@end