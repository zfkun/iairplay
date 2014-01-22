//
//  AppDelegate.m
//  iAirPlay
//
//  Created by zfkun on 13-7-28.
//  Copyright (c) 2013年 zfkun. All rights reserved.
//

#import "AppDelegate.h"
#import "IPAddress.h"
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <arpa/inet.h>
//#include "libavformat/avformat.h"



// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    NSString *ip = [IPAddress localIPAddress];
//    NSLog(@"current host: %@", ip);
    
//    av_register_all();
//    return;
    
    // init logging framework.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];

    // init HLS(HTTP Live Stream) ip & port
    _hlsIP = [IPAddress localIPAddress]; // local IP for `en1`
    _hlsPort = 123456;
    
    // init service list table
    _serviceView.dataSource = self;
    _serviceView.delegate = self;
    
    // init ServerBrowser
    _brower = [[ServiceBrowser alloc] initWithType:@"_airplay._tcp" inDomain:@"local"];
    _brower.delegate = self;
    
//    [self searchForDomains];
//    [self searchForDomains:YES];
//    [self searchForServices];

    
    if ([_brower start]) {
        NSLog(@">> Browser Start Success: `%@.%@`", _brower.type, _brower.domain);
        [self startHLSServer];
    } else {
        NSLog(@">> Browser Start Fail: `%@.%@`", _brower.type, _brower.domain);
    }

}





# pragma mark - Private Methods

- (BOOL)startHLSServer
{
    if (!_server) {
        // Initalize our http server
        _server = [[HTTPServer alloc] init];
	
        // Tell the server to broadcast its presence via Bonjour.
        // This allows browsers such as Safari to automatically discover our service.
        [_server setType:@"_http._tcp."];
	
        // Normally there's no need to run our server on any specific port.
        // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
        // However, for easy testing you may want force a certain port so you can just hit the refresh button.
        [_server setPort:_hlsPort];
	
        // We're going to extend the base HTTPConnection class with our MyHTTPConnection class.
        // This allows us to do all kinds of customizations.
        [_server setConnectionClass:[MyHTTPConnection class]];
	
//      // Serve files from our embedded Web folder
//      NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
//      DDLogInfo(@"Setting document root: %@", webPath);
//	
//      [_server setDocumentRoot:webPath];
	}

	NSError *error = nil;
	if ([_server start:&error]) {
//        DDLogInfo(@"Started HTTP Server on port %hu", [_server listeningPort]);
        return YES;
	} else {
//        DDLogError(@"Error starting HTTP Server: %@", error);
        return NO;
    }
}

- (void)stopHLSServer
{
    if (_server) {
        [_server stop];
    }
}

- (void)playVideo
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%li/play", _serverIP, _serverPort]];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:0];
//    [headers setObject:@"iTunes/10.6 (Macintosh; Intel Mac OS X 10.7.3) AppleWebKit/535.18.5" forKey:@"User-Agent"];
//    [headers setObject:@"iTunes/11.0.4" forKey:@"User-Agent"];
//    [headers setObject:@"text/parameters" forKey:@"Content-Type"];
    
    NSMutableData *bodys = [NSMutableData dataWithCapacity:0];
//    [bodys appendData:[[NSString stringWithFormat:@"Content-Location: http://%@:%li/v/1.mp4\n", _hlsIP, _hlsPort]
//                       dataUsingEncoding:NSUTF8StringEncoding]];
    [bodys appendData:[[NSString stringWithFormat:@"Content-Location: http://%@:%li/\n", _hlsIP, _hlsPort]
                       dataUsingEncoding:NSUTF8StringEncoding]];
    [bodys appendData:[@"Start-Position: 0.000000\n" dataUsingEncoding:NSUTF8StringEncoding]];

//    [self startHLSServer];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request setRequestHeaders:headers];
    [request setPostBody:bodys];
    [request setShouldAttemptPersistentConnection:YES];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)playbackInfo
{
    // GET /playback-info
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%li/playback-info", _serverIP, _serverPort]];

    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:0];
//    [headers setObject:@"iTunes/11.0.4" forKey:@"User-Agent"];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];

    [request setRequestHeaders:headers];    
    [request setDelegate:self];
    [request startAsynchronous];
}



