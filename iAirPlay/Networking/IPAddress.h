//
//  IPAddress.h
//  iAirPlay
//
//  Created by zfkun on 13-8-6.
//  Copyright (c) 2013年 zfkun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPAddress : NSObject

// get local ip for `interfaceName`, etc: `en0`(LAN), `en1`(WIFI)
+ (NSString *)localIPAddressWithName:(NSString *)interfaceName;

// get local ip for `en1`
+ (NSString *)localIPAddress;

// get ip for address's nsdata
+ (NSString *)ipAddressWithData:(NSData *)data;

@end
