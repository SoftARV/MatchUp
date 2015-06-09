//
//  ChatViewController.h
//  MatchedUp
//
//  Created by Miguel Rincon on 2/16/15.
//  Copyright (c) 2015 Miguel Rincon. All rights reserved.
//

#import "JSMessagesViewController.h"
#import <Parse/Parse.h>

@interface ChatViewController : JSMessagesViewController 

@property (strong, nonatomic) PFObject *chatRoom;

@end
