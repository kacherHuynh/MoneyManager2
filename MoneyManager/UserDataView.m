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

@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *color;
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
    
    NSArray *categoryList = [[NSArray alloc]initWithObjects:@"Foods", @"Train", @"Shopping", @"General", nil];
    float x = title.frame.origin.x;
    float y = title.frame.origin.y + rowHeight;
    
    for (int i = 0; i < categoryList.count; i++) {
        
        // Create categories
        
        MyLabel *category = [[MyLabel alloc]initWithFrame:CGRectMake(x, y, categoryColWidth, rowHeight)];
        category.text = [NSString stringWithFormat:@"%@", categoryList[i]];
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
        value.tag = i;
        value.text = @"00000";
        value.font = self.font;
        value.textColor = self.color;
        value.textAlignment = NSTextAlignmentCenter;
        [self addSubview:value];
        
        // Create Rate column
        
        MyLabel *rate = [[MyLabel alloc]initWithFrame:CGRectMake(x+categoryColWidth+valueColWidth, y, rateColWidth, rowHeight)];
        rate.tag = 10 + i;
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
        }else if ([record[i][@"Category"] isEqualToString:@"Train"]){
            // Calcualte for Train here
            train += [record[i][@"Amount"] intValue];
        }else if ([record[i][@"Category"] isEqualToString:@"Shopping"]){
            // Calcualte for Shopping here
            shopping += [record[i][@"Amount"] intValue];
        }else if ([record[i][@"Category"] isEqualToString:@"Foods"]){
            // Calculate for General here
            general += [record[i][@"Amount"] intValue];
        }
    }
    
    
    NSLog(@"TRAIN: %i, SHOPPING: %i, GENERAL: %i, FOODS: %i", train, shopping, general, food);
}


@end
