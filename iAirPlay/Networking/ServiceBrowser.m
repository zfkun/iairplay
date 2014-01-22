//
//  ServerBrowser.m
//  iAirPlay
//
//  Created by zfkun on 13-7-28.
//  Copyright (c) 2013年 zfkun. All rights reserved.

#import "ServiceBrowserDelegate.h"
#import "ServiceBrowser.h"




#pragma mark - NSNetService (BrowserViewControllerAdditions)

// A category on NSNetService that's used to sort NSNetService objects by their name.
@interface NSNetService (BrowserViewControllerAdditions)

- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService *)aService;

@end

@implementation NSNetService (BrowserViewControllerAdditions)

- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService *)aService
{
	return [[self name] localizedCaseInsensitiveCompare:[aService name]];
}

@end




#pragma mark - Private properties and methods

@interface ServiceBrowser ()

// Sort services alphabetically
- (void) sortServices;

@end




@implementation ServiceBrowser

@synthesize delegate = _delegate;
@synthesize services = _services;
@synthesize type = _type;
@synthesize domain = _domain;


#pragma mark - Lifecycle

// Initialize
- (id)init
{
    self = [super init];

    if (self) {
        _services = [[NSMutableArray alloc] init];
        _type = @"";
        _domain = @"";
    }

    return self;
}

// Initialize with serviceType
- (id)initWithType:(NSString *)type inDomain:(NSString *)domain
{
    self = [self init];
    
    _type = type;
    _domain = domain;
    
    return self;
}


// Cleanup
- (void)dealloc
{
    if ( _services != nil ) {
        _services = nil;
    }
    
    _type = nil;
    _domain = nil;
    _delegate = nil;

//    [super dealloc];
}


// Start browsing for servers
- (BOOL) start
{
    // Restarting?
    if ( _netServiceBrowser != nil ) {
        [self stop];
    }
    
	_netServiceBrowser = [[NSNetServiceBrowser alloc] init];
	if( !_netServiceBrowser ) {
		return NO;
	}
    
	_netServiceBrowser.delegate = self;
	[_netServiceBrowser searchForServicesOfType:_type inDomain:_domain];
    
    return YES;
}

- (BOOL) startWithType:(NSString *)type inDomain:(NSString *)domain
{
    _type = type;
    return [self start];
}


// Terminate current service browser and clean up
- (void) stop {
    if ( _netServiceBrowser == nil ) {
        return;
    }
    
    [_netServiceBrowser stop];
    _netServiceBrowser = nil;
    
    [_services removeAllObjects];
}


// Sort servers array by service names
- (void) sortServices
{
    [_services sortUsingSelector:@selector(localizedCaseInsensitiveCompareByName:)];
}






#pragma mark - NSNetServiceBrowser Delegate Method Implementations

//// Will search service
//- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser
//{
//    NSLog(@">>>> netServiceBrowserWillSearch");
//    [_delegate serviceBrowserWillSearch:self];
//}
//
//// Did search stoped
//- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
//{
//    NSLog(@">>>> netServiceBrowserDidStopSearch");
//    [_delegate serviceBrowserDidStopSearch:self];
//}
//
//// Search error
//- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
//             didNotSearch:(NSDictionary *)errorDict
//{
//    NSLog(@">>>> search error: %@", errorDict);
//    [_delegate serviceBrowser:self didNotSearch:errorDict];
//}

// New service was found
- (void) netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
            didFindService:(NSNetService *)netService
                moreComing:(BOOL)moreServicesComing
{
    // Make sure that we don't have such service already (why would this happen? not sure)
    if ( ! [_services containsObject:netService] ) {
        [_services addObject:netService];
        [_delegate serviceBrowser:self didFindService:netService moreComing:moreServicesComing];
    }
    
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing ) {
        return;
    }
    
    // Sort alphabetically and let our delegate know
    [self sortServices];

    [_delegate serviceBrowserDidUpdate:self];
}


// Service was removed
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
    // Remove from list
    [_services removeObject:netService];
    
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing ) {
        return;
    }

    // Sort alphabetically and let our delegate know
    [self sortServices];

    [_delegate serviceBrowserDidUpdate:self];
}

@end
