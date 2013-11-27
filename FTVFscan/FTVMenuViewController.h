//
//  FTVMenuViewController.h
//  FTVFscan
//
//  Created by Sarkar Raj on 11/19/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTVCustomNavigationController.h"

@interface FTVMenuViewController : FTVCustomNavigationController<UITableViewDelegate>
{
    IBOutlet UITableView *menuTableView;
    NSMutableArray *menuItems;
    NSMutableArray *menuItemsIcoons;
    NSMutableArray *menuItemViewId;
}

@end
