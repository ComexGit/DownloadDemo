//
//  DownloadVC.h
//  DownloadDemo
//
//  Created by yuqian on 2018/10/11.
//  Copyright © 2018年 yuqian. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    DownloadWayURLSession,
    DownloadWayAFNetworking,
} DownloadWay;

@interface DownloadVC : UIViewController

@property (nonatomic, assign) DownloadWay downloadWay;

@end

NS_ASSUME_NONNULL_END
