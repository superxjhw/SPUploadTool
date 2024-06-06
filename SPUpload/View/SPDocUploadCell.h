//
//  SPDocUploadCell.h
//  
//
//  Created by SPSuper on 2017/7/12.
//  Copyright © 2017年 Super. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPDocUploadModel;

@interface SPDocUploadCell : UITableViewCell

@property (nonatomic, strong) SPDocUploadModel *docUploadModel;
@property (nonatomic, copy) void(^reloadDataBlock)(void);

@end
