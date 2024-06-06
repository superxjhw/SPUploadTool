//
//  SPUploadManager.m
//  
//
//  Created by SPSuper on 2017/7/12.
//  Copyright © 2017年 Super. All rights reserved.
//

#import "SPUploadManager.h"
#import "SPDocUploadModel.h"

@implementation SPUploadManager
SingletonM(UploadManager);

static NSString *uploadListName = @"uploadList";

- (NSMutableArray *)modelArray {
    
    if (_modelArray == nil) {
        _modelArray = [NSMutableArray array];
        if ([[NSUserDefaults standardUserDefaults] arrayForKey:uploadListName]) {
            _modelArray = [SPDocUploadModel mj_objectArrayWithKeyValuesArray:[[NSUserDefaults standardUserDefaults] arrayForKey:uploadListName]];
        }
    }
    return _modelArray;
}



- (void)addUploadModel:(SPDocUploadModel *)model  {
    
    [self.modelArray addObject:model];
    [self refreshCaches];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSuperUploadFile object:nil];
}

- (void)removeUploadModel:(SPDocUploadModel *)model {
    
    model.isRunning = NO;
    [model.dataTask cancel];
    [self cleanPath:model.filePath];
    [self.modelArray removeObject:model];
    [self refreshCaches];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSuperFinishedUpload object:nil];
    if (self.modelArray.count == 0) {
        [self postNotice];
    }
    
}

- (void)postNotice {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSuperFinishedUpload object:nil];
}

- (void)refreshCaches {
    
    [[NSUserDefaults standardUserDefaults] setObject:[SPDocUploadModel mj_keyValuesArrayWithObjectArray:self.modelArray ignoredKeys:@[@"progressBlock",@"isRunning",@"dataTask"]] forKey:uploadListName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)cancelAllUploadOperations {
    
    for (SPDocUploadModel *docUploadModel in self.modelArray) {
        [docUploadModel.dataTask cancel];
        docUploadModel.isRunning = NO;
    }
    
    [self refreshCaches];
}

- (void)removeAll {
    
    [self cancelAllUploadOperations];
    [self.modelArray  removeAllObjects];
    [self refreshCaches];
    [self clean];
    [self postNotice];
    
}

#pragma mark- first upload 断点(NSURL)
- (void)uploadUrl:(NSURL *)mediaUrl withModel:(SPDocUploadModel *)model completion:(void(^)(void))completion {
    
    int64_t length = [self fileSizeAtPath:mediaUrl];
    NSInteger count = length / (kSuperUploadBlockSize);
    NSInteger blockCount = length % (kSuperUploadBlockSize) == 0 ? count : count + 1;
    
    model.filePath = [self writeToCacheUrl:mediaUrl appendNameString:model.lastPathComponent];
    model.totalCount = blockCount;
    model.totalSize = length;
    
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:mediaUrl.path];
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:model.filePath append:YES];
    [outputStream open];
    
    for (NSInteger i = 0; i < count ; i ++) {
       [handle seekToFileOffset:kSuperUploadBlockSize * i];
        @autoreleasepool {
            NSData *blockData = [handle readDataOfLength:kSuperUploadBlockSize];
            [outputStream write:blockData.bytes maxLength:blockData.length];
            blockData = nil;
        }
    }
    [outputStream close];
    [handle closeFile];
    
    [self uploadWithModel:model completion:completion];
    
}

#pragma mark- first upload 断点(NSData)
- (void)uploadData:(NSData *)data withModel:(SPDocUploadModel *)model completion:(void(^)(void))completion {
    
    NSInteger count = data.length / (kSuperUploadBlockSize);
    NSInteger blockCount = data.length % (kSuperUploadBlockSize) == 0 ? count : count + 1;
    
    model.filePath = [self writeToCacheVideo:data appendNameString:model.lastPathComponent];
    model.totalCount = blockCount;
    model.totalSize = data.length;
    
    [self uploadWithModel:model completion:completion];
}

