//
//  LoginViewController.m
//  MatchedUp
//
//  Created by Miguel Rincon on 2/11/15.
//  Copyright (c) 2015 Miguel Rincon. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Constants.h"

#define USER_PROFILE @"profile"
#define USER_ID @"id"
#define USER_NAME @"name"
#define USER_FIRST_NAME @"first_name"
#define USER_LOCATION @"location"
#define USER_GENDER @"gender"
#define USER_BIRTHDAY @"birthday"
#define USER_INTERESTED_IN @"interested_in"
#define USER_RELATIONSHIP_STATUS @"relationship_status"

#define SEGUE_TO_HOME @"LoginToHomeSegue"

@interface LoginViewController () <NSURLConnectionDataDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.activityIndicator.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self updateUserInformation];
        [self performSegueWithIdentifier:SEGUE_TO_HOME sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)loginButtonPressed:(UIButton *)sender {
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSArray *permissionsArray = @[@"user_about_me", @"user_interests", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        if (!user) {
            if (!error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log in error" message:@"The Facebook log in was cancel" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log in error" message:[error description] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alertView show];
            }
        }
        else {
            [self updateUserInformation];
            [self performSegueWithIdentifier:SEGUE_TO_HOME sender:self];
        }
    }];
}

#pragma mark - Helper methods

- (void)updateUserInformation {
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSDictionary *userDictionary = (NSDictionary *)result;
            
            //create URL
            NSString *facebookID = userDictionary[USER_ID];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
            
            if (userDictionary[USER_NAME]) {
                userProfile[kUserProfileNameKey] = userDictionary[USER_NAME];
            }
            if (userDictionary[USER_FIRST_NAME]) {
                userProfile[kUserProfileFirstNameKey] =userDictionary[USER_FIRST_NAME];
            }
            if (userDictionary[USER_LOCATION][USER_NAME]) {
                userProfile[kUserProfileLocationKey] = userDictionary[USER_LOCATION][USER_NAME];
            }
            if (userDictionary[USER_GENDER]) {
                userProfile[kUserProfileGenderKey] = userDictionary[USER_GENDER];
            }
            if (userDictionary[USER_BIRTHDAY]) {
                userProfile[kUserProfileBirthdayKey] = userDictionary[USER_BIRTHDAY];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate *date = [formatter dateFromString:userDictionary[USER_BIRTHDAY]];
                NSDate *now = [NSDate date];
                NSTimeInterval seconds = [now timeIntervalSinceDate:date];
                int age = seconds / 31536000;
                userProfile[KUserProfileAgeKey] = @(age);
            }
            if (userDictionary[USER_INTERESTED_IN]) {
                userProfile[kUserProfileInterestedInKey] = userDictionary[USER_INTERESTED_IN];
            }
            if (userDictionary[USER_RELATIONSHIP_STATUS]) {
                userProfile[KUserProfileRelationshipStatusKey] = userDictionary[USER_RELATIONSHIP_STATUS];
            }
            
            if ([pictureURL absoluteString]) {
                userProfile[KUserProfilePictureURLKey] = [pictureURL absoluteString];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:kUserProfileKey];
            [[PFUser currentUser] saveInBackground];
            [self requestImage];
        }
        else {
            NSLog(@"Error in FB request: %@", error);
        }
    }];
}

- (void)uploadPFFileToParse:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    if (!imageData) {
        NSLog(@"imageData was not found.");
        return;
    }
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFObject *photo = [PFObject objectWithClassName:kPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kPhotoUserKey];
            [photo setObject:photoFile forKey:kPhotoPictureKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Photo saved Successfully");
            }];
        }
    }];
}

-(void)requestImage {
    PFQuery *query = [PFQuery queryWithClassName:kPhotoClassKey];
    [query whereKey:kPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number == 0) {
            PFUser *user = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc] init];
            
            NSURL *profilePictureURL = [NSURL URLWithString:user[kUserProfileKey][KUserProfilePictureURLKey]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (!urlConnection) {
                NSLog(@"Failed to download picture");
            }
        }
    }];
}

#pragma mark - NSURLConnectionDataDelegate

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
}

@end
