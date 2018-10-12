//
//  AFNetworkingMgr.m
//  DownloadDemo
//
//  Created by yuqian on 2018/10/11.
//  Copyright © 2018年 yuqian. All rights reserved.
//

#import "AFNetworkingMgr.h"
#import <AFNetworking.h>


@interface AFNetworkingMgr()

@property (nonatomic, strong) AFURLSessionManager *sessionMgr;
@property (nonatomic, strong) NSURLSessionDataTask *downloadTask;

@property (nonatomic, assign) NSInteger fileLength;
@property (nonatomic, assign) NSInteger currentLength;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, copy) NSString *downloadUrl;
@property (nonatomic, copy) NSString *savePath;

@end

@implementation AFNetworkingMgr

- (instancetype) initWithDownloadUrl:(NSString*)url savePath:(NSString *)savePath delegate:(id<AFNetworkingMgrDelegate>)delegate {
    
    if (self = [super init]) {
        self.downloadUrl = url;
        self.savePath = savePath;
    }
    return self;
}

- (AFURLSessionManager *)sessionMgr {
    
    if (!_sessionMgr) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionMgr = [[AFURLSessionManager alloc]initWithSessionConfiguration:config];
    }
    return _sessionMgr;
}

- (NSURLSessionDataTask *)downloadTask {
    if (!_downloadTask) {
        
        NSURL *url = [NSURL URLWithString:_downloadUrl];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        // 设置HTTP请求头中的Range
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", self.currentLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        __weak typeof(self) weakSelf = self;
        
        [self.sessionMgr dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            // 清空长度
            weakSelf.currentLength = 0;
            weakSelf.fileLength = 0;
            
            // 关闭fileHandle
            [weakSelf.fileHandle closeFile];
            weakSelf.fileHandle = nil;
        }];
        
//        _downloadTask = [self.sessionMgr dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//            NSLog(@"dataTaskWithRequest");
//
//            // 清空长度
//            weakSelf.currentLength = 0;
//            weakSelf.fileLength = 0;
//
//            // 关闭fileHandle
//            [weakSelf.fileHandle closeFile];
//            weakSelf.fileHandle = nil;
//
//        }];
        
        [self.sessionMgr setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
            NSLog(@"NSURLSessionResponseDisposition");
            
            // 获得下载文件的总长度：请求下载的文件长度 + 当前已经下载的文件长度
            weakSelf.fileLength = response.expectedContentLength + self.currentLength;
            
            // 沙盒文件路径
            NSLog(@"File downloaded to: %@",weakSelf.savePath);
            
            // 创建一个空的文件到沙盒中
            NSFileManager *manager = [NSFileManager defaultManager];
            
            if (![manager fileExistsAtPath:weakSelf.savePath]) {
                // 如果没有下载文件的话，就创建一个文件。如果有下载文件的话，则不用重新创建(不然会覆盖掉之前的文件)
                [manager createFileAtPath:weakSelf.savePath contents:nil attributes:nil];
            }
            
            // 创建文件句柄
            weakSelf.fileHandle = [NSFileHandle fileHandleForWritingAtPath:weakSelf.savePath];
            
            // 允许处理服务器的响应，才会继续接收服务器返回的数据
            return NSURLSessionResponseAllow;
        }];
        
        [self.sessionMgr setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
            NSLog(@"setDataTaskDidReceiveDataBlock");
            
            // 指定数据的写入位置 -- 文件内容的最后面
            [weakSelf.fileHandle seekToEndOfFile];
            
            // 向沙盒写入数据
            [weakSelf.fileHandle writeData:data];
            
            // 拼接文件总长度
            weakSelf.currentLength += data.length;
            
            // 获取主线程，不然无法正确显示进度。
            NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
               
                if ([weakSelf.delegate respondsToSelector:@selector(AFNetworkingMgr:didReceiveDataWithProgress:)]) {
                    [weakSelf.delegate AFNetworkingMgr:weakSelf didReceiveDataWithProgress:1.0 * weakSelf.currentLength / weakSelf.fileLength];
                }
                
            }];
        }];
    }
    return _downloadTask;
}

- (NSInteger)fileLengthForPath:(NSString *)path {
    
    NSInteger fileLength = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileLength = [fileDict fileSize];
        }
    }
    return fileLength;
}

@end
