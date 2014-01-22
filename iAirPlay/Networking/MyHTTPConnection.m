//
//  MyHTTPConnection.m
//  iAirPlay
//
//  Created by zfkun on 13-7-28.
//  Copyright (c) 2013年 zfkun. All rights reserved.
//


#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "MyHTTPDataResponse.h"
#import "TSHTTPDataResponse.h"
#import "HTTPFileResponse.h"
//#import "TSHTTPFileResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"


// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;


/**
 * All we have to do is override appropriate methods in HTTPConnection.
**/

@implementation MyHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Add support for POST
	
	if ([method isEqualToString:@"POST"]) {
        return NO;
	} else if ([method isEqualToString:@"GET"]) {
        return YES;
    }
	
	return [super supportsMethod:method atPath:path];
}

//- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
//{
//	HTTPLogTrace();
//	
//	// Inform HTTP server that we expect a body to accompany a POST request
//	
//	if ([method isEqualToString:@"POST"]) return YES;
//
//	return [super expectsRequestBodyFromMethod:method atPath:path];
//}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	HTTPLogTrace();
	
    // 一级. 多码流适配文件 m3u8
	if ([method isEqualToString:@"GET"] && [path isEqualToString:@"/"])
    {
        // ffprobe -v quiet -print_format json -show_format -show_streams ??.mkv
        
        NSLog(@"request!!  - %@ - %@", method, path);

        NSString *data = @"#EXTM3U\n\
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"audio\",LANGUAGE=\"und\",NAME=\"Original Audio\",DEFAULT=YES,AUTOSELECT=YES\n\
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=300000,CODECS=\"mp4a.40.2,avc1.640028\",AUDIO=\"audio\"\n\
/stream/0.m3u8\n\
#EXT-X-ENDLIST\n";

        return [[MyHTTPDataResponse alloc] initWithData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // 二级. 指定码流TS分片汇总 m3u8
    else if ([method isEqualToString:@"GET"] && [path isEqualToString:@"/stream/0.m3u8"])
    {
        NSLog(@"request!!  - %@ - %@", method, path);

        NSString *data = @"#EXTM3U\n\
#EXT-X-TARGETDURATION:10\n\
#EXT-X-PLAYLIST-TYPE:VOD\n\
#EXT-X-ALLOW-CACHE:YES\n\
#EXTINF:10,\n\
/stream/0/1.ts\n\
#EXTINF:10,\n\
/stream/0/2.ts\n\
#EXTINF:10,\n\
/stream/0/3.ts\n\
#EXTINF:10,\n\
/stream/0/4.ts\n\
#EXT-X-ENDLIST";

        return [[MyHTTPDataResponse alloc] initWithData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // 三级. TS分片文件 ts
    else if ( [method isEqualToString:@"GET"] && [path hasPrefix:@"/stream/0/"] )
    {
        NSLog(@"request stream st : %@", path);
        
        // ffmpeg -y -i 1.mkv -t 10 -ss 0 -vcodec copy -acodec copy -vbsf h264_mp4toannexb 1.ts 
        
        
//        NSData *response = nil;
        NSString *tsFilePath = nil;
        
        [path substringFromIndex:[@"/stream/0/" length]];
        
        
        
        if ([path hasSuffix:@"1.ts"]) {
            tsFilePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"ts"];
        } else if ([path hasSuffix:@"2.ts"]) {
            tsFilePath = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"ts"];
        } else if ([path hasSuffix:@"3.ts"]) {
            tsFilePath = [[NSBundle mainBundle] pathForResource:@"3" ofType:@"ts"];
        } else if ([path hasSuffix:@"4.ts"]) {
            tsFilePath = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"ts"];
        }
//        else if ([path hasSuffix:@"5.ts"]) {
//            tsFilePath = [[NSBundle mainBundle] pathForResource:@"5" ofType:@"ts"];
//        } else if ([path hasSuffix:@"6.ts"]) {
//            tsFilePath = [[NSBundle mainBundle] pathForResource:@"6" ofType:@"ts"];
//        } else if ([path hasSuffix:@"7.ts"]) {
//            tsFilePath = [[NSBundle mainBundle] pathForResource:@"7" ofType:@"ts"];
//        } else if ([path hasSuffix:@"8.ts"]) {
//            tsFilePath = [[NSBundle mainBundle] pathForResource:@"8" ofType:@"ts"];
//        }
        
//        response = [NSData dataWithContentsOfFile:tsFilePath];
//        response = [[NSData dataWithContentsOfFile:tsFilePath] dataUsingEncoding:NSUTF8StringEncoding];
//        return [[TSHTTPDataResponse alloc] initWithData:response];
        
        return [[HTTPFileResponse alloc] initWithFilePath:tsFilePath forConnection:self];
    }
	
	return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	HTTPLogTrace();
	
	// If we supported large uploads,
	// we might use this method to create/open files, allocate memory, etc.
}

- (void)processBodyData:(NSData *)postDataChunk
{
	HTTPLogTrace();
	
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
	
	BOOL result = [request appendData:postDataChunk];
	if (!result)
	{
		HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
	}
}

@end
