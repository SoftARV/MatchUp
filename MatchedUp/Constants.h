//
//  Constants.h
//  MatchedUp
//
//  Created by Miguel Rincon on 2/12/15.
//  Copyright (c) 2015 Miguel Rincon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#pragma mark - User class

extern NSString *const kUserTagLineKey;

extern NSString *const kUserProfileKey;
extern NSString *const kUserProfileNameKey;
extern NSString *const kUserProfileFirstNameKey;
extern NSString *const kUserProfileLocationKey;
extern NSString *const kUserProfileGenderKey;
extern NSString *const kUserProfileBirthdayKey;
extern NSString *const kUserProfileInterestedInKey;
extern NSString *const KUserProfilePictureURLKey;
extern NSString *const KUserProfileRelationshipStatusKey;
extern NSString *const KUserProfileAgeKey;

#pragma mark - Photo class

extern NSString *const kPhotoClassKey;
extern NSString *const kPhotoUserKey;
extern NSString *const kPhotoPictureKey;

#pragma mark - Activity class

extern NSString *const kActivityClassKey;
extern NSString *const kActivityTypeKey;
extern NSString *const kActivityFromUserKey;
extern NSString *const kActivityToUserKey;
extern NSString *const kActivityPhotoKey;
extern NSString *const kActivityTypeLikeKey;
extern NSString *const kActivityTypeDislikeKey;

#pragma mark - Settings

extern NSString *const kMenEnabledKey;
extern NSString *const kWomenEnabledKey;
extern NSString *const kSingleEnabledKey;
extern NSString *const kAgeMaxKey;

#pragma mark - Chatroom

extern NSString *const kChatroomClassKey;
extern NSString *const kChatroomUser1Key;
extern NSString *const kChatroomUser2Key;

#pragma mark - Chat

extern NSString *const kChatClassKey;
extern NSString *const kChatChatroomKey;
extern NSString *const kChatFromUserKey;
extern NSString *const kChatToUserKey;
extern NSString *const kChatTextKey;

@end
