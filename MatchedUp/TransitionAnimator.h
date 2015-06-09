//
//  TransitionAnimator.h
//  MatchedUp
//
//  Created by Miguel Rincon on 2/18/15.
//  Copyright (c) 2015 Miguel Rincon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;

@end
