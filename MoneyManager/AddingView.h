//
//  AddingView.h
//  MoneyManager
//
//  Created by hh.tai on 3/4/15.
//  Copyright (c) 2015 hh.tai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddingView : UIView
@property (nonatomic) NSArray *categoryList;

- (id)initWithFrame:(CGRect)frame withCategoryList:(NSMutableArray *)list;
@end
