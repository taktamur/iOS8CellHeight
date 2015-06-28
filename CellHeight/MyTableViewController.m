//
//  MyTableViewController.m
//  CellHeight
//
//  Created by 田村孝文 on 2015/06/28.
//  Copyright (c) 2015年 田村孝文. All rights reserved.
//

#import "MyTableViewController.h"

@interface MyTableViewController ()
@property(nonatomic)NSMutableArray *array;
@end

@implementation MyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.array = [NSMutableArray new];
    
    for( NSUInteger i=0; i<20; i++) {
        NSUInteger rand =  arc4random()%5;
        [self.array addObject:@(rand)];
    }
    self.tableView.estimatedRowHeight = 100;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlStateChanged:)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)refreshControlStateChanged:(id)sender
{
    // 3 秒待ってからハンドリングを行う、URL リクエストとレスポンスに似せたダミーコード
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        for( NSUInteger i=0; i<20; i++) {
            NSUInteger rand =  arc4random()%5;
            [self.array insertObject:@(rand) atIndex:0];
        }
//                [self.tableView reloadData];
        [self.tableView beginUpdates];
        NSMutableArray *indexPaths = [NSMutableArray new];
        for( NSUInteger i=0; i<20; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [indexPaths addObject:indexPath];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];
        [self.tableView endUpdates];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:20 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
        [self.refreshControl endRefreshing];

    });
}
-(NSString *)stringByLineNumber:(NSUInteger)number
{
    NSString *ret = @"";
    for(NSUInteger i=1; i<=number; i++ ){
        ret = [ret stringByAppendingString:[@(number) description]];
        if( i!=number){
            ret = [ret stringByAppendingString:@"\n"];
        }
    }
    return ret;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog( @"cellForRowAtIndexPath: row=%@",@(indexPath.row));
    NSArray *cellColors= @[ [UIColor whiteColor],
                            [UIColor redColor],
                            [UIColor blueColor],
                            [UIColor yellowColor],
                            [UIColor greenColor]];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    NSUInteger num = (NSUInteger)[self.array[indexPath.row] integerValue];
    cell.textLabel.text = [self stringByLineNumber:num];
    cell.backgroundColor = cellColors[num];
    [cell layoutIfNeeded];
    return cell;
}



@end
