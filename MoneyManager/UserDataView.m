//
//  UserDataView.m
//  MoneyManager
//
//  Created by hh.tai on 2/23/15.
//  Copyright (c) 2015 hh.tai. All rights reserved.
//

#import "UserDataView.h"
#import "MyLabel.h"

@interface UserDataView()


@property (nonatomic) UIColor *color;
@property (nonatomic) NSArray *categoryList;
@end

@implementation UserDataView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)customInit{
    // This version, we don't allow user to add new category
    // It will fixed at 4 categories as: Foods, Train, Shopping, General
    // Include the title and 4 categories, so we have 5 rows and 3 columns for
    // name of categories, value and rate.
    self.font = [UIFont fontWithName:@"Steiner" size:16.0];
    self.color = [UIColor colorWithRed:200/255.0 green:198/255.0 blue:210/255.0 alpha:1];
    self.userData = [[NSMutableArray alloc]init];
    
    float rowHeight = self.frame.size.height/5;
    float categoryColWidth = self.frame.size.width/3;
    float valueColWidth = categoryColWidth;
    float rateColWidth = valueColWidth;
    
    // Create label for Title
    MyLabel *title = [[MyLabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, rowHeight)];
    title.text = @"OVERVIEW (this month)";
    title.center = CGPointMake(self.center.x, rowHeight/2);
    title.font = [UIFont fontWithName:@"QuicksandLight-Regular" size:24.0];
    title.textColor = self.color;
    [self addSubview:title];
    
    self.categoryList = [[NSArray alloc]initWithObjects:@"Foods", @"Train", @"Shopping", @"General", nil];
    float x = title.frame.origin.x;
    float y = title.frame.origin.y + rowHeight;
    
    for (int i = 0; i < self.categoryList.count; i++) {
        
        // Create categories
        
        MyLabel *category = [[MyLabel alloc]initWithFrame:CGRectMake(x, y, categoryColWidth, rowHeight)];
        category.text = [NSString stringWithFormat:@"%@", self.categoryList[i]];
        category.font = self.font;
        switch (i) {
            case 0:
                category.textColor = [UIColor colorWithRed:254/255.0 green:197/255.0 blue:101/255.0 alpha:1.0];
                break;
            case 1:
                category.textColor = [UIColor colorWithRed:62/255.0 green:212/255.0 blue:197/255.0 alpha:1.0];
                break;
            case 2:
                category.textColor = [UIColor colorWithRed:175/255.0 green:171/255.0 blue:251/255.0 alpha:1.0];
                break;
            case 3:
                category.textColor = [UIColor colorWithRed:252/255.0 green:129/255.0 blue:130/255.0 alpha:1.0];
                break;
                
            default:
                break;
        }
        [self addSubview:category];
        // Create Value column
        
        MyLabel *value = [[MyLabel alloc]initWithFrame:CGRectMake(x+categoryColWidth, y, valueColWidth, rowHeight)];
        value.tag = i+1;
        value.text = @"00000";
        value.font = self.font;
        value.textColor = self.color;
        value.textAlignment = NSTextAlignmentCenter;
        [self addSubview:value];
        
        // Create Rate column
        
        MyLabel *rate = [[MyLabel alloc]initWithFrame:CGRectMake(x+categoryColWidth+valueColWidth, y, rateColWidth, rowHeight)];
        rate.tag = 10 + value.tag;
        rate.text = @"00%";
        rate.font = self.font;
        rate.textColor = self.color;
        rate.textAlignment = NSTextAlignmentRight;

        [self addSubview:rate];
        
        // Update Y
        y = y + rowHeight;
        
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

#pragma mark USER DATA

- (void)refreshData:(NSArray *)record{
    int food = 0, train = 0, shopping = 0, general = 0;
    
    for (int i = 0; i < record.count ; i++) {
        if ([record[i][@"Category"] isEqualToString:@"Foods"]) {
            // Calculate for Foods here
            
            food += [record[i][@"Amount"] intValue];
            UILabel *foodLabel = (UILabel *)[self viewWithTag:1];
            NSString *string = [NSString stringWithFormat:@"%i", food];
            [self updateText:string forLabel:foodLabel];
            
        }else if ([record[i][@"Category"] isEqualToString:@"Train"]){
            // Calcualte for Train here
            
            train += [record[i][@"Amount"] intValue];
            UILabel *trainLabel = (UILabel *)[self viewWithTag:2];
            NSString *string = [NSString stringWithFormat:@"%i", train];
            [self updateText:string forLabel:trainLabel];
            
        }else if ([record[i][@"Category"] isEqualToString:@"Shopping"]){
            // Calcualte for Shopping here
            
            shopping += [record[i][@"Amount"] intValue];
            UILabel *shoppingLabel = (UILabel *)[self viewWithTag:3];
            NSString *string = [NSString stringWithFormat:@"%i", shopping];
            [self updateText:string forLabel:shoppingLabel];
            
        }else if ([record[i][@"Category"] isEqualToString:@"General"]){
            // Calculate for General here
            
            general += [record[i][@"Amount"] intValue];
            UILabel *generalLabel = (UILabel *)[self viewWithTag:4];
            NSString *string = [NSString stringWithFormat:@"%i", general];
            [self updateText:string forLabel:generalLabel];
        }
    }
    
    NSArray *array = [[NSArray alloc]initWithObjects:
                      [NSNumber numberWithInt:food],
                      [NSNumber numberWithInt:train],
                      [NSNumber numberWithInt:shopping],
                      [NSNumber numberWithInt:general],nil];
    for (int r = 11; r < 15; r++) {
        UILabel *label = (UILabel *)[self viewWithTag:r];
        NSString *string;
        switch (label.tag) {
            case 11:
                string = [NSString stringWithFormat:@"%@%%", [self percentageOfthisValue:food wihtThisSumOfArray:array]];
                [self updateText:string forLabel:label];
                break;
            
            case 12:
                string = [NSString stringWithFormat:@"%@%%", [self percentageOfthisValue:train wihtThisSumOfArray:array]];
                [self updateText:string forLabel:label];
                break;
                
            case 13:
                string = [NSString stringWithFormat:@"%@%%", [self percentageOfthisValue:shopping wihtThisSumOfArray:array]];
                [self updateText:string forLabel:label];
                break;
                
            case 14:
                
                string = [NSString stringWithFormat:@"%@%%", [self percentageOfthisValue:general wihtThisSumOfArray:array]];
                [self updateText:string forLabel:label];
                break;
            default:
                break;
        }
    }
    
    [self.userData removeAllObjects];
    [self.userData addObject:[NSNumber numberWithInt:food]];
    [self.userData addObject:[NSNumber numberWithInt:train]];
    [self.userData addObject:[NSNumber numberWithInt:shopping]];
    [self.userData addObject:[NSNumber numberWithInt:general]];
    
}

- (NSString *)percentageOfthisValue:(int)value wihtThisSumOfArray:(NSArray *)arr{
    float sum = 0;
    for (int i = 0; i < arr.count; i++) {
        int intNum = [arr[i] intValue];
        sum += intNum;
    }
    
    int result = (int)round((value/sum*100));
    return [NSString stringWithFormat:@"%i", result];
    
}

- (void)updateText:(NSString *)text forLabel:(UILabel *)label{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [label.layer addAnimation:animation forKey:@"changeTextTransition"];
    label.text = text;
}

@end
