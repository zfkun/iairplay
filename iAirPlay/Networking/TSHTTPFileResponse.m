//
//  TSHTTPFileResponse.m
//  iAirPlay
//
//  Created by zfkun on 13-8-17.
//  Copyright (c) 2013年 zfkun. All rights reserved.
//

#import "TSHTTPFileResponse.h"
#import "HTTPLogging.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_OFF; // | HTTP_LOG_FLAG_TRACE;


@implementation TSHTTPFileResponse

- (NSDictionary *)httpHeaders
{
	HTTPLogTrace();
	
	return [NSDictionary dictionaryWithObject:@"video/MP2T" forKey:@"Content-Type"];
}

@end
