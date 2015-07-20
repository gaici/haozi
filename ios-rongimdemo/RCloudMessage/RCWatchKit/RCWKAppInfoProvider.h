//
//  RCWKAppInfoProvider.h
//  RCloudMessage
//
//  Created by litao on 15/5/11.
//  Copyright (c) 2015年 胡利武. All rights reserved.
//

#ifndef RCloudMessage_RCWKAppInfoProvider_h
#define RCloudMessage_RCWKAppInfoProvider_h

@protocol RCWKAppInfoProvider
- (NSString *)getAppName;
- (NSString *)getAppGroups;
- (NSArray *)getAllUserInfo;
- (NSArray *)getAllGroupInfo;
- (NSArray *)getAllFriends;
- (void)openParentApp;
- (BOOL)getNewMessageNotificationSound;
- (void)setNewMessageNotificationSound:(BOOL)on;
- (void)logout;
- (BOOL)getLoginStatus;
@end

#endif
