//
//  CrashListController.m
//  CrashLogRecord
//
//  Created by Chance on 16/3/28.
//  Copyright © 2016年 Chance. All rights reserved.
//

#import "CrashListController.h"
#import "CrashDetailController.h"
#import "CrashHandle.h"

/**
 *  崩溃日志列表
 */
@interface CrashListController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *crashLogPath;

@end

@implementation CrashListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
}

- (void)loadData
{
    _dataArray = [NSMutableArray array];
    _crashLogPath = pathForCrashLogFileName(nil);
    
    NSArray *array = [[NSFileManager defaultManager] subpathsAtPath:_crashLogPath];
    for (NSString *name in array) {
        if ([name hasSuffix:@".log"]) {
            [_dataArray addObject:name];
        }
    }
}

- (void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", self.crashLogPath, self.dataArray[indexPath.row]];
    CrashDetailController *vc = [CrashDetailController new];
    vc.filePath = filePath;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
