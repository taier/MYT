//
//  ViewScreenCollectionCell.h
//  MYT
//
//  Created by Denis Kaibagarov on 10/31/15.
//  Copyright (c) 2015 AwesomeCompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewScreenCollectionCellDeleagte <NSObject>

- (void)finishTutorial;

@end

@interface ViewScreenCollectionCell : UICollectionViewCell

@property id<ViewScreenCollectionCellDeleagte> delegate;

@end
