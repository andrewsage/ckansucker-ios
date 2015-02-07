//
//  ViewController.m
//  CKANSucker
//
//  Created by Andrew Sage on 02/10/2014.
//  Copyright (c) 2014 Xoverto. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    CKANSucker *_sucker;
    int _networkSessions;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _networkSessions = 0;
    
    _sucker = [[CKANSucker alloc] init];
    _sucker.serverAPIBaseURL = @"http://opendata.aberdeencity.gov.uk";
    _sucker.serverAPIVersion = @"3";
    _sucker.datasetPackageID = @"car-parks";
    _sucker.datasetPackageID = @"sports-classes";
    
    _sucker.serverAPIBaseURL = @"http://www.edinburghopendata.info";
    _sucker.datasetPackageID = @"sports-and-recreational-facilities";
    _sucker.datasetPackageID = @"community-learning-and-development";
    _sucker.datasetPackageID = @"edinburgh-stories-api-memories";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)connectTapped:(id)sender {
    //[_sucker download];
    
    [_sucker downloadBackgroundWithBlock:^(NSData* data, NSError *error) {
        
        if(error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSString* dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Data: %@", dataAsString);
            
            NSLog(@"downloaded successfully");
            NSLog(@"Data is at %@", _sucker.datasourceURL);
            NSLog(@"Modified at %@", _sucker.revisonModifiedAt);
            NSLog(@"Data version %@", _sucker.dataVersion);
        }
        
    }];
}



@end
