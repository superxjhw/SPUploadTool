//
//  SPUploadManager.h
//  
//
//  Created by SPSuper on 2017/7/12.
//  Copyright © 2017年 Super. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPDocUploadModel;
@interface SPUploadManager : NSObject
SingletonH(UploadManager);

@property (nonatomic, strong) NSMutableArray *modelArray;

- (void)refreshCaches;

- (void)cancelAllUploadOperations;

/**
 支持断点续传,上传初始化
 直接传data类型,自动缓存到本地,上传完毕自动清理
 @param data 要上传的数据
 @param model 需要保存的内容
 */
- (void)uploadData:(NSData *)data withModel:(SPDocUploadModel *)model completion:(void(^)(void))completion;

/**
 支持断点续传,上传初始化
 直接传data类型,自动缓存到本地,上传完毕自动清理
 @param mediaUrl 要上传的文件URL
 @param model 需要保存的内容
 */
- (void)uploadUrl:(NSURL *)mediaUrl withModel:(SPDocUploadModel *)model completion:(void(^)(void))completion;

/**
 续传
 @param model 保存的数据模型
 */
- (void)continueUploadWithModel:(SPDocUploadModel *)model;


/**
 清理所有上传文件缓存
 */
- (void)clean;

/**
 移除某一个文件,对应上传列表手动左滑删除以及上传成功后自动删除
 */
- (void)removeUploadModel:(SPDocUploadModel *)model;

/**
 清理所有上传文件
 */
- (void)removeAll;

/**
  清理指定文件缓存

 @param filePath 文件路径
 */
- (void)cleanPath:(NSString *)filePath;

@end
