//
//  AppDelegate.h
//  iAirPlay
//
//  Created by zfkun on 13-7-28.
//  Copyright (c) 2013年 zfkun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ServiceBrowserDelegate.h"
#import "ServiceBrowser.h"

#import "ServiceResolverDelegate.h"
#import "ServiceResolver.h"

#import "HTTPServer.h"

#import "ASIHTTPRequestDelegate.h"
#import "ASIHTTPRequest.h"


@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource, ServiceBrowserDelegate, ServiceResolverDelegate, ASIHTTPRequestDelegate>

{
    // HTTP Live Stream
    NSString *          _hlsIP;
    NSInteger           _hlsPort;
    HTTPServer *        _server;

    // AirPlay Server Info: ip and port
    NSString *          _serverIP;
    NSInteger           _serverPort;
    
    // NetService Brower
    ServiceBrowser *    _brower;
    
    // NetService Resolver
    ServiceResolver *   _resolver;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *serviceView;

@end
