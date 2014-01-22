//
//  ServiceBrowserDelegate.h
//  iAirPlay
//
//  Created by zfkun on 13-7-28.
//  Copyright (c) 2013年 zfkun. All rights reserved.

#import <Foundation/Foundation.h>

@class ServiceBrowser;

@protocol ServiceBrowserDelegate

//@optional
//- (void)serviceBrowserWillSearch:(ServiceBrowser *)sender;
//
//- (void)serviceBrowserDidStopSearch:(ServiceBrowser *)sender;
//
//- (void)serviceBrowser:(ServiceBrowser *)sender
//         didNotSearch:(NSDictionary *)errorDict;


@required

- (void)serviceBrowser:(ServiceBrowser *)sender
        didFindService:(NSNetService *)netService
            moreComing:(BOOL)moreComing;

- (void)serviceBrowserDidUpdate:(ServiceBrowser *)sender;


@end
