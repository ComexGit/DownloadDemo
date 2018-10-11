//
//  URLSessionMgr.m
//  DownloadDemo
//
//  Created by yuqian on 2018/10/11.
//  Copyright © 2018年 yuqian. All rights reserved.
//

#import "URLSessionMgr.h"

@interface URLSessionMgr() <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSURLSessionDataTask *downloadTask;

@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, copy) NSString *downloadUrl;
@property (nonatomic, copy) NSString *savePath;

@property (nonatomic, assign) NSInteger currentLength;
@property (nonatomic, assign) NSInteger fileLength;

@end

@implementation URLSessionMgr

- (instancetype) initWithDownloadUrl:(NSString*)url savePath:(NSString *)savePath delegate:(id<URLSessionMgrDelegate>)delegate {

    if (self = [super init]) {
        
        self.delegate = delegate;
        self.downloadUrl = url;
        self.savePath = savePath;
        
        self.operationQueue = [[NSOperationQueue alloc]init];
        self.operationQueue.maxConcurrentOperationCount = 1;
    }
    
    return self;
}

- (NSURLSession *)urlSession {
    
    if (!_urlSession) {
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.operationQueue];
    }
    return _urlSession;
}

- (NSURLSessionDataTask *)downloadTask {
    
    if (!_downloadTask) {
       
        NSURL *url = [NSURL URLWithString:_downloadUrl];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        // 设置HTTP请求头中的Range
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", self.currentLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        _downloadTask = [self.urlSession dataTaskWithRequest:request];
    }
    return _downloadTask;
}

- (void)resumeTask {
    
    NSInteger currentLength = [self fileLengthForPath:self.savePath];
    if (currentLength > 0) {  // 继续下载
        self.currentLength = currentLength;
    }
    
    [self.downloadTask resume];
}

- (void)suspendTask {
    
    [self.downloadTask suspend];
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


#pragma mark - NSURLSessionDataDelegate
/**
 * 接收到响应的时候：创建一个空的沙盒文件
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // 获得下载文件的总长度：请求下载的文件长度 + 当前已经下载的文件长度
    self.fileLength = response.expectedContentLength + self.currentLength;
    
    // 沙盒文件路径
    NSLog(@"File downloaded to: %@",_savePath);
    
    // 创建一个空的文件到沙盒中
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:_savePath]) {
        // 如果没有下载文件的话，就创建一个文件。如果有下载文件的话，则不用重新创建(不然会覆盖掉之前的文件)
        [manager createFileAtPath:_savePath contents:nil attributes:nil];
    }
    
    // 创建文件句柄
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:_savePath];
    
    // 允许处理服务器的响应，才会继续接收服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到具体数据：把数据写入沙盒文件中
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 指定数据的写入位置 -- 文件内容的最后面
    [self.fileHandle seekToEndOfFile];
    
    // 向沙盒写入数据
    [self.fileHandle writeData:data];
    
    // 拼接文件总长度
    self.currentLength += data.length;
    
//    NSLog(@"%ld",self.currentLength);
    
    __weak typeof(self) weakSelf = self;
    // 获取主线程，不然无法正确显示进度。
    NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
    [mainQueue addOperationWithBlock:^{
        
        if ([self.delegate respondsToSelector:@selector(urlSession:didReceiveDataWithProgress:)]) {
            [self.delegate urlSession:self didReceiveDataWithProgress:1.0 * weakSelf.currentLength / weakSelf.fileLength];
        }
    }];
}

/**
 *  下载完文件之后调用：关闭文件、清空长度
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    // 关闭fileHandle
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    
    // 清空长度
    self.currentLength = 0;
    self.fileLength = 0;
}


@end
