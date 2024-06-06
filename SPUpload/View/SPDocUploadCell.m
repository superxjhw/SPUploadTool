//
//  SPDocUploadCell.m
//  
//
//  Created by SPSuper on 2017/7/12.
//  Copyright © 2017年 Super. All rights reserved.
//

#import "SPDocUploadCell.h"
#import "SPDocUploadModel.h"
#import "SPDocUpListVC.h"

@interface SPDocUploadCell ()

@property (nonatomic, weak) UIImageView *typeImangeView ;
@property (nonatomic, weak) UILabel *fileTitlelabel;
@property (nonatomic, weak) UILabel *progressLabel;
@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, weak) UILabel *runningLabel;



@end

@implementation SPDocUploadCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *typeImangeView = [[UIImageView alloc] init];
        [self.contentView addSubview:typeImangeView];
        typeImangeView.contentMode = UIViewContentModeScaleAspectFill;
        typeImangeView.layer.masksToBounds = YES;
        self.typeImangeView = typeImangeView;
        [typeImangeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.centerY.equalTo(self.mas_centerY);
            make.width.height.equalTo(@60);
        }];
        
        UILabel *fileTitlelabel = [[UILabel alloc] init];
        fileTitlelabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:fileTitlelabel];
        self.fileTitlelabel = fileTitlelabel;
        [fileTitlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-20);
            make.top.equalTo(@15);
            make.left.equalTo(typeImangeView.mas_right).offset(20);
            make.height.equalTo(@25);
        }];
        
        UILabel *progressLabel = [[UILabel alloc] init];
        progressLabel.textColor = [UIColor grayColor];
        progressLabel.font = [UIFont systemFontOfSize:12];;
        [self.contentView addSubview:progressLabel];
        self.progressLabel = progressLabel;
        [progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(fileTitlelabel.mas_bottom);
            make.left.equalTo(fileTitlelabel.mas_left);
            make.width.equalTo(fileTitlelabel.mas_width);
            make.height.equalTo(@20);
        }];
        
        UIProgressView *progressView = [[UIProgressView alloc] init];
        progressView.transform = CGAffineTransformMakeScale(1.0, 1.5);
        [self.contentView addSubview:progressView];
        self.progressView = progressView;
        [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(progressLabel.mas_bottom).offset(5);
            make.left.equalTo(progressLabel.mas_left);
            make.width.equalTo(progressLabel.mas_width);
        }];
        
        UILabel *runningLabel = [[UILabel alloc] init];
        runningLabel.textColor = [UIColor lightGrayColor];
        runningLabel.textAlignment = NSTextAlignmentRight;
        runningLabel.font = [UIFont systemFontOfSize:12];;
        [self.contentView addSubview:runningLabel];
        self.runningLabel = runningLabel;
        [runningLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(fileTitlelabel.mas_bottom);
            make.right.equalTo(self.contentView.mas_right).offset(-20);
            make.width.equalTo(@100);
            make.height.equalTo(@20);
            
        }];
        
        UIView *sepView = [[UIView alloc] init];
        [self addSubview:sepView];
        sepView.backgroundColor = [UIColor lightGrayColor];
        [sepView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(@0);
            make.height.equalTo(@1);
        }];
        
    }
    
    return  self;
}



- (void)setDocUploadModel:(SPDocUploadModel *)docUploadModel {
    
    docUploadModel.progressBlock = ^(CGFloat uploadPersent,NSString *progressLableText){
        self.progressLabel.text = progressLableText;
        self.progressView.progress = uploadPersent;
        [[SPUploadManager shareUploadManager] refreshCaches];
    };
    
    self.progressLabel.text = docUploadModel.progressLableText;
    self.progressView.progress = docUploadModel.uploadPercent;
    
    switch (docUploadModel.fileType) {

        case SPFileTypePhoto:
            _typeImangeView.image = [UIImage imageWithContentsOfFile:docUploadModel.filePath];
            break;
        case SPFileTypeVideo:
            _typeImangeView.image = [UIImage imageNamed:@"video"];
            break;

        default:
            _typeImangeView.image = [UIImage imageNamed:@"document"];
            break;
    }
    
    if (docUploadModel.isRunning) {
        self.runningLabel.text = @"正在上传...";
    }else {
        self.runningLabel.text = @"已暂停";
    }
    self.fileTitlelabel.text = docUploadModel.title;
    _docUploadModel = docUploadModel;
}


@end