#pragma mark- first upload
- (void)uploadWithModel:(SPDocUploadModel *)model completion:(void(^)(void))completion {
    
    model.uploadedCount = 0;
    model.isRunning = YES;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // 上传序列标识
    parameters[@"sequenceNo"] = @0;
    // 片大小
    parameters[@"blockSize"] = @(kSuperUploadBlockSize);
    // 总大小
    parameters[@"totFileSize"] = @(model.totalSize);
    // 扩展名
    parameters[@"suffix"] = model.filePath.pathExtension;
    // 参数和接口
    NSString *requestUrl = kSuperUploadTestUrl;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDataTask *dataTask = [manager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:[NSData data] name:@"block" fileName:model.filePath.lastPathComponent mimeType:@"application/octet-stream"];
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSDictionary *dataDict = responseObject[@"data"];
        model.upToken = dataDict[@"upToken"];
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:model.filePath];
        if (handle == nil) {  return; }
        [self continueUploadWithModel:model];
        [self addUploadModel:model];
        if (completion) { completion();}
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"SuperNSLog-- %@",error.description);
    }];
    
    model.dataTask = dataTask;

}

#pragma mark- continue upload
- (void)continueUploadWithModel:(SPDocUploadModel *)model {
    if (!model.isRunning) {
        return;
    }
    __block NSInteger i = model.uploadedCount;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"blockSize"] = @(kSuperUploadBlockSize);
    parameters[@"totFileSize"] = @(model.totalSize);
    parameters[@"suffix"] = model.filePath.pathExtension;
    parameters[@"upToken"] = model.upToken;
    parameters[@"sequenceNo"] = @(i + 1);
    
    NSString *requestUrl = kSuperUploadTestUrl;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDataTask *dataTask = [manager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:model.filePath];
        [handle seekToFileOffset:kSuperUploadBlockSize * i];
        NSData *blockData = [handle readDataOfLength:kSuperUploadBlockSize];
        [formData appendPartWithFileData:blockData name:@"block" fileName:model.filePath.lastPathComponent mimeType:@"application/octet-stream"];
        [handle closeFile];
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        i ++;
        model.uploadedCount = i;
        NSDictionary *dataDict = responseObject[@"data"];
        NSString *fileUrl = dataDict[@"fileUrl"];
        if ([fileUrl isKindOfClass:[NSString class]]) {
            
            [model.parameters setValue:fileUrl forKey:@"fileUrl"];
            [self saveRequest:model];
            
        }else {
            if (i < model.totalCount) {
                [self continueUploadWithModel:model];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        if (model.isRunning) {
            [self continueUploadWithModel:model];
        }
    }];
    
    model.dataTask = dataTask;
}


#pragma mark- clean cache file
- (void)clean {
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path =  [cachesDirectory stringByAppendingPathComponent:@"video"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtPath:path error:nil];
}

- (void)cleanPath:(NSString *)filePath {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtPath:filePath error:nil];
}

#pragma mark- write cache file
- (NSString *)writeToCacheVideo:(NSData *)data appendNameString:(NSString *)name {
    
    NSString *path = [self pathByAppendNameString:name];
    [data writeToFile:path atomically:NO];
    return path;
}

- (NSString *)writeToCacheUrl:(NSURL *)mediaUrl appendNameString:(NSString *)name {
    
    NSString *path = [self pathByAppendNameString:name];
    return path;
}


- (NSString *)pathByAppendNameString:(NSString *)name {
    
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *createPath =  [cachesDirectory stringByAppendingPathComponent:@"video"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *path = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/video/%.0f%@",[NSDate date].timeIntervalSince1970,name]];
    return path;
}


#pragma mark- saveRequest
- (void)saveRequest:(SPDocUploadModel *)model {
    
    // 操作
    
    // 处理完毕后
   [self removeUploadModel:model];
}

// 通过路径获取文件大小
- (long long)fileSizeAtPath:(NSURL *)mediaUrl {
    
    NSFileManager *manager =[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:mediaUrl.path]){
        return [[manager attributesOfItemAtPath:mediaUrl.path error:nil] fileSize];
    }else {
        return 0;
    }
    
}

@end
