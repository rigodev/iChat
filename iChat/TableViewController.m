//
//  TableViewController.m
//  iChat
//
//  Created by rigo on 03/04/2019.
//  Copyright © 2019 shuvalov. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftNavBarItem;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setupTitleViewForNavigationBar];
}

- (void)setupTitleViewForNavigationBar
{
    UIView *titleView = [UIView new];
    
    UIImageView *profileImageView = [UIImageView new];
    [titleView addSubview:profileImageView];
    profileImageView.translatesAutoresizingMaskIntoConstraints = false;
    [profileImageView.leftAnchor constraintEqualToAnchor:titleView.leftAnchor].active = true;
    [profileImageView.topAnchor constraintEqualToAnchor:titleView.topAnchor];
    [profileImageView.heightAnchor constraintEqualToAnchor:titleView.heightAnchor].active = true;
    [profileImageView.widthAnchor constraintEqualToAnchor:titleView.heightAnchor].active = true;
    
    profileImageView.layer.cornerRadius = 20;
    profileImageView.clipsToBounds = true;
    profileImageView.image = [UIImage imageNamed:@"clouds"];
    profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UILabel *nameLabel = [UILabel new];
    [titleView addSubview:nameLabel];
    nameLabel.translatesAutoresizingMaskIntoConstraints = false;
    [nameLabel.leftAnchor constraintEqualToAnchor:profileImageView.rightAnchor constant:5].active = true;
    [nameLabel.rightAnchor constraintEqualToAnchor:titleView.rightAnchor].active = true;
    [nameLabel.heightAnchor constraintEqualToAnchor:profileImageView.heightAnchor].active = true;
    [nameLabel.centerYAnchor constraintEqualToAnchor:profileImageView.centerYAnchor].active = true;
    nameLabel.text = @"Hello world and others sdfsdf s";
    nameLabel.textColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = titleView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
