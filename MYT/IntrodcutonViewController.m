//
//  IntrodcutonViewController.m
//  MYT
//
//  Created by Denis Kaibagarov on 10/24/15.
//  Copyright © 2015 AwesomeCompany. All rights reserved.
//

#import "IntrodcutonViewController.h"
#import "ViewScreenCollectionCell.h"


@interface IntrodcutonViewController () < UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ViewScreenCollectionCellDeleagte,UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewMain;
@property (strong, nonatomic) IBOutlet UILabel *labelCount;

@end

@implementation IntrodcutonViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    if(![self needToShowTutorial]) {
        self.view.alpha = 0;
        [self moveToNextScreen];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
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
    cell.delegate = self;
    return  cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSIndexPath *centerCellIndexPath = [self.collectionViewMain indexPathForItemAtPoint: [self.view convertPoint:[self.view center] toView:self.collectionViewMain]];
    
    self.labelCount.text = [NSString stringWithFormat:@"Step: %i/4",(int)(centerCellIndexPath.item + 1)];
    
}

#pragma mark Collection View Layout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionViewMain.frame.size;
}

- (BOOL)needToShowTutorial {
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = @"FINISH_TUTORIAL";
    bool needToShowTutorial = [defaults valueForKey:key];
    return !needToShowTutorial;
}

- (void)moveToNextScreen {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = @"FINISH_TUTORIAL";
    [defaults setBool:true forKey:key];
    [defaults synchronize];
    
    [self performSegueWithIdentifier:@"MAIN_SCREEN_SEGUE" sender:NULL];
}

#pragma mark Cell Delegate

- (void)finishTutorial {
    [self moveToNextScreen];
}


@end
