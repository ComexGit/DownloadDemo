
//
//  DownloadOptionVC.m
//  DownloadDemo
//
//  Created by yuqian on 2018/10/11.
//  Copyright © 2018年 yuqian. All rights reserved.
//

#import "DownloadOptionVC.h"
#import "DownloadVC.h"


@interface DownloadOptionVC ()

@end

@implementation DownloadOptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    DownloadVC *vc = segue.destinationViewController;
    vc.downloadWay = [segue.identifier isEqualToString:@"URLSession"] ? DownloadWayURLSession : DownloadWayAFNetworking;
}


@end