- (void)resolveService:(NSInteger)serverIndex
{
    NSNetService *service = [_brower.services objectAtIndex:serverIndex];
    if (service != nil) {
        NSLog(@">> will resolve service: %@.%@:%li", service.hostName, service.domain, service.port);
        
//        if (_connecter != nil) {
//            NSLog(@">> already connected, close it firset ..");
//            [_connecter close];
//            _connecter = nil;
//            NSLog(@">> old connect closed");
//        }
//        
//        _connecter = [[Connection alloc] initWithNetService:service];
//        _connecter.delegate = self;
//    
//        if ([_connecter connect]) {
//            NSLog(@">> Connect to %@  : %li ..", _connecter.host, _connecter.port);
//        } else {
//            NSLog(@">> Connect fail to %@ : %li", _connecter.host, _connecter.port);
//        }

        if (_resolver != nil) {
            NSLog(@">> already resolved, stop it firset ..");
            [_resolver stop];
            _resolver = nil;
            NSLog(@">> old _resolver stoped");
        }
        
        _resolver = [[ServiceResolver alloc] initWithService:service];
        _resolver.delegate = self;
        
        if ([_resolver start]) {
            NSLog(@">> Resolve start, %@ : %li ..", _resolver.host, _resolver.port);
        } else {
            NSLog(@">> Resolve fail, %@ : %li", _resolver.host, _resolver.port);
        }

    }
}




# pragma mark - ServiceBrowserDelegate implementations
//- (void)serviceBrowserWillSearch:(ServiceBrowser *)sender
//{
//    NSLog(@"----> netServiceBrowserWillSearch");
//}

- (void)serviceBrowserDidUpdate:(ServiceBrowser *)sender
{
    NSLog(@"%@: server list updated, will refresh TableView ...", THIS_FILE);
    
    [self.serviceView reloadData];
}

- (void)serviceBrowser:(ServiceBrowser *)sender
       didFindService:(NSNetService *)netService
           moreComing:(BOOL)moreComing
{
    NSLog(@"%@: didFindService: %@ , %li", THIS_FILE, netService.name, netService.port);
    
//    if (_resolver != nil) {
//        NSLog(@">> already resolved, stop it firset ..");
//        [_resolver stop];
//        _resolver = nil;
//        NSLog(@">> old _resolver stoped");
//    }
//    
//    _resolver = [[ServiceResolver alloc] initWithService:netService];
//    _resolver.delegate = self;
//    
//    if ([_resolver start]) {
//        NSLog(@">> Resolve start, %@ : %li ..", _resolver.host, _resolver.port);
//    } else {
//        NSLog(@">> Resolve fail, %@ : %li", _resolver.host, _resolver.port);
//    }
    
//    if (!moreComing) {
//        [_brower.services performSelector:@selector(serviceResolve:)];
//    }
    
//    if (!moreComing) {
//        ServiceResolver *resolver = [[ServiceResolver alloc] initWithService:netService];
//        [resolver setDelegate:self];
//        [resolver start];
//    }
}





# pragma mark - ServiceResolverDelegate implementation

- (void)serviceResolverDidResolve:(ServiceResolver *)sender
                       forService:(NSNetService *)service
{
    NSLog(@"%@: service did resolve: %@:%li , %@", THIS_FILE, sender.ip, sender.port, service.addresses);
    
    _serverIP = sender.ip;
    _serverPort = sender.port;
    
    [self.serviceView reloadData];

    [self playVideo];
}

- (void)serviceResolver:(ServiceResolver *)sender
          didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"%@: service did not resolve: %@", THIS_FILE, sender);
}








# pragma mark - ASIHTTPRequestDelegate implementations

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@: requestFinished : %@ ..", THIS_FILE, request);
    
//    [self playbackInfo];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%@: requestFailed: %@..", THIS_FILE, request.error);
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"%@: request started ..", THIS_FILE);
}

- (void)requestRedirected:(ASIHTTPRequest *)request
{
    NSLog(@"%@: request redirected ..", THIS_FILE);
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    NSLog(@"%@: request didReceiveData: %@", THIS_FILE, data);
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"%@: request didReceiveResponseHeaders: %@", THIS_FILE, responseHeaders);
}

- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL
{
    NSLog(@"%@: request willRedirectToURL: %@", THIS_FILE, [newURL absoluteString]);
}








# pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (_brower == nil) {
        return 0;
    }

    return [_brower.services count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *val = nil;

    NSNetService *service = [_brower.services objectAtIndex:row];
    
    if ([[tableColumn identifier] isEqualToString:@"ServiceAddress"]) {
        // Cell `ServiceAddress`
        val = [NSString stringWithFormat:@"%@:%li", service.hostName, service.port];
    } else if ([[tableColumn identifier] isEqualToString:@"ServiceName"]) {
        // Cell `ServiceName`
        val = service.name;
    }
    
    return val;
}



# pragma mark - NSTableViewDelegate

//- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
//{
////    tableView.selectedRow
//    NSLog(@"didClickTableColumn: %@", tableColumn);
//}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
//    NSTableRowView *rowView = [tableView rowViewAtRow:row makeIfNecessary:NO];
//    NSTableCellView *cellView = [rowView viewAtColumn:tableView.selectedColumn];

    NSLog(@"%@: shouldSelectRow: %li", THIS_FILE, row);
    
//    [self serviceResolve:row withTimeout:5.0];
    [self resolveService:row];
    
    return YES;
}

@end
