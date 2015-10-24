//
//  IntrodcutonViewController.m
//  MYT
//
//  Created by Denis Kaibagarov on 10/24/15.
//  Copyright © 2015 AwesomeCompany. All rights reserved.
//

#import "IntrodcutonViewController.h"
#import "MYBlurIntroductionView.h"
#import "MYCustomPanel.h"


@interface IntrodcutonViewController () <MYIntroductionDelegate, MYCustomPanelDelegate>

@property bool didPresent;

@end

@implementation IntrodcutonViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    if([self needToShowTutorial]) {
        return;
    }
    
    [self moveToNextScreen];
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
     _didPresent = false;
    
    if([self needToShowTutorial]) {
        [self initIntroduction];
    } 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initIntroduction {
    
    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:self.view.frame title:@"Hello" description:@"Asesome App 1"];
    
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:self.view.frame title:@"Hello" description:@"Asesome App 2"];
    
    MYCustomPanel *panel3 = [[MYCustomPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"MYCustomPanel"];
    
    panel3.delegate = self;
    
    //Create the introduction view and set its delegate
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    introductionView.delegate = self;
    introductionView.BackgroundImageView.image = [UIImage imageNamed:@"Toronto.jpg"];
    
    //Add panels to an array
    NSArray *panels = @[panel1, panel2, panel3];
    
    //Build the introduction with desired panels
    [introductionView buildIntroductionWithPanels:panels];
    
    [self.view addSubview:introductionView];
}

- (BOOL)needToShowTutorial {
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = @"FINISH_TUTORIAL";
    bool needToShowTutorial = [defaults valueForKey:key];
    return !needToShowTutorial;
}

- (void)moveToNextScreen {
    
    if(_didPresent)
        return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = @"FINISH_TUTORIAL";
    [defaults setBool:true forKey:key];
    [defaults synchronize];
    
    [self performSegueWithIdentifier:@"MAIN_SCREEN_SEGUE" sender:NULL];
    _didPresent = true;
}

// Introduction Screen delegate

- (void)didFinishTutorial{
    [self moveToNextScreen];
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    [self moveToNextScreen];
}

@end
