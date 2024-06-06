//
//  SPDocUpListVC.m
//  
//
//  Created by SPSuper on 2017/7/12.
//  Copyright © 2017年 Super. All rights reserved.
//

#import "SPDocUpListVC.h"
#import "SPDocUploadModel.h"
#import "SPDocUploadCell.h"

@interface SPDocUpListVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation SPDocUpListVC

static NSString *const cellID = @"uploadListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空列表" style:UIBarButtonItemStylePlain target:self action:@selector(clean)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kSuperFinishedUpload object:nil];
    
    self.title = @"上传列表";
}



- (void)setupTableView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 80;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[SPDocUploadCell class] forCellReuseIdentifier:cellID];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(@0);
    }];
    self.tableView = tableView;
}

#pragma mark- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [SPUploadManager shareUploadManager].modelArray.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SPDocUploadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.reloadDataBlock = ^{[self reloadData];};
    SPDocUploadModel *docUploadModel = [SPUploadManager shareUploadManager].modelArray[indexPath.row];
    cell.docUploadModel = docUploadModel;

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SPDocUploadModel *docUploadModel = [SPUploadManager shareUploadManager].modelArray[indexPath.row];
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:docUploadModel.filePath];
    if (handle == nil) {
        NSLog(@"SuperNSLog-- 源文件不存在或路径已经改变");
        return;
    }
    docUploadModel.isRunning = !docUploadModel.isRunning;
    if (docUploadModel.isRunning) {
        if (docUploadModel.dataTask.state == NSURLSessionTaskStateSuspended) {
             [docUploadModel.dataTask resume];
        }else {
            [[SPUploadManager shareUploadManager] continueUploadWithModel:docUploadModel];
        }
       
    }else {
        [docUploadModel.dataTask suspend];
    }
   
    [self reloadData];

    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    SPDocUploadModel *docUploadModel = [SPUploadManager shareUploadManager].modelArray[indexPath.row];
    [[SPUploadManager shareUploadManager] removeUploadModel:docUploadModel];
}


- (void)reloadData {
    
    [self.tableView reloadData];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)clean {

    [[SPUploadManager shareUploadManager] removeAll];
    [self reloadData];
    
}




@end
