//
//  URLSessionMgr.h
//  DownloadDemo
//
//  Created by yuqian on 2018/10/11.
//  Copyright © 2018年 yuqian. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class URLSessionMgr;

@protocol URLSessionMgrDelegate <NSObject>

- (void) urlSession:(URLSessionMgr*)mgr didReceiveDataWithProgress:(double)progress;

@end

@interface URLSessionMgr : NSObject

@property (nonatomic, weak) id<URLSessionMgrDelegate> delegate;

- (instancetype) initWithDownloadUrl:(NSString*)url savePath:(NSString *)savePath delegate:(id<URLSessionMgrDelegate>)delegate;
- (void)resumeTask;
- (void)suspendTask;

@end

NS_ASSUME_NONNULL_END
