//
//  ViewController.h
//  MoneyManager
//
//  Created by hh.tai on 2/16/15.
//  Copyright (c) 2015 hh.tai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"

@interface ViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, XYPieChartDelegate, XYPieChartDataSource>

- (void)showAddingView;
- (void)okayBtnPressedWithValue:(NSString *)value forCategory:(NSString *)category;
@end

