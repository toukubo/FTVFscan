//
//  FTVMenuViewController.m
//  FTVFscan
//
//  Created by Sarkar Raj on 11/19/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "FTVMenuViewController.h"

#import "DDMenuController.h"

@interface FTVMenuViewController ()

@end

@implementation FTVMenuViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [menuTableView setSeparatorInset:UIEdgeInsetsZero];
    menuItems = [[NSMutableArray alloc] init];
    [menuItems addObject:@"TOUR"];
    [menuItems addObject:@"HISTORY"];
//    [menuItems addObject:@"CAMERA"];
    [menuItems addObject:@"GALLERY"];
    [menuItems addObject:@"BRANDS"];
    
    menuItemsIcoons = [[NSMutableArray alloc] init];
    [menuItemsIcoons addObject:@"drawer-tour-label.png"];
    [menuItemsIcoons addObject:@"drawer-history-label.png"];
//    [menuItemsIcoons addObject:@"camera-icon.png"];
    [menuItemsIcoons addObject:@"drawer-album-label.png"];
    [menuItemsIcoons addObject:@"drawer-brands-label.png"];
    
    menuItemViewId = [[NSMutableArray alloc] init];
    [menuItemViewId addObject:@"FTVTourViewController"];
    [menuItemViewId addObject:@"FTVScansViewController"];
//    [menuItemViewId addObject:@"FTVCameraViewController"];
    [menuItemViewId addObject:@"FTVGalleryViewController"];
    [menuItemViewId addObject:@"FTVBrandsViewController"];
    
    [super setBackNavigations:self];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)tour:(id)sender
{
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FTVCameraViewController"];
    [menuController setRootController:controller animated:YES];
}


#pragma -- Table View Delegates

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [menuItems count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSLog(@"In the table view");
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    static NSString *CellIdentifier = @"Cell";
    // Load the top-level objects from the custom cell XIB.
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"NarzissTextBold" size:16];
    cell.textLabel.text = [menuItems objectAtIndex:indexPath.row];

    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //Do some code here
    
    return cell;    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // cell height
	return 50;
}

// If the tableView Cell is selected
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Do some code here
    
    DDMenuController *menuController = (DDMenuController*)((FTVAppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:[menuItemViewId objectAtIndex:indexPath.row]];
    [menuController setRootController:controller animated:YES];
    [menuController showRootController:YES];
}

// For deleteing any row from the table
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Do some code here
    
}



@end
