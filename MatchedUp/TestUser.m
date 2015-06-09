//
//  TestUser.m
//  MatchedUp
//
//  Created by Miguel Rincon on 2/15/15.
//  Copyright (c) 2015 Miguel Rincon. All rights reserved.
//

#import "TestUser.h"
#import <Parse/Parse.h>
#import "Constants.h"

@implementation TestUser

+ (void)saveTestUserToParse {
    PFUser *newUser = [PFUser user];
    newUser.username = @"user1";
    newUser.password = @"password1";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSDictionary *profile = @{KUserProfileAgeKey : @28, kUserProfileBirthdayKey : @"11/22/1985", kUserProfileFirstNameKey : @"Nec", kUserProfileGenderKey : @"male", kUserProfileLocationKey : @"Berlin, Germany", kUserProfileNameKey : @"Nec Arkwright"};
            [newUser setObject:profile forKey:kUserProfileKey];
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    UIImage *profileImage = [UIImage imageNamed:@"TestUserPhoto.jpg"];
                    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                    PFFile *photoFile = [PFFile fileWithData:imageData];
                    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            PFObject *photo = [PFObject objectWithClassName:kPhotoClassKey];
                            [photo setObject:newUser forKey:kPhotoUserKey];
                            [photo setObject:photoFile forKey:kPhotoPictureKey];
                            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    NSLog(@"photo saved successfully");
                                }
                                else NSLog(@"error in photo: %@", error);
                            }];
                        }
                        else NSLog(@"Error in photoFile: %@", error);
                    }];
                }
                else NSLog(@"error in newUser save: %@", error);
            }];
        }
        else NSLog(@"error in newUser signUp: %@",error);
    }];
}

@end
