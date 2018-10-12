//
//  DownloadVC.m
//  DownloadDemo
//
//  Created by yuqian on 2018/10/11.
//  Copyright © 2018年 yuqian. All rights reserved.
//

#import "DownloadVC.h"
#import "NSURLSession/URLSessionMgr.h"
#import "AFNetWorking/AFNetworkingMgr.h"

@interface DownloadVC () <URLSessionMgrDelegate,AFNetworkingMgrDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (strong, nonatomic) URLSessionMgr *sessionMgr;
@property (strong, nonatomic) AFNetworkingMgr *networkingMgr;
@end

@implementation DownloadVC

- (URLSessionMgr *)sessionMgr {
    
    if (!_sessionMgr) {
        
        NSString *url = @"https://dldir1.qq.com/weixin/mac/WeChat_2.3.18.18.dmg";
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"WeChat_2.3.18.18.dmg"];
        
        _sessionMgr = [[URLSessionMgr alloc]initWithDownloadUrl:url savePath:path delegate:self];
    }
    return _sessionMgr;
}

- (AFNetworkingMgr *)networkingMgr {
    
    if (!_networkingMgr) {
        
        NSString *url = @"https://dldir1.qq.com/weixin/mac/WeChat_2.3.18.18.dmg";
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"WeChat_2.3.18.18.dmg"];
        
        _networkingMgr = [[AFNetworkingMgr alloc]initWithDownloadUrl:url savePath:path delegate:self];
    }
    
    return _networkingMgr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _downloadWay == DownloadWayURLSession ? @"URLSession" : @"AFNetworking";
}

- (IBAction)clickDownloadBtn:(UIButton *)sender {
    
    sender.selected = !sender.isSelected;
    
    if (sender.selected) {
        
        if (_downloadWay == DownloadWayURLSession) {
            [self.sessionMgr resumeTask];
        }
        else {
            [self.networkingMgr resumeTask];
        }
        
    } else {
        
        if (_downloadWay == DownloadWayURLSession) {
            [self.sessionMgr suspendTask];
        }
        else {
            [self.networkingMgr suspendTask];
        }
    }
}

#pragma mark - URLSessionMgrDelegate

- (void)urlSession:(URLSessionMgr *)mgr didReceiveDataWithProgress:(double)progress {

    // 下载进度
    [self updateUI:progress];
}

- (void)AFNetworkingMgr:(nonnull AFNetworkingMgr *)mgr didReceiveDataWithProgress:(double)progress {
    [self updateUI:progress];
}

- (void) updateUI:(double)progress {
    
    self.progressView.progress =  progress;
    self.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:%.2f%%",100.0 * progress];
    
    //    NSLog(@"progress:%f", progress);
    
    if (progress == 1.0) {
        self.progressLabel.text = @"下载完成";
        self.downloadBtn.titleLabel.text = @"开始下载";
        self.downloadBtn.enabled = NO;
    }
}

@end
