//
//  MatchViewController.h
//  MatchedUp
//
//  Created by Miguel Rincon on 2/15/15.
//  Copyright (c) 2015 Miguel Rincon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MatchViewControllerDelegate <NSObject>

- (void)presentMatchesViewController;

@end

@interface MatchViewController : UIViewController

@property (weak, nonatomic) id <MatchViewControllerDelegate> delegate;

@property (strong, nonatomic) UIImage *matchedUserImage;

@end
