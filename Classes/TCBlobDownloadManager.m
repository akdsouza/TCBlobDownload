//
//  BlobDownloadManager.m
//
//  Created by Thibault Charbonnier on 16/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#import "TCBlobDownloadManager.h"

@interface TCBlobDownloadManager ()
{
    NSOperationQueue *_operationQueue;
}

@end

@implementation TCBlobDownloadManager


#pragma mark - Init and utilities


- (id)init
{
    if (self = [super init]) {
        _operationQueue = [[NSOperationQueue alloc] init];
        //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        //_defaultDownloadPath = [paths objectAtIndex:0];
        _defaultDownloadPath = NSTemporaryDirectory();
    }
    
    return self;
}

+ (id)sharedDownloadManager
{
    static dispatch_once_t onceToken;
    static id sharedMediaServer = nil;
    
    dispatch_once(&onceToken, ^{
        sharedMediaServer = [[[self class] alloc] init];
    });
    
    return sharedMediaServer;
}

- (void)setDefaultDownloadPath:(NSString *)pathToDL
{
    if ([TCBlobDownload createPathFromPath:pathToDL])
        _defaultDownloadPath = pathToDL;
}

- (NSUInteger)downloadCount
{
    return [_operationQueue operationCount];
}

- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrent
{
    [_operationQueue setMaxConcurrentOperationCount:maxConcurrent];
}


#pragma mark - TCBlobDownloads Management


- (void)startDownloadWithURL:(NSString *)urlString
                  customPath:(NSString *)customPathOrNil
                 andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil
{
    NSString *downloadPath = self.defaultDownloadPath;
    if (nil != customPathOrNil && [TCBlobDownload createPathFromPath:customPathOrNil])
        downloadPath = customPathOrNil;
    
    TCBlobDownload *downloader = [[TCBlobDownload alloc] initWithUrlString:urlString
                                                              downloadPath:downloadPath
                                                               andDelegate:delegateOrNil];
    [_operationQueue addOperation:downloader];
}

- (void)startDownloadWithURL:(NSString *)urlString
                  customPath:(NSString *)customPathOrNil
               progressBlock:(void (^)(float, float))progressBlock
                  errorBlock:(void (^)(NSError *))errorBlock
             completionBlock:(void (^)())completionBlock
{
    NSString *downloadPath = self.defaultDownloadPath;
    if (nil != customPathOrNil && [TCBlobDownload createPathFromPath:customPathOrNil])
        downloadPath = customPathOrNil;
    
    TCBlobDownload *downloader = [[TCBlobDownload alloc] initWithUrlString:urlString
                                                              downloadPath:customPathOrNil
                                                             progressBlock:progressBlock
                                                                errorBlock:errorBlock
                                                           completionBlock:completionBlock];
    [_operationQueue addOperation:downloader];
}

- (void)startDownload:(TCBlobDownload *)blobDownload
{
    [_operationQueue addOperation:blobDownload];
}

- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove
{
    for (TCBlobDownload *blob in [_operationQueue operations])
        [blob cancelDownloadAndRemoveFile:remove];
#ifdef DEBUG
    NSLog(@"Cancelled all downloads.");
#endif
}

@end
