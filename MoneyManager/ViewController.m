//
//  ViewController.m
//  MoneyManager
//
//  Created by hh.tai on 2/16/15.
//  Copyright (c) 2015 hh.tai. All rights reserved.
//

#import "ViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "UserDataView.h"
#import "SplittingTriangle.h"
#import "XYPieChart.h"
#import "AddingView.h"

@import CloudKit;

NSString * const UserRecordType = @"MoneyManagerRecords";
NSString * const UserCategoryRecordType = @"MoneyManagerCategory";
NSString * const UserIDField = @"UserID";
NSString * const AmountField = @"Amount";
NSString * const CategoryField = @"Category";
NSString * const DateField = @"Date";


@interface ViewController ()

@property (readonly) CKContainer *container;
@property (readonly) CKDatabase *publicData;
@property (nonatomic) NSString *userID;
@property (nonatomic) __block NSMutableArray *userCategory;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIVisualEffectView *blurView;
@property (nonatomic) UserDataView *userDataView;
@property (nonatomic) SplittingTriangle *loadingView;
@property (nonatomic) XYPieChart *chart;
@property (nonatomic) AddingView *addingView;
@property (nonatomic) UIButton *addButton;
@property (nonatomic) BOOL isLoading;


@end

@implementation ViewController

- (void)loadView{
    [super loadView];
 
    // add imageview as a background

    self.view.backgroundColor = [UIColor colorWithRed:64/255.0 green:62/255.0 blue:72/255.0 alpha:1.0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // Init CK
    [self initCloudKit];
    [self loadUserCategoryList];
    
    // Load GUI

    [self loadGUI];

}


#pragma mark LAYOUT

- (void)loadGUI{
    [self loadUserData];
    [self loadChart];
}

- (void)loadUserData{
    
    self.userDataView = [[UserDataView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2)];
    self.userDataView.mainView = self;
    [self refreshUserDataView:self.userDataView];
    [self.view addSubview:self.userDataView];
    [self checkForLoading];
}

- (void)loadChart{
    if (self.chart == nil) {
        self.chart = [[XYPieChart alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2) Center:CGPointMake(self.view.center.x, self.view.center.y/2) Radius:100];
        [self.chart setStartPieAngle:M_PI_2];
        [self.chart setAnimationSpeed:1.0];
        [self.chart setLabelFont: self.userDataView.font];
        [self.chart setLabelShadowColor:[UIColor blackColor]];
        [self.chart setLabelRadius:60];	//optional
        [self.chart setShowPercentage:YES];	//optional
        [self.chart setPieBackgroundColor:[UIColor clearColor]];
        [self.chart setDataSource:self];
        [self.chart setDelegate:self];
    }

    [self.view addSubview:self.chart];
    [self checkForLoading];
    [self.chart reloadData];
}

- (void)checkForLoading{
    
    if (self.isLoading) {
        [self.view bringSubviewToFront:self.loadingView];
    }
}

- (void)showLoadingScreen{
    
    self.view.userInteractionEnabled = NO;
    
    if (self.loadingView == nil) {
        
        // create loading view
        self.loadingView = [[SplittingTriangle alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.loadingView.center = self.view.center;
        [self.loadingView setForeColor:[UIColor colorWithRed:25.0/255 green:191.0/255 blue:214.0/255 alpha:1]
                          andBackColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1]];
        
        self.loadingView.clockwise = YES;
        self.loadingView.duration = 1.5;
        self.loadingView.radius = 5;
        self.loadingView.paused = NO;
    }
    
    self.isLoading = YES;
    self.loadingView.alpha = 0.9;
    if (self.loadingView.superview == nil) {
        [self.view addSubview:self.loadingView];
    }
}

- (void)hideLoadingScreen{
    
    self.view.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.loadingView.alpha = 0;
        
        self.isLoading = NO;
    }];

}


#pragma mark PREPARE DATA

- (void)loadUserCategoryList{
    if (self.userCategory == nil) {
        self.userCategory = [[NSMutableArray alloc]init];
    }
    // get category list from icloud
    
    [self fetchCategoryByUserId:self.userID completionHandler:^(NSArray *records) {
        
        if (self.userCategory.count < records.count) {
            for (int i = (int)self.userCategory.count; i<records.count; i++) {
                [self.userCategory addObject:records[i][CategoryField]];
            }
        }
        
        if (self.userCategory.count == 0) {
            [self.userCategory addObject:[NSString stringWithFormat:@"Food"]];
            [self.userCategory addObject:[NSString stringWithFormat:@"Train"]];
            [self.userCategory addObject:[NSString stringWithFormat:@"Shopping"]];
            [self.userCategory addObject:[NSString stringWithFormat:@"General"]];
        }
    }];
}

- (void)refreshUserDataView:(UserDataView *)view{
    [self fetchDataByUserId:self.userID completionHandler:^(NSArray *record) {
        [view refreshData:record];
        [self.chart reloadData];
    }];
}



