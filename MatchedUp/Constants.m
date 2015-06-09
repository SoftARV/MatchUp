//
//  Constants.m
//  MatchedUp
//
//  Created by Miguel Rincon on 2/12/15.
//  Copyright (c) 2015 Miguel Rincon. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark - User class

NSString *const kUserTagLineKey = @"tagLine";

NSString *const kUserProfileKey = @"profile";
NSString *const kUserProfileNameKey = @"name";
NSString *const kUserProfileFirstNameKey = @"firstName";
NSString *const kUserProfileLocationKey = @"location";
NSString *const kUserProfileGenderKey = @"gender";
NSString *const kUserProfileBirthdayKey = @"birthday";
NSString *const kUserProfileInterestedInKey = @"interestedIn";
NSString *const KUserProfilePictureURLKey = @"pictureURL";
NSString *const KUserProfileRelationshipStatusKey = @"relationshipStatus";
NSString *const KUserProfileAgeKey = @"age";

#pragma mark - Photo class

NSString *const kPhotoClassKey = @"Photo";
NSString *const kPhotoUserKey = @"user";
NSString *const kPhotoPictureKey = @"image";

#pragma mark - Activity class

NSString *const kActivityClassKey = @"Activity";
NSString *const kActivityTypeKey = @"type";
NSString *const kActivityFromUserKey = @"fromUser";
NSString *const kActivityToUserKey = @"toUser";
NSString *const kActivityPhotoKey = @"photo";
NSString *const kActivityTypeLikeKey = @"like";
NSString *const kActivityTypeDislikeKey = @"dislike";

#pragma mark - Settings

NSString *const kMenEnabledKey = @"men";
NSString *const kWomenEnabledKey = @"women";
NSString *const kSingleEnabledKey = @"single";
NSString *const kAgeMaxKey = @"ageMax";

#pragma mark - Chatroom

NSString *const kChatroomClassKey = @"Chatroom";
NSString *const kChatroomUser1Key = @"user1";
NSString *const kChatroomUser2Key = @"user2";

#pragma mark - Chat

NSString *const kChatClassKey = @"Chat";
NSString *const kChatChatroomKey = @"chat";
NSString *const kChatFromUserKey = @"fromUser";
NSString *const kChatToUserKey = @"toUser";
NSString *const kChatTextKey = @"text";

@end
