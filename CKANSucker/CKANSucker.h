//
//  CKANSucker.h
//  CKANSucker
//
//  Created by Andrew Sage on 02/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKANSucker;

typedef void (^CKANBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^CKANDDataResultBlock)(NSData *data, NSError *error);

@interface CKANSucker : NSObject

@property (strong, nonatomic) NSString *serverAPIBaseURL;
@property (strong, nonatomic) NSString *serverAPIVersion;
@property (strong, nonatomic) NSString *datasetPackageID;
@property (nonatomic, copy) NSDate *revisonModifiedAt;
@property (strong, nonatomic) NSString *dataVersion;



@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, strong) NSString *datasourceURL;


- (void)downloadBackgroundWithBlock:(CKANDDataResultBlock)block;

@end
