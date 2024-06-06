//
//  ViewController.m
//  SPUploadDemo
//
//  Created by SPSuper on 2017/12/25.
//  Copyright © 2017年 SPSuper. All rights reserved.
//

#import "ViewController.h"
#import "SPDocUpListVC.h"
#import "SPDocUploadModel.h"


@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, copy) NSURL *mediaUrl;
@property (nonatomic, assign) SPFileType fileType;
@property (nonatomic, strong) UIImage *selectImage;

@end

@implementation ViewController

- (IBAction)uploadButtonClick:(UIButton *)sender {
    
    
//    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    //包含视频
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        NSLog(@"SuperNSLog-- 请允许访问手机相册");
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:( NSString *)kUTTypeImage]) {
        self.fileType = SPFileTypePhoto;
        self.selectImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.mediaUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    }else {
        self.fileType = SPFileTypeVideo;
        self.mediaUrl = [info objectForKey:UIImagePickerControllerMediaURL];
    }
    
    [self upload];
    
   
    
}

- (void)upload {
    
    SPDocUploadModel *model = [[SPDocUploadModel alloc] init];
    model.title = @"上传文件测试";
    model.lastPathComponent = self.mediaUrl.lastPathComponent;
    model.fileType = self.fileType;
    // 保存上传成功后 接下来调用接口的参数的url \
    这边app上传列表是统一的，文件服务器返回fileUrl后直接拿到url调用接下来的保存接口
    model.requestUrl = nil;
    model.parameters = nil;
    
    NSData *data;
    if (self.fileType == SPFileTypePhoto) {
        data = UIImageJPEGRepresentation(self.selectImage, 1);
        [[SPUploadManager shareUploadManager] uploadData:data withModel:model completion:^{
            [self myUploadListItemClick:nil];
        }];
    }else {
        [[SPUploadManager shareUploadManager] uploadUrl:self.mediaUrl withModel:model completion:^{
            [self myUploadListItemClick:nil];
        }];
    }
  
}


- (IBAction)myUploadListItemClick:(id)sender {
    
    SPDocUpListVC *uploadListVC = [[SPDocUpListVC alloc] init];
    [self.navigationController pushViewController:uploadListVC animated:YES];
    
}






@end
