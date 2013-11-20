//
//  SVLeftMenuViewController.m
//  SVIPad
//
//  Created by Tim Tretyak on 24.02.13.
//  Copyright (c) 2013 studiovoice. All rights reserved.
//

#import "SVLeftMenuViewController.h"
#import "SVUtilities.h"
#import "FTVAppDelegate.h"
#import "MSNavigationPaneViewController.h"
#import "SVWebViewController.h"


@interface SVLeftMenuViewController ()

@property (strong,nonatomic) NSMutableArray *catArray;
@property (strong,nonatomic) NSMutableArray *genArray;

@end

@implementation SVLeftMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Temp solution. Should be dynamic...
        self.catArray = [[NSMutableArray alloc] init];
        [self.catArray addObject:@"TOUR"];
        [self.catArray addObject:@"f.Scan"];
        [self.catArray addObject:@"CAMERA"];
        [self.catArray addObject:@"HISTORY"];
        [self.catArray addObject:@"GALLERY"];
        [self.catArray addObject:@"BRANDS"];
        
    }
    self.view.backgroundColor = [UIColor blackColor];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.tableView){
        self.tableView = [[UITableView alloc] init];
    }
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.bounces = NO;
    self.tableView.opaque = NO;
    self.tableView.separatorColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [SVUtilities navMenuBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.catArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    if(section == 0)
//        return @""; // HOME
//    else if(section == 1)
//        return @"カテゴリー"; //CATEGORY
//    else if(section == 2)
//        return @"ジャンル"; //Genre
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if(section == 0)
//        return 30;
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    sectionView.backgroundColor = [SVUtilities navMenuBackground];
    UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 230, 30)];
    sectionTitle.font = [UIFont boldSystemFontOfSize:20];
    sectionTitle.backgroundColor = [UIColor clearColor];
    [sectionView addSubview:sectionTitle];
    if(section == 1)
        sectionTitle.text = @"カテゴリー";
    else if(section == 2)
        sectionTitle.text = @"ジャンル";
    
    return sectionView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *titleLabel;
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [SVUtilities navMenuBackground];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 220, 45)];
        titleLabel.font = [UIFont systemFontOfSize:25];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.tag = 1000;
        titleLabel.textColor = [UIColor whiteColor];
        [cell addSubview:titleLabel];
    }
    else
        titleLabel = (UILabel *)[cell viewWithTag:1000];
    // Configure the cell...
//    if(indexPath.section == 1)
//        titleLabel.text = [[self.catArray objectAtIndex:indexPath.row] valueForKey:@"name"];
//    else if(indexPath.section == 2)
//        titleLabel.text = [[self.genArray objectAtIndex:indexPath.row] valueForKey:@"name"];
//    else // "HOME" item
        titleLabel.text = [self.catArray objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FTVAppDelegate *appDelegate = (FTVAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVTourViewController"];
//    if (indexPath.row == 0) {
//        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVTourViewController"];
//    }else if (indexPath.row == 1) {
//        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVTourViewController"];
//    }else if (indexPath.row == 2) {
//        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVCameraViewController"];
//    }else if (indexPath.row == 3) {
//        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVTourViewController"];
//    }else if (indexPath.row == 4) {
//        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVTourViewController"];
//    }else if (indexPath.row == 5) {
//        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVTourViewController"];
//    }
    
    [appDelegate switchSceneToTabController];
}

@end
