//
//  SPDocUploadModel.m
//  
//
//  Created by SPSuper on 2017/7/12.
//  Copyright © 2017年 Super. All rights reserved.
//

#import "SPDocUploadModel.h"

@implementation SPDocUploadModel

- (void)setUploadedCount:(NSInteger)uploadedCount {
    
    _uploadedCount = uploadedCount;
    
    self.uploadPercent = (CGFloat)uploadedCount / self.totalCount;
    self.progressLableText = [NSString stringWithFormat:@"%.2fMB/%.2fMB",self.totalSize * self.uploadPercent /1024.0/1024.0,self.totalSize/1024.0/1024.0];
    if (self.progressBlock) {
        self.progressBlock(self.uploadPercent,self.progressLableText);
    }
    
    [[SPUploadManager shareUploadManager] refreshCaches];
    
}

@end
