//
//  CKANSucker.m
//  CKANSucker
//
//  Created by Andrew Sage on 02/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "CKANSucker.h"

static const int kTimeoutInterval = 20; // 20 seconds


@implementation CKANSucker

- (void)startNetworkTraffic {
    
    /*
    static int _networkSessions = 0;
    
    if(_networkSessions == 0) {
        //[self.delegate connectionNetworkStarted];
        //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    _networkSessions++;
     */
}

- (void)stopNetworkTraffic {
    
    /*
    _networkSessions--;
    
    if(_networkSessions == 0) {
        //[self.delegate connectionNetworkEnded];
        //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
     */
}

- (void)downloadBackgroundWithBlock:(CKANDDataResultBlock)block {

    NSData *data = nil;
    NSError *error;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/%@/action/package_show?id=%@",
                           self.serverAPIBaseURL,
                           self.serverAPIVersion,
                           self.datasetPackageID];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:kTimeoutInterval];

    
    block(data, error);
    
    request.timeoutInterval = 240;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [self stopNetworkTraffic];
                               
                               if(error) {
                                   NSLog(@"Connection failed: %@", error.localizedDescription);
                                   block(data, error);
                               } else {
                                   NSLog(@"We sent to: %@", response.URL);
                                   
                                   NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                   NSInteger responseStatusCode = [httpResponse statusCode];
                                   
                                   NSLog(@"Response status code: %ld", (long)responseStatusCode);
                                   NSLog(@"%@", [NSHTTPURLResponse localizedStringForStatusCode:responseStatusCode]);
                                   switch (responseStatusCode) {
                                       case 200: {
                                           NSString* dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                           
                                           if(self.debugMode) {
                                               NSLog(@"Data received: %@", dataAsString);
                                           }
                                           
                                           [self processReceivedJSON:data
                                                          httpMethod:request.HTTPMethod];

                                           
                                           block(data, error);
                                       }
                                           break;
                                           
                                           
                                           
                                       case 500:
                                           NSLog(@"Internal Server error: response 500");
                                           break;
                                           
                                       default:
                                           NSLog(@"Connection did receive response: %@", response);
                                           
                                           break;
                                   }
                               }
                           }];

}


- (BOOL)processReceivedJSON:(id)jsonData httpMethod:(NSString *)httpMethod {
    
    if(self.debugMode) {
        NSLog(@"Responding to a %@ request", httpMethod);
    }
    
    NSError *jsonError;
    NSArray *jsonArray = nil;
    NSDictionary *jsonDictionary = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
    
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        jsonArray = (NSArray *)jsonObject;
    }
    else {
        jsonDictionary = (NSDictionary *)jsonObject;
    }
    
    NSLog(@"array of data: %@", jsonArray);
    NSLog(@"data: %@", jsonDictionary);
    
    NSDictionary *errorDictionary = [jsonDictionary objectForKey:@"error"];
    if(errorDictionary) {
        NSLog(@"Error: %@", errorDictionary);
        //[self.delegate connectionJSONParseError:[errorDictionary objectForKey:@"message"]];
        return NO;
        
    } else {
    
        NSDictionary *resultDictionary = [jsonDictionary objectForKey:@"result"];
        if(resultDictionary) {
            self.dataVersion = [resultDictionary objectForKey:@"version"];
            for(NSDictionary *resourcesDictionary in [resultDictionary objectForKey:@"resources"]) {
                
                if(resourcesDictionary) {
                    self.datasourceURL = [resourcesDictionary objectForKey:@"url"];
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSS"];
                    NSString *revisionTimestamp = [resourcesDictionary valueForKey:@"revision_timestamp"];
                    self.revisonModifiedAt = [dateFormatter dateFromString:revisionTimestamp];
                    
                    return YES;
                } else {
                    return NO;
                }
            }
            
        } else {
            return NO;
        }
    }
    
    return NO;
}

@end
