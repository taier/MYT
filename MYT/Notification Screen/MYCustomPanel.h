//
//  MYCustomPanel.h
//  MYBlurIntroductionView-Example
//
//  Created by Matthew York on 10/17/13.
//  Copyright (c) 2013 Matthew York. All rights reserved.
//

#import "MYIntroductionPanel.h"

@protocol MYCustomPanelDelegate <NSObject>

- (void)didFinishTutorial;

@end

@import MapKit;

@interface MYCustomPanel : MYIntroductionPanel <UITextViewDelegate,CLLocationManagerDelegate> {
    
    __weak IBOutlet UIView *CongratulationsView;
}

@property (strong, nonatomic) IBOutlet UILabel *labelCongratulations;
@property id<MYCustomPanelDelegate> delegate;

- (IBAction)didPressEnable:(id)sender;

@end
