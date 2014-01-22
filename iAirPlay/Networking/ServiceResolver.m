//
//  ServiceResolver.m
//  iAirPlay
//
//  Created by zfkun on 13-8-3.
//  Copyright (c) 2013年 zfkun. All rights reserved.
//

#import "ServiceResolverDelegate.h"
#import "ServiceResolver.h"
#import "IPAddress.h"
#import <arpa/inet.h>



@interface ServiceResolver()

//@property (nonatomic, retain) NSNetService *netService;

@end




@implementation ServiceResolver

//@synthesize services = _services;
@synthesize domain = _domain, host = _host, ip = _ip, port = _port, timeout = _timeout;
@synthesize service = _service;
@synthesize delegate = _delegate;
//@synthesize netService = _netService;



# pragma mark - ServiceResolver - Lifecycle

// Init
- (id)init
{
    self = [super init];
    
    if (self) {
//        _services = [[NSMutableArray alloc] init];
        _domain = nil;
        _host = nil;
        _ip = nil;
        _port = -1;
        _timeout = 5.0;
    }
    
    return self;
}

- (id)initWithService:(NSNetService *)service
{
    _service = service;
    _domain = service.domain;
    _host = service.hostName;
    _port = service.port;
    
    return [self init];
}


- (void)dealloc
{
//    if (_services != nil) {
//        _services = nil;
//    }
    
    _domain = nil;
    _host = nil;
    _ip = nil;
    _port = -1;
//    _timeout = ;
    _service = nil;
    _delegate = nil;
}





# pragma mark - ServiceResolver - Public & Private Methods

- (BOOL)start
{
    if (_service == nil) {
        return NO;
    }
    
    if (_ip != nil && _host != nil && _domain != nil) {
        [_delegate serviceResolverDidResolve:self forService:_service];
        return YES;
    }
    
    [_service setDelegate:self];
    [_service resolveWithTimeout:_timeout];
    
    return NO;
}

- (BOOL)startWithService:(NSNetService *)service
{
    _service = service;
    return [self start];
}

- (void)stop
{
    
}







# pragma mark - NSNetService Delegate Method Implementations

// Called if we weren't able to resolve net service
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    if ( sender != _service ) {
        return;
    }

    // Close everything and tell delegate that we have failed
    [_delegate serviceResolver:self didNotResolve:errorDict];

    [self stop];
}


// Called when net service has been successfully resolved
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    if ( sender != _service ) {
        return;
    }
    
    // Save Service info
    _domain = sender.domain;
    _host = sender.hostName;
    _port = sender.port;
    _ip = [IPAddress ipAddressWithData:[sender.addresses objectAtIndex:0]];
    
    // Notify
    [_delegate serviceResolverDidResolve:self forService:sender];
    
    // Don't need the service anymore
    _service = nil;
}



@end
