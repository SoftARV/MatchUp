//
//  HomeViewController.m
//  MatchedUp
//
//  Created by Miguel Rincon on 2/13/15.
//  Copyright (c) 2015 Miguel Rincon. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "TestUser.h"
#import "ProfileViewController.h"
#import "MatchViewController.h"
#import "TransitionAnimator.h"
#import <Mixpanel.h>

#define SEGUE_TO_PROFILE @"HomeToProfileSegue"
#define SEGUE_TO_MATCH @"HomeToMatchSegue"
#define SEGUE_TO_MATCHES @"HomeToMatchesSegue"

@interface HomeViewController () <MatchViewControllerDelegate, ProfileViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;
@property (strong, nonatomic) IBOutlet UIView *labelContainerView;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.firstNameLabel.text = nil;
    self.ageLabel.text = nil;
    
    [self setupViews];
    
    //[TestUser saveTestUserToParse];
}

- (void)viewDidAppear:(BOOL)animated {
    self.photoImageView.image = [UIImage imageNamed:@"UserImage.png"];
    self.firstNameLabel.text = nil;
    self.ageLabel.text = nil;
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kPhotoClassKey];
    [query whereKey:kPhotoUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kPhotoUserKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photos = objects;
            if ([self allowPhoto] == NO) {
                [self setupNextPhoto];
            }
            else [self queryForCurrentPhotoIndex];
        }
        else NSLog(@"error in viewDidAppear findObjectsInBackgroundWith Block: %@", error);
    }];
}

- (void)setupViews {
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self addShadowForView:self.labelContainerView];
    [self addShadowForView:self.buttonContainerView];
    self.photoImageView.layer.masksToBounds = YES;
}

- (void)addShadowForView:(UIView *)view {
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 4;
    view.layer.shadowRadius = 1;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 0.25;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_TO_PROFILE]) {
        ProfileViewController *targetVC = segue.destinationViewController;
        targetVC.photo = self.photo;
        targetVC.delegate = self;
    }
}

#pragma mark - IBActions

- (IBAction)likeButttonPressed:(UIButton *)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Like"];
    [mixpanel flush];
    
    [self checkLike];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Dislike"];
    [mixpanel flush];
    
    [self checkDislike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:SEGUE_TO_PROFILE sender:nil];
    
}

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:SEGUE_TO_MATCHES sender:nil];
}

- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender {
}

#pragma mark - MatchViewControllerDelegate

- (void)presentMatchesViewController {
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:SEGUE_TO_MATCHES sender:nil];
    }];
}

#pragma mark - ProfileViewControllerDelegate

- (void)didPressLike {
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self checkLike];
}

- (void)didPressDislike {
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self checkDislike];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    TransitionAnimator *animator = [[TransitionAnimator alloc] init];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    TransitionAnimator *animator = [[TransitionAnimator alloc] init];
    return animator;
}

#pragma mark - Helper methods

- (void)queryForCurrentPhotoIndex {
    if ([self.photos count] > 0) {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[kPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
                [self updateView];
            }
            else NSLog(@"Error in queryForCurrentPhotoIndex: %@", error);
        }];
        
        PFQuery *queryForLike = [PFQuery queryWithClassName:kActivityClassKey];
        [queryForLike whereKey:kActivityTypeKey equalTo:kActivityTypeLikeKey];
        [queryForLike whereKey:kActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDislike = [PFQuery queryWithClassName:kActivityClassKey];
        [queryForDislike whereKey:kActivityTypeKey equalTo:kActivityTypeDislikeKey];
        [queryForDislike whereKey:kActivityPhotoKey equalTo:self.photo];
        [queryForDislike whereKey:kActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.activities = [objects mutableCopy];
                
                if ([self.activities count] == 0) {
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedByCurrentUser = NO;
                }
                else {
                    PFObject *activity = self.activities[0];
                    
                    if ([activity[kActivityTypeKey] isEqualToString:kActivityTypeLikeKey]) {
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedByCurrentUser = NO;
                    }
                    else if ([activity[kActivityTypeKey] isEqualToString:kActivityTypeDislikeKey]) {
                        self.isLikedByCurrentUser = NO;
                        self.isDislikedByCurrentUser = YES;
                    }
                    else {
                        //Some other type of activity
                    }
                }
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
                self.infoButton.enabled = YES;
            }
            else NSLog(@"Error in query for likes and dislike saved: %@", error);
        }];
    }
}

- (void)updateView {
    self.firstNameLabel.text = self.photo[kPhotoUserKey][kUserProfileKey][kUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kPhotoUserKey][kUserProfileKey][KUserProfileAgeKey]];
}

