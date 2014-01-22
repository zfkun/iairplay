//
//  ServiceResolverDelegate.h
//  iAirPlay
//
//  Created by zfkun on 13-8-3.
//  Copyright (c) 2013年 zfkun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServiceResolver;


@protocol ServiceResolverDelegate <NSObject>

@required
- (void) serviceResolverDidResolve:(ServiceResolver *)sender forService:(NSNetService *)service;
- (void) serviceResolver:(ServiceResolver *)sender didNotResolve:(NSDictionary *)errorDict;

@end
