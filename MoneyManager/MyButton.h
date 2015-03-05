//
//  MyButton.h
//  MoneyManager
//
//  Created by hh.tai on 3/4/15.
//  Copyright (c) 2015 hh.tai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyButton : UIButton

- (void)addUnderLine:(UILabel *)underLine;
- (void)setBorderColor:(UIColor *)color;
- (void)hideUnderLine;
- (void)showUnderLine;

@end