- (void)setupNextPhoto {
    if (self.currentPhotoIndex + 1 < self.photos.count) {
        self.currentPhotoIndex ++;
        if ([self allowPhoto] == NO) {
            [self setupNextPhoto];
        }
        else [self queryForCurrentPhotoIndex];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No more users to view" message:@"Check back later for more people" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)allowPhoto {
    int maxAge = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kAgeMaxKey];
    BOOL men = [[NSUserDefaults standardUserDefaults] boolForKey:kMenEnabledKey];
    BOOL women = [[NSUserDefaults standardUserDefaults] boolForKey:kWomenEnabledKey];
    BOOL single = [[NSUserDefaults standardUserDefaults] boolForKey:kSingleEnabledKey];
    
    PFObject *photo = self.photos[self.currentPhotoIndex];
    PFUser *user = photo[kPhotoUserKey];
    
    int userAge = [user[kUserProfileKey][KUserProfileAgeKey] intValue];
    NSString *userGender = user[kUserProfileKey][kUserProfileGenderKey];
    NSString *relationshipStatus = user[kUserProfileKey][KUserProfileRelationshipStatusKey];
    
    if (maxAge < userAge) {
        return NO;
    }
    else if (men == NO && [userGender isEqualToString:@"male"]) {
        return NO;
    }
    else if (women == NO && [userGender isEqualToString:@"female"]) {
        return NO;
    }
    else if (single == NO && ([relationshipStatus isEqualToString:@"single"] || relationshipStatus == nil)) {
        return NO;
    }
    else return YES;
}

- (void)saveLike {
    PFObject *likeActivity = [PFObject objectWithClassName:kActivityClassKey];
    [likeActivity setObject:kActivityTypeLikeKey forKey:kActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:kActivityFromUserKey];
    [likeActivity setObject:[self.photo objectForKey:kPhotoUserKey] forKey:kActivityToUserKey];
    [likeActivity setObject:self.photo forKey:kActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self checkForPhotoUserLikes];
        [self setupNextPhoto];
    }];
}

- (void)saveDislike {
    PFObject *dislikeActivity = [PFObject objectWithClassName:kActivityClassKey];
    [dislikeActivity setObject:kActivityTypeDislikeKey forKey:kActivityTypeKey];
    [dislikeActivity setObject:[PFUser currentUser] forKey:kActivityFromUserKey];
    [dislikeActivity setObject:[self.photo objectForKey:kPhotoUserKey] forKey:kActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:kActivityPhotoKey];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setupNextPhoto];
    }];
}

- (void)checkLike {
    if (self.isLikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isDislikedByCurrentUser) {
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    }
    else {
        [self saveLike];
    }
}

- (void)checkDislike {
    if (self.isDislikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isLikedByCurrentUser) {
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    }
    else {
        [self saveDislike];
    }
}

- (void)checkForPhotoUserLikes {
    PFQuery *query = [PFQuery queryWithClassName:kActivityClassKey];
    [query whereKey:kActivityFromUserKey equalTo:self.photo[kPhotoUserKey]];
    [query whereKey:kActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kActivityTypeKey equalTo:kActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([objects count] > 0) {
                [self createChatRoom];
            }
        }
    }];
}

- (void)createChatRoom {
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:kChatroomClassKey];
    [queryForChatRoom whereKey:kChatroomUser1Key equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:kChatroomUser2Key equalTo:self.photo[kPhotoUserKey]];
    
    PFQuery *queryForChatInverse = [PFQuery queryWithClassName:kChatroomClassKey];
    [queryForChatInverse whereKey:kChatroomUser2Key equalTo:[PFUser currentUser]];
    [queryForChatInverse whereKey:kChatroomUser1Key equalTo:self.photo[kPhotoUserKey]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatInverse]];
    
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([objects count] == 0) {
                PFObject *chatroom = [PFObject objectWithClassName:kChatroomClassKey];
                [chatroom setObject:[PFUser currentUser] forKey:kChatroomUser1Key];
                [chatroom setObject:self.photo[kPhotoUserKey] forKey:kChatroomUser2Key];
                [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        UIStoryboard *myStoryboard = self.storyboard;
                        MatchViewController *matchViewController = [myStoryboard instantiateViewControllerWithIdentifier:@"matchVC"];
                        matchViewController.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.75];
                        matchViewController.transitioningDelegate = self;
                        matchViewController.matchedUserImage = self.photoImageView.image;
                        matchViewController.delegate = self;
                        matchViewController.modalPresentationStyle = UIModalPresentationCustom;
                        [self presentViewController:matchViewController animated:YES completion:nil];
                    }
                }];
            }
        }
    }];
}

@end
