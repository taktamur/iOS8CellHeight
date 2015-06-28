//
//  MyTableViewController.m
//  CellHeight
//
//  Created by 田村孝文 on 2015/06/28.
//  Copyright (c) 2015年 田村孝文. All rights reserved.
//

#import "MyTableViewController.h"
#import "MyTableViewCell.h"
@interface MyTableViewController ()
@property(nonatomic)NSMutableArray *array;
@property(nonatomic)MyTableViewCell *dummyCell;
@end

@implementation MyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.array = [NSMutableArray new];
    
    for( NSUInteger i=0; i<20; i++) {
        NSUInteger rand =  arc4random()%5;
        [self.array addObject:@(rand)];
    }
    // estimatedRowHeightは使わない。
//    self.tableView.estimatedRowHeight = 100;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlStateChanged:)
                  forControlEvents:UIControlEventValueChanged];
    
    // セルの高さを計算する用の、表示されないダミーのセルを用意する。
    self.dummyCell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
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

/**
 Autolayoutを使ったUITableViewCellの高さ計算
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 高さ計算用のダミーのセルに、cellForRowAtIndexPathで行うのと
    // 同じ設定をする。
    [self setupCell:self.dummyCell atIndexPath:indexPath];

    // 以下、サイズ計算用の処理です。
    // ダミーセルそのものに操作しても、サイズ計算は行われないので、
    // その内側にあるcontentViewに対して操作を行います。
    // contentViewを再レイアウトする
    [self.dummyCell.contentView setNeedsLayout];
    [self.dummyCell.contentView layoutIfNeeded];
    // contentViewの、Autolayoutに従った時のサイズを取得する
    CGSize size = [self.dummyCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    // UITableViewの高さは、contentViewと「区切り線」を含んだ高さなので、
    // 高さに区切り線分の高さを+1して返す
    return size.height+1;
}

/** MyTableViewCellの設定処理 */
// MyTableViewCellへの設定処理が重たい場合は、
// 「高さ計算で必要な設定」と「高さ計算では不要な設定」に
// 分けたほうが良いかもしれません。
-(void)setupCell:(MyTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger num = (NSUInteger)[self.array[indexPath.row] integerValue];
    cell.title.text = [self stringByLineNumber:num];
    cell.backgroundColor = [self colorByNumber:num];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog( @"cellForRowAtIndexPath: row=%@",@(indexPath.row));
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    [self setupCell:cell atIndexPath:indexPath];
//    NSLog( @"cell=%@",cell);
    return cell;
}

#pragma mark - ユーティリティ
-(UIColor *)colorByNumber:(NSUInteger)number
{
    NSArray *cellColors= @[ [UIColor whiteColor],
                            [UIColor redColor],
                            [UIColor blueColor],
                            [UIColor yellowColor],
                            [UIColor greenColor]];
    
    return cellColors[number%5];
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



@end
