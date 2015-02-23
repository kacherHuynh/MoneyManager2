//
//  ViewController.m
//  MoneyManager
//
//  Created by hh.tai on 2/16/15.
//  Copyright (c) 2015 hh.tai. All rights reserved.
//

#import "ViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "CTPopOutMenu.h"
#import "UserDataView.h"

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
@property (nonatomic) __block NSMutableArray *userData;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIVisualEffectView *blurView;
@property (nonatomic) UIView *transView;
@property (nonatomic) UIView *userDataView;
//@property (nonatomic) int foods,trains,shopping,general;
//@property (nonatomic) float foodsRate,trainRate,shoppingRate,genralRate;


@end

@implementation ViewController

- (void)loadView{
    [super loadView];

    // add imageview as a background
//    self.imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg"]];
//    self.imageView.frame = self.view.frame;
    
    
    self.view.backgroundColor = [UIColor colorWithRed:64/255.0 green:62/255.0 blue:72/255.0 alpha:1.0];
    
    // create effect view to add to background view
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    self.blurView.frame = self.imageView.bounds;
    self.blurView.alpha = 0;

    
//    [self.view addSubview:self.imageView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Init CK
    [self initCloudKit];
    [self getCategoryList];
    
    // Load GUI
    [self loadGUI];
    [self loadUserData];
    
}


#pragma mark LAYOUT

- (void)loadGUI{
    UserDataView *view = [[UserDataView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2)];
    [self.view addSubview:view];
    
    [view refreshData:[self getUserData]];
}

- (void)loadUserData{
    
    // Initial View

    // Update View
    
}

- (void)loadChart{
    
}

#pragma mark PREPARE DATA

- (void)getCategoryListWithCompletionHandler:(void (^)(BOOL finished))completionHandler{
    

}

- (void)getCategoryList{
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
    }];

}

- (NSArray *)getUserData{
    NSArray __block *arr;
    [self fetchDataByUserId:self.userID completionHandler:^(NSArray *record) {
        arr = [[NSArray alloc]initWithArray:record];
        
    }];
    return arr;
    
}

- (void)showCategry{
    
    // add effect view
    [self.view addSubview:self.blurView];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.blurView.alpha = 1.0;
    }];
    
    // get list and add item for category menu
    [self getCategoryList];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (int m = 0; m < self.userCategory.count; m++) {
        CTPopoutMenuItem *item = [[CTPopoutMenuItem alloc]
                                  initWithTitle:self.userCategory[m]
                                  image:[UIImage imageNamed:@"pic5"]];
        
        [arr addObject:item];
    }
    CTPopoutMenu * menu = [[CTPopoutMenu alloc]initWithTitle:@"HOW MUCH DO YOU SPEND?" message:@"YOU" items:arr];
    menu.menuStyle = MenuStyleGrid;
    menu.delegate = self;
    menu.view.alpha = 0.8;
    [menu showMenuInParentViewController:self withCenter:self.view.center];
}


- (void)initCloudKit{
    _container = [CKContainer defaultContainer];
    _publicData = [_container publicCloudDatabase];

    // get UserID and pass to self.userID
    
    self.userID = [NSString stringWithFormat:@""];
    
    [self.container fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
        if (error== nil) {
            NSLog(@"USER ID: %@", recordID.recordName);
            self.userID = [NSString stringWithFormat:@"%@", recordID.recordName];
        }else{
            NSLog(@"An error occured in %@: %@", NSStringFromSelector(_cmd), error);
        }
    }];
    while ([self.userID isEqualToString:@""]) {
        sleep(1);
    }
    
    //
    self.view.userInteractionEnabled = true;
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
    [self getCategoryList];
}

#pragma mark DELEGATE 

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}

- (void)menu:(CTPopoutMenu *)menu willDismissWithSelectedItemAtIndex:(NSUInteger)index andValue:(NSString *)value{
    
    // check the value, if not null add it to iCloud
    if (![value isEqualToString:@""]) {
        [self addRecoreWithAmount:value forCategory:self.userCategory[index]];
    }
    
    // remove blur effect
    self.blurView.alpha = 0;
    [self.blurView removeFromSuperview];
}

- (void)menuwillDismiss:(CTPopoutMenu *)menu{
    
    // remove blur effect
    [self.blurView removeFromSuperview];
    self.blurView.alpha = 0;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

}


@end
