//
//  ViewScreenCollectionCell.m
//  MYT
//
//  Created by Denis Kaibagarov on 10/31/15.
//  Copyright (c) 2015 AwesomeCompany. All rights reserved.
//


@import MapKit;
#import "ViewScreenCollectionCell.h"

@interface ViewScreenCollectionCell () <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *labelFinishText;
@property (strong, nonatomic) IBOutlet UIButton *buttonStartUsingApp;

@end

@implementation ViewScreenCollectionCell {
    
     CLLocationManager *locationManager;
}

- (void)awakeFromNib {
    // Initialization code
}
- (IBAction)onAllowLocationButtonPress:(id)sender {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];

}
- (IBAction)onBeginUisngAppButtonPress:(id)sender {
    [self.delegate finishTutorial];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if(status == kCLAuthorizationStatusNotDetermined) {
        return;
    }
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.labelFinishText.text = @"Enjoy the App!";
    } else if (status == kCLAuthorizationStatusDenied) {
        self.labelFinishText.text = @"Go to setting, and enable location to use this app";
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.labelFinishText.alpha = 1;
        self.buttonStartUsingApp.alpha = 1;
    }];
}


@end
