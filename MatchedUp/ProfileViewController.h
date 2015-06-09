//
//  ProfileViewController.h
//  MatchedUp
//
//  Created by Miguel Rincon on 2/14/15.
//  Copyright (c) 2015 Miguel Rincon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol ProfileViewControllerDelegate <NSObject>

- (void)didPressLike;
- (void)didPressDislike;

@end

@interface ProfileViewController : UIViewController

@property (weak, nonatomic) id <ProfileViewControllerDelegate> delegate;
@property (strong, nonatomic) PFObject *photo;

@end
