//
//  MYCustomPanel.m
//  MYBlurIntroductionView-Example
//
//  Created by Matthew York on 10/17/13.
//  Copyright (c) 2013 Matthew York. All rights reserved.
//

#import "MYCustomPanel.h"
#import "MYBlurIntroductionView.h"

@implementation MYCustomPanel {
    
    CLLocationManager *locationManager;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Interaction Methods
//Override them if you want them!

-(void)panelDidAppear {
    
}

-(void)panelDidDisappear{
    CongratulationsView.alpha = 0;
}

#pragma mark Outlets
- (IBAction)didPressFinishButton:(id)sender {
    [self.delegate didFinishTutorial];
}

- (IBAction)didPressEnable:(id)sender {
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if(status == kCLAuthorizationStatusNotDetermined) {
        return;
    }
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.labelCongratulations.text = @"Enjoy the App!";
    } else if (status == kCLAuthorizationStatusDenied) {
        self.labelCongratulations.text = @"Go to setting, and enable location to use this app";
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        CongratulationsView.alpha = 1;
    }];
    
}


@end
