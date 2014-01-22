//
//  IPAddress.m
//  iAirPlay
//
//  Created by zfkun on 13-8-6.
//  Copyright (c) 2013年 zfkun. All rights reserved.
//

#import <arpa/inet.h>
#import <net/if.h>
#import <ifaddrs.h>

#import "IPAddress.h"

@implementation IPAddress

+ (NSString *)ipWithSockaddr:(struct sockaddr *)addr
{
    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)addr)->sin_addr)];
}

+ (NSString *)localIPAddressWithName:(NSString *)interfaceName
{
    NSString *ip = nil;
    
    struct ifaddrs *addrs;
    
    // retrieve the current interfaces - returns 0 on success
    if ( getifaddrs(&addrs) == 0 ) {
        const struct ifaddrs *cursor = addrs;

        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0) {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                
                NSLog(@"%s: interface `%@`, ip `%@`", __FILE__, name, [IPAddress ipWithSockaddr:cursor->ifa_addr]);
                
                if ([name isEqualToString:interfaceName]) {
                    ip = [IPAddress ipWithSockaddr:cursor->ifa_addr];
                    break;
                }
            }
            cursor = cursor->ifa_next;
        }
    
        freeifaddrs(addrs);
    }
    
    return ip;
}


+ (NSString *)localIPAddress
{
    return [IPAddress localIPAddressWithName:@"en1"];
}


+ (NSString *)ipAddressWithData:(NSData *)data
{
    struct sockaddr_in *socketAddress = (struct sockaddr_in *)[data bytes];
    return [NSString stringWithFormat:@"%s", inet_ntoa(socketAddress->sin_addr)];
    //    retrun [NSString stringWithCString:(const char *)inet_ntoa(socketAddress->sin_addr)
    //                                  encoding:NSUTF8StringEncoding];
}

@end
