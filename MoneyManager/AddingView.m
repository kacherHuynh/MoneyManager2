//
//  AddingView.m
//  MoneyManager
//
//  Created by hh.tai on 3/4/15.
//  Copyright (c) 2015 hh.tai. All rights reserved.
//

#import "AddingView.h"
#import "MyButton.h"

int const padding = 6;
int const colNum = 4;
int const rowNum = 6;

typedef enum {
    kFoods = 100,
    kTrain,
    kShopping,
    kGeneral
} Category;


@implementation AddingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame withCategoryList:(NSMutableArray *)list{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.9];
        
        UIFont *font = [UIFont fontWithName:@"Steiner" size:40.0];
        UIColor *color = [UIColor colorWithRed:200/255.0 green:198/255.0 blue:210/255.0 alpha:1];
        
        // Since our application only allow user to have 4 category, so we define it here
        NSArray *colorList = [[NSArray alloc]
                          initWithObjects:
                          [UIColor colorWithRed:254/255.0 green:197/255.0 blue:101/255.0 alpha:1.0], // Foods
                          [UIColor colorWithRed:62/255.0 green:212/255.0 blue:197/255.0 alpha:1.0],  // Train
                          [UIColor colorWithRed:175/255.0 green:171/255.0 blue:251/255.0 alpha:1.0], // Shop
                          [UIColor colorWithRed:252/255.0 green:129/255.0 blue:130/255.0 alpha:1.0], // General
                          nil];
        NSArray *numPadList = [[NSArray alloc]initWithObjects:@"7",@"8",@"9",@"C",@"4",@"5",@"6",@"←",@"1",@"2",@"3",@"OK",@"0",@"00",@".", nil];
        
        // Custom init here
        float btnSize = (frame.size.width - (padding * 3))/5;
        float offsetY = (frame.size.height - (btnSize * rowNum + padding*4)) /2;
        float offsetX = btnSize/2;
        
        // Create display label
        UILabel * displayLabel = [[UILabel alloc]initWithFrame:CGRectMake(offsetX, offsetY, btnSize * 4 + padding * 3, btnSize)];
        displayLabel.text = @"0";
        displayLabel.font = font;
        displayLabel.textColor = color;
        displayLabel.textAlignment = NSTextAlignmentRight;
        
        //displayLabel.backgroundColor = [UIColor redColor];
        
        [self addSubview:displayLabel];
        
        // Create Category 
        offsetY = offsetY + btnSize * 1.5;
        
        for (int i = 0; i < 4; i++) {
            MyButton *btn = [[MyButton alloc]initWithFrame:CGRectMake(offsetX, offsetY, btnSize, btnSize/2)];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            
            //btn.backgroundColor = [UIColor redColor];
            // create attributed string for title
            NSString *titleString = [NSString stringWithFormat:@"%@", list[i]];
            NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc]initWithString:titleString];
            [attributedTitle addAttribute:NSForegroundColorAttributeName value:colorList[i] range:NSMakeRange(0, attributedTitle.length)];
            [attributedTitle addAttribute:NSFontAttributeName value:[UIFont fontWithName:font.fontName size:12] range:NSMakeRange(0, attributedTitle.length)];
            [btn setAttributedTitle:attributedTitle forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            // Create line below Btn
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0,btn.frame.size.height*0.75, btn.frame.size.width, btn.frame.size.height/20)];
            label.backgroundColor = colorList[i];
            btn.underLine = label;
            [btn setUnderLine];
        
            switch (i) {
                case 0:
                    btn.tag = kFoods;
                    break;
                case 1:
                    btn.tag = kTrain;
                    break;
                case 2:
                    btn.tag = kShopping;
                    break;
                case 3:
                    btn.tag = kGeneral;
                    break;
                default:
                    break;
            }
            
            
            
            [self addSubview:btn];
            offsetX = offsetX + btnSize + padding;
        }
        
        // Create Numpad
        offsetX = btnSize/2;
        offsetY = offsetY+ btnSize/2 + padding;
        int index = 0;
        float tempHeight;
        
        for (int i = 0; i < 4; i++) {
            for (int r = 0; r < 4; r ++) {
                if (index == 11) {
                    tempHeight = btnSize*2 + padding;
                }else{
                    tempHeight = btnSize;
                }
                
                MyButton *btn = [[MyButton alloc]initWithFrame:CGRectMake(offsetX, offsetY, btnSize, tempHeight)];
                [btn setTitle:numPadList[index] forState:UIControlStateNormal];
                btn.font = [UIFont fontWithName:font.fontName size:20];
//                btn.tag = index;
                [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:btn];
                
                // Update index and offset for X
                offsetX = offsetX + padding + btnSize;
                
                if (index < numPadList.count -1){
                    index++;
                }else{
                    break;
                }
                
            }
            
            // Update offset for Y
            offsetX = btnSize/2;
            offsetY = offsetY + padding + btnSize;
        }
    }
    return self;
}

- (void)btnPressed:(id)sender{

    MyButton *btn = (MyButton *)sender;
    NSLog(@"%@", btn.titleLabel.text);
    if (btn.tag > 0) {
        
        for (MyButton *subview in self.subviews)
        {
            if (subview.tag > 0) {
                NSLog(@"%i", subview.tag);
                subview.underLine.hidden = YES;
            }
        }
        btn.underLine.hidden = NO;
    }
    

}

@end
