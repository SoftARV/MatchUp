//
//  MatchesViewController.m
//  MatchedUp
//
//  Created by Miguel Rincon on 2/15/15.
//  Copyright (c) 2015 Miguel Rincon. All rights reserved.
//

#import "MatchesViewController.h"
#import <Parse/Parse.h>
#import "ChatViewController.h"
#import "Constants.h"

#define SEGUE_TO_CHAT @"MatchesToChatSegue"

@interface MatchesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *availableChatRooms;

@end

@implementation MatchesViewController

- (NSMutableArray *)availableChatRooms {
    if (!_availableChatRooms){
        _availableChatRooms = [[NSMutableArray alloc] init];
    }
    return _availableChatRooms;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self updateAvaliableChatRooms];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_TO_CHAT]) {
        ChatViewController *targetVC = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        targetVC.chatRoom = self.availableChatRooms[indexPath.row];
    }
}


#pragma mark - UITableViewControllerDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.availableChatRooms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *chatRoom = self.availableChatRooms[indexPath.row];
    
    PFUser *likedUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser1 = chatRoom[kChatroomUser1Key];
    if ([testUser1.objectId isEqual:currentUser.objectId]) {
        likedUser = [chatRoom objectForKey:kChatroomUser2Key];
    }
    else {
        likedUser = [chatRoom objectForKey:kChatroomUser1Key];
    }
    
    //Configure cell...
    
    cell.textLabel.text = likedUser[kUserProfileKey][kUserProfileFirstNameKey];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    PFQuery *queryForPhoto = [[PFQuery alloc] initWithClassName:kPhotoClassKey];
    [queryForPhoto whereKey:kPhotoUserKey equalTo:likedUser];
    [queryForPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    cell.imageView.image = [UIImage imageWithData:data];
                    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                }
            }];
        }
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:SEGUE_TO_CHAT sender:indexPath];
    
}

#pragma mark - Helper methods

- (void)updateAvaliableChatRooms {
    PFQuery *query = [PFQuery queryWithClassName:kChatroomClassKey];
    [query whereKey:kChatroomUser1Key equalTo:[PFUser currentUser]];
    PFQuery *queryInverse = [PFQuery queryWithClassName:kChatroomClassKey];
    [query whereKey:kChatroomUser2Key equalTo:[PFUser currentUser]];
    
    PFQuery *queryCombined = [PFQuery orQueryWithSubqueries:@[query, queryInverse]];
    [queryCombined includeKey:kChatChatroomKey];
    [queryCombined includeKey:kChatroomUser1Key];
    [queryCombined includeKey:kChatroomUser2Key];
    [queryCombined findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.availableChatRooms removeAllObjects];
            self.availableChatRooms = [objects mutableCopy];
            [self.tableView reloadData];
        }
        else NSLog(@"error getting the available chats: %@", error);
    }];
     
}

@end
