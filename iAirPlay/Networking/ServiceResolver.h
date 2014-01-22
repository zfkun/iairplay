//
//  ServiceResolver.h
//  iAirPlay
//
//  Created by zfkun on 13-8-3.
//  Copyright (c) 2013年 zfkun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServiceResolverDelegate;

@interface ServiceResolver : NSObject <NSNetServiceDelegate>

{
    NSString *                  _host;
    NSString *                  _domain;
    NSString *                  _ip;
    NSInteger                   _port;
    NSNetService *              _service;
    NSTimeInterval              _timeout;
    
    
//    NSMutableArray *            _services;
    
    id<ServiceResolverDelegate> _delegate;
}


@property (nonatomic, retain) id<ServiceResolverDelegate> delegate;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *ip;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, readonly) NSNetService *service;
@property (nonatomic, assign) NSTimeInterval timeout;
//@property (nonatomic, readonly) NSArray *services;


// Initialize with NetService
- (id)initWithService:(NSNetService *)service;

// Start resolve for Bonjour services
- (BOOL)start;

// Start resolve for Bonjour services with NetService
- (BOOL)startWithService:(NSNetService *)service;

// Stop everything
- (void)stop;


@end
