//
//  MyButton.m
//  MoneyManager
//
//  Created by hh.tai on 3/4/15.
//  Copyright (c) 2015 hh.tai. All rights reserved.
//

#import "MyButton.h"

@interface MyButton()
@property (nonatomic) UILabel *underLine;
@end

@implementation MyButton


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)addUnderLine:(UILabel *)underLine{
    self.underLine = underLine;
    self.underLine.hidden = YES;
    [self addSubview:self.underLine];
}

- (void)setBorderColor:(UIColor *)color{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 0.5;
}

- (void)hideUnderLine{
    self.underLine.hidden = YES;
}

- (void)showUnderLine{
    self.underLine.hidden = NO;
}


@end
