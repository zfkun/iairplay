//
//  ServerBrowser.h
//  iAirPlay
//
//  Created by zfkun on 13-7-28.
//  Copyright (c) 2013年 zfkun. All rights reserved.

#import <Foundation/Foundation.h>

@class ServiceBrowserDelegate;

@interface ServiceBrowser : NSObject <NSNetServiceBrowserDelegate>
{
    NSNetServiceBrowser *       _netServiceBrowser;
    NSMutableArray *            _services;
    id<ServiceBrowserDelegate>  _delegate;
}


@property (nonatomic, retain) id<ServiceBrowserDelegate> delegate;
@property (nonatomic, readonly) NSArray *services;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *domain;

// Initialize with serviceType
- (id)initWithType:(NSString *)type inDomain:(NSString *)domain;

// Start browsing for Bonjour services
- (BOOL)start;

// Start browsing for Bonjour services with serviceType & inDomain
- (BOOL) startWithType:(NSString *)type inDomain:(NSString *)domain;

// Stop everything
- (void)stop;

@end
