//
//  AFNetworkingMgr.h
//  DownloadDemo
//
//  Created by yuqian on 2018/10/11.
//  Copyright © 2018年 yuqian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AFNetworkingMgr;

@protocol AFNetworkingMgrDelegate <NSObject>

- (void) AFNetworkingMgr:(AFNetworkingMgr*)mgr didReceiveDataWithProgress:(double)progress;

@end

@interface AFNetworkingMgr : NSObject

@property (nonatomic, weak) id<AFNetworkingMgrDelegate> delegate;

- (instancetype) initWithDownloadUrl:(NSString*)url savePath:(NSString *)savePath delegate:(id<AFNetworkingMgrDelegate>)delegate;
- (void)resumeTask;
- (void)suspendTask;

@end

NS_ASSUME_NONNULL_END
