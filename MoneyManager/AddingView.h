//
//  AddingView.h
//  MoneyManager
//
//  Created by hh.tai on 3/4/15.
//  Copyright (c) 2015 hh.tai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AddingView : UIView <UIAlertViewDelegate>
@property (nonatomic) NSArray *categoryList;
@property (nonatomic) ViewController *mainView;

- (id)initWithFrame:(CGRect)frame withCategoryList:(NSMutableArray *)list;
@end
