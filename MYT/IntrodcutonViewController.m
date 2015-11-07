//
//  IntrodcutonViewController.m
//  MYT
//
//  Created by Denis Kaibagarov on 10/24/15.
//  Copyright © 2015 AwesomeCompany. All rights reserved.
//

#import "IntrodcutonViewController.h"
#import "ViewScreenCollectionCell.h"


@interface IntrodcutonViewController () < UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewMain;

@property bool didPresent;

@end

@implementation IntrodcutonViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
//    if([self needToShowTutorial]) {
//        return;
//    }
//    
//    [self moveToNextScreen];
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
     _didPresent = false;
    
//    if([self needToShowTutorial]) {
        [self initIntroduction];
//    } 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ViewScreenCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"cellView%li",indexPath.item + 1] forIndexPath:indexPath];
    
    return  cell;
}

#pragma mark Collection View Layout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionViewMain.frame.size;
}


- (void)initIntroduction {
    
//    // Register stuff
//    for (int i = 1; i < 5 ; i++) {
//        [self.collectionViewMain registerClass:[ViewScreenCollectionCell class] forCellWithReuseIdentifier:[NSString stringWithFormat:@"cellView%i",i]];
//    }
    
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


@end