- (void)initCloudKit{

    _container = [CKContainer defaultContainer];
    _publicData = [_container publicCloudDatabase];
    
    // show loading screen
    [self showLoadingScreen];

    // get UserID and pass to self.userID
    
    self.userID = [NSString stringWithFormat:@""];
    
    [self.container fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
        if (error== nil) {
            NSLog(@"USER ID: %@", recordID.recordName);
            self.userID = [NSString stringWithFormat:@"%@", recordID.recordName];
            
            // when we have the UID, finished loading -> we will hide loading screen, but notice that, we need to do it on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoadingScreen];
                // We only can load data after we have UID so here we will load chart base on User Data
                [self refreshUserDataView:self.userDataView];
            });
            
        }else{
            NSLog(@"An error occured in %@: %@", NSStringFromSelector(_cmd), error);
        }
    }];
}
- (void)fetchDataByUserId:(NSString *)userId completionHandler:(void (^)(NSArray *record))completionHander {
    NSPredicate *condition = [NSPredicate predicateWithFormat:@"%K == %@",UserIDField, self.userID];
    
    CKQuery *query = [[CKQuery alloc]initWithRecordType:UserRecordType predicate:condition];
    
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc]initWithQuery:query];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    [queryOperation setRecordFetchedBlock:^(CKRecord *record) {
        [results addObject:record];
    }];
    
    queryOperation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
        if (error) {
            // In your app, handle this error with such perfection that your users will never realize an error occurred.
            NSLog(@"An error occured in %@: %@", NSStringFromSelector(_cmd), error);
            abort();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completionHander(results);
            });
        }
    };
    
    [self.publicData addOperation:queryOperation];
}

- (void)fetchCategoryByUserId:(NSString *)userId completionHandler:(void (^)(NSArray *records))completionHandler{
    
    NSPredicate *condition = [NSPredicate predicateWithFormat:@"%K == %@",UserIDField, self.userID];
    
    CKQuery *query = [[CKQuery alloc]initWithRecordType:UserCategoryRecordType predicate:condition];
    
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc]initWithQuery:query];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    [queryOperation setRecordFetchedBlock:^(CKRecord *record) {
        [results addObject:record];
    }];
    
    queryOperation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
        if (error) {
            // In your app, handle this error with such perfection that your users will never realize an error occurred.
            NSLog(@"An error occured in %@: %@", NSStringFromSelector(_cmd), error);
            abort();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completionHandler(results);
            });
        }
    };
    
    [self.publicData addOperation:queryOperation];
    
}

#pragma mark HANDLE USER ACTION

- (void)addRecoreWithAmount:(NSString *)amount forCategory:(NSString *)category{
    
    [self showLoadingScreen];
    
    CKRecord *record = [[CKRecord alloc]initWithRecordType:UserRecordType];
    record[AmountField] = amount;
    record[CategoryField] = category;
    record[DateField] = [NSDate date];
    record[UserIDField] = self.userID;
    
    
    [self.publicData saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
        if (error) {
            NSLog(@"An error occured in %@: %@", NSStringFromSelector(_cmd), error);
            abort();
        }else{
            NSLog(@"ADDED SUCCESSFULY");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(hideLoadingScreen) withObject:nil afterDelay:2];
                [self performSelector:@selector(refreshUserDataView:) withObject:self.userDataView afterDelay:2];
            });
        }
    }];
}

- (void)addCategory:(NSString *)category{
    
    CKRecord *record = [[CKRecord alloc]initWithRecordType:UserCategoryRecordType];

    record[CategoryField] = category;
    record[UserIDField] = self.userID;
    record[DateField] = [NSDate date];
    
    
    [self.publicData saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
        if (error) {
            NSLog(@"An error occured in %@: %@", NSStringFromSelector(_cmd), error);
            abort();
        }else{
            NSLog(@"ADDED SUCCESSFULY");
        }
    }];
    
    // update category list
    [self loadUserCategoryList];
}

- (void)showAddingView{
    if (self.addingView == nil) {
        self.addingView = [[AddingView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withCategoryList:self.userCategory];
        self.addingView.mainView = self;
    }
    [self.view addSubview:self.addingView];
}

- (void)okayBtnPressedWithValue:(NSString *)value forCategory:(NSString *)category{
    [self.addingView removeFromSuperview];
    NSLog(@"Value: %@ and Category: %@",value,category);
    [self addRecoreWithAmount:value forCategory:category];
}

#pragma mark DELEGATE 

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

// DATA SOURCE FOR CHART

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart{
    return self.userDataView.userData.count;
}
- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index{
    return [self.userDataView.userData[index] intValue];
}
- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index{
    return self.userDataView.colorList[index];
}
- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index{
    return @"LOG";
}//optional


- (void)deleteCategoryByUserId:(NSString *)userId completionHandler:(void (^)(NSArray *records))completionHandler{
    
    // Note: This feature is only used for debugging.
    
    NSPredicate *condition = [NSPredicate predicateWithFormat:@"%K == %@",UserIDField, self.userID];
    
    CKQuery *query = [[CKQuery alloc]initWithRecordType:UserRecordType predicate:condition];
    
    CKQueryOperation *queryOperation = [[CKQueryOperation alloc]initWithQuery:query];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    [queryOperation setRecordFetchedBlock:^(CKRecord *record) {
        [self.publicData deleteRecordWithID:record.recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
            NSLog(@"DELETED");
        }];
    }];
    
    queryOperation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
        if (error) {
            // In your app, handle this error with such perfection that your users will never realize an error occurred.
            NSLog(@"An error occured in %@: %@", NSStringFromSelector(_cmd), error);
            abort();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completionHandler(results);
            });
        }
    };
    
    [self.publicData addOperation:queryOperation];
    
}

@end
