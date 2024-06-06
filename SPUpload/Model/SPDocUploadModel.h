//
//  SPDocUploadModel.h
//  
//
//  Created by SPSuper on 2017/7/12.
//  Copyright © 2017年 Super. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SPFileType) {
    SPFileTypePhoto,
    SPFileTypeVideo,
    SPFileTypeDocument
};

@interface SPDocUploadModel : NSObject

// 方便操作(暂停取消)正在上传的文件
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
// 总大小
@property (nonatomic, assign) int64_t totalSize;
// 总片数
@property (nonatomic, assign) NSInteger totalCount;
// 已上传片数
@property (nonatomic, assign) NSInteger uploadedCount;
// 上传所需参数
@property (nonatomic, copy) NSString *upToken;
// 上传状态标识, 记录是上传中还是暂停
@property (nonatomic, assign) BOOL isRunning;
// 缓存文件路径
@property (nonatomic, copy) NSString *filePath;
// 用来保存文件名使用
@property (nonatomic, copy) NSString *lastPathComponent;

// 以下属性用于给上传列表界面赋值
@property (nonatomic, assign) SPFileType fileType;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *progressLableText;
@property (nonatomic, assign) CGFloat uploadPercent;
@property (nonatomic, copy) void(^progressBlock)(CGFloat uploadPersent,NSString *progressLableText);

// 接下来调用的url
@property (nonatomic, copy) NSString *requestUrl;
// 保存上传成功后调用保存接口的参数
@property (nonatomic, strong) NSMutableDictionary *parameters;

@end
