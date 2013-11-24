//
//  FTVGalleryViewController.h
//  FTVFscan
//
//  Created by Tim Tretyak on 27.09.13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FTVCustomNavigationController.h"


@interface FTVGalleryViewController : FTVCustomNavigationController <UICollectionViewDataSource, UICollectionViewDelegate, UIBarPositioningDelegate>

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

-(IBAction)OpenMenu:(id)sender;
@end
