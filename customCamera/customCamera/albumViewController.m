//
//  albumViewController.m
//  customCamera
//
//  Created by David on 16/7/25.
//  Copyright © 2016年 detu. All rights reserved.
//

#import "albumViewController.h"
#import <Photos/Photos.h>
#import "cameraViewController.h"

@interface albumViewController ()<PHPhotoLibraryChangeObserver, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy) NSMutableArray *mArray;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation albumViewController


- (NSMutableArray *)mArray {
    
    if (!_mArray) {
        _mArray = [NSArray  array].mutableCopy;
    }
    return _mArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusDenied) {
        NSLog(@"没权限啦");
        
    }else {
       self.mArray = [self getAllAssetInPhotoAblumWithAscending:YES].mutableCopy;
        
        [self.tableView reloadData];
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    self.view.backgroundColor = [UIColor orangeColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenW, ScreenH-64)];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];
}

- (void)back {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (NSArray <PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL )ascending {
    
    NSMutableArray <PHAsset *> *assets = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        [assets addObject:asset];
        
    }];
    return assets;
}


//相册内容有变化
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
    });
    
}

#pragma delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.mArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    NSString *file = [_mArray[indexPath.row] valueForKey:@"filename"];
    cell.textLabel.text = file;
    
    //返回缩略图
//    NSString *thumbPath = [file getThumbPath];
//    
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbPath]];
//    
//    UIImage *img = [UIImage imageWithData:data];
//    
//    cell.imageView.image = img;
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}



@end
