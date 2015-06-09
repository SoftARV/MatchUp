//
//  ProfileViewController.m
//  MatchedUp
//
//  Created by Miguel Rincon on 2/14/15.
//  Copyright (c) 2015 Miguel Rincon. All rights reserved.
//

#import "ProfileViewController.h"
#import "Constants.h"

@interface ProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFFile *pictureFile = self.photo[kPhotoPictureKey];
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.profilePictureImageView.image = [UIImage imageWithData:data];
        }
        else NSLog(@"error in pictureFile getting the image data: %@", error);
    }];
    
    PFUser *user = self.photo[kPhotoUserKey];
    self.locationLabel.text = user[kUserProfileKey][kUserProfileLocationKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@",user[kUserProfileKey][KUserProfileAgeKey]];
    
    if (user[kUserProfileKey][KUserProfileRelationshipStatusKey] == nil) {
        self.statusLabel.text = @"Single";
    }
    else self.statusLabel.text = user[kUserProfileKey][KUserProfileRelationshipStatusKey];
    self.tagLineLabel.text = user[kUserTagLineKey];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    self.title = user[kUserProfileKey][kUserProfileFirstNameKey];
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

#pragma mark - IBActions methods

- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self.delegate didPressLike];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self.delegate didPressDislike];
}

@end
