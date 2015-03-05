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

@interface AddingView()
@property (nonatomic) UILabel *displayLabel;
@property (nonatomic) NSString *category;
@property float topPt, bottomPt;

@end

@implementation AddingView

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
        // we need to store this number to use for removing view by touching out side of button
        self.topPt = offsetY;
        float offsetX = btnSize/2;
        
        // Create display label
        self.displayLabel = [[UILabel alloc]initWithFrame:CGRectMake(offsetX, offsetY, btnSize * 4 + padding * 3, btnSize)];
        self.displayLabel.text = @"0";
        self.displayLabel.font = font;
        self.displayLabel.textColor = color;
        self.displayLabel.textAlignment = NSTextAlignmentRight;
        
        //displayLabel.backgroundColor = [UIColor redColor];
        
        [self addSubview:self.displayLabel];
        
        // Create Category 
        offsetY = offsetY + btnSize * 1;
        
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
            [btn addUnderLine:label];
        
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
                
                // If button is OK, set bigger size for it
                if (index == 11) {
                    tempHeight = btnSize*2 + padding;
                }else{
                    tempHeight = btnSize;
                }
                
                MyButton *btn = [[MyButton alloc]initWithFrame:CGRectMake(offsetX, offsetY, btnSize, tempHeight)];
                [btn setTitle:numPadList[index] forState:UIControlStateNormal];
                btn.font = [UIFont fontWithName:font.fontName size:20];
                btn.tag = index;
                [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:btn];
                
                // If button is OK, set border for it
                if (index == 11) {
                    [btn setBorderColor:[UIColor colorWithRed:252/255.0 green:129/255.0 blue:130/255.0 alpha:0.5]];
                }else{
                    [btn setBorderColor:[UIColor colorWithRed:200/255.0 green:198/255.0 blue:210/255.0 alpha:0.5]];
                }
                
                
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
        self.bottomPt = offsetY;
    }
    return self;
}

- (void)btnPressed:(id)sender{

    MyButton *btn = (MyButton *)sender;

    if (btn.tag >= 100) {
        
        // Remove the current underline
        for (MyButton *subview in self.subviews)
        {
            if (subview.tag >= 100) {
                [subview hideUnderLine];
            }
        }
        // Handle action for button
        [btn showUnderLine];
        self.category = btn.titleLabel.text;
        
    }else{
        
        switch (btn.tag) {
            case 3: // tag = 3 is C => Reset the label to 0
                [self updateText:@"0" forLabel:self.displayLabel];
                break;
            
            case 7: // back button
                [self updateText:[self deleteString:self.displayLabel.text] forLabel:self.displayLabel];
                break;
            case 11: // OK button
                [self.mainView okayBtnPressedWithValue:self.displayLabel.text forCategory:self.category];
                self.displayLabel.text = @"0";
                break;
            case 14: // . button
                [self updateText:[self updateStringWithDot:self.displayLabel.text] forLabel:self.displayLabel] ;
                break;
            default:
                [self updateText:[self updateString:self.displayLabel.text whenBtnPress:btn] forLabel:self.displayLabel];
                break;
        }
    }
}

- (NSString *)updateString:(NSString *)string whenBtnPress:(MyButton *)btn{
    NSString *newString;
    
    if ([string isEqualToString:@"0"]) {
        if (![btn.titleLabel.text isEqualToString:@"00"]) {
            newString = btn.titleLabel.text;
        }else{
            newString = @"0";
        }
    }else{
        newString = [string stringByAppendingString:btn.titleLabel.text];
    }
    
    return newString;
}

- (NSString *)deleteString:(NSString *)string{
    // This is delete only last character
    int length = (int)string.length;
    
    if ((![string isEqualToString:@"0"]) && (length > 1)) {
        string = [string substringToIndex:string.length -1];
    }else{
        string = @"0";
    }
    return string;
}

- (NSString *)updateStringWithDot:(NSString *)string{
    
    NSUInteger len = [string length];
    unichar buffer[len+1];
    [string getCharacters:buffer range:NSMakeRange(0, len)];

    for(int i = 0; i < len; i++) {
        NSString *needToCheck = [NSString stringWithFormat:@"%C", buffer[i]];
        if ([needToCheck isEqualToString:@"."]) {
            return string;
        }
    }
    
    string = [string stringByAppendingString:@"."];
    return string;
}

- (void)updateText:(NSString *)text forLabel:(UILabel *)label{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.15;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [label.layer addAnimation:animation forKey:@"changeTextTransition"];
    label.text = text;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self];
        if (point.y < self.topPt || point.y > self.bottomPt) {
            [self removeFromSuperview];
        }
    }
}

@end
