#import "WannatalkCore.h"
#import <WTExternalSDK/WTExternalSDK.h>
#import <React/RCTLog.h>
#import <React/RCTConvert.h>

@interface WannatalkCore() <WTLoginManagerDelegate, WTSDKManagerDelegate> {
    BOOL _hasListeners;
}

@property (nonatomic, strong) RCTResponseSenderBlock loginSenderBlock;
@property (nonatomic, strong) RCTResponseSenderBlock logoutSenderBlock;

@property (nonatomic, strong) RCTResponseSenderBlock orgProfileSenderBlock;
@property (nonatomic, strong) RCTResponseSenderBlock chatListSenderBlock;
@property (nonatomic, strong) RCTResponseSenderBlock userListSenderBlock;

@end

@implementation WannatalkCore



- (instancetype) init {
    self = [super init];
    if (self) {
        [[WTSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:nil];
        [WTLoginManager sharedInstance].delegate = self;
        [WTSDKManager sharedInstance].delegate = self;
    }
    return self;
}


#define EVENT_LOGIN @"login-event"
#define EVENT_ERROR @"error-event"
#define EVENT_WANNATALK @"wannatalk-event"

//#define EVENT_ORG_PROFILE @"org-event"
//#define EVENT_CHAT_LIST @"chat-list-event"
//#define EVENT_USERS_LIST @"user-list-event"

typedef NS_ENUM(NSInteger, WTEventTypes)
{
    kEventTypeLogin = 1011,
    kEventTypeSilentLogin,
    kEventTypeLogout,
    kEventTypeOrgProfile,
    kEventTypeChatList,
    kEventTypeUsers
};


- (NSArray<NSString *> *)supportedEvents
{
    return @[
        EVENT_ERROR,
        EVENT_LOGIN,
//        EVENT_WANNATALK,
//        EVENT_ORG_PROFILE,
//        EVENT_CHAT_LIST,
//        EVENT_USERS_LIST
    ];
}

//- (NSDictionary *)constantsToExport
//{
//    return @{
//        @"kEVENT_ERROR": EVENT_ERROR,
//        @"kEVENT_LOGIN": EVENT_LOGIN,
//        //        @"kEVENT_WANNATALK": EVENT_WANNATALK,
////        @"kEVENT_ORG_PROFILE": EVENT_ORG_PROFILE,
////        @"kEVENT_CHAT_LIST": EVENT_CHAT_LIST,
////        @"kEVENT_USERS_LIST": EVENT_USERS_LIST
//
//        //        @"kEventTypeLogin": @(kEventTypeLogin),
//        //        @"kEventTypeSilentLogin": @(kEventTypeSilentLogin),
//        //        @"kEventTypeLogout": @(kEventTypeLogout),
//        //        @"kEventTypeOrgProfile": @(kEventTypeOrgProfile),
//        //        @"kEventTypeChatList": @(kEventTypeChatList),
//        //        @"kEventTypeUsers": @(kEventTypeUsers)
//    };
//
//
//}

// Will be called when this module's first listener is added.
- (void)startObserving
{
    _hasListeners = YES;
}

// Will be called when this module's last listener is removed, or on dealloc.
- (void)stopObserving
{
    _hasListeners = NO;
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


#pragma mark -

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(isUserLoggedIn:(RCTResponseSenderBlock)callback) {
    
    callback(@[@([WTLoginManager sharedInstance].isUserLoggedIn)]);
}

RCT_EXPORT_METHOD(logout:(RCTResponseSenderBlock)callback) {
    self.logoutSenderBlock = callback;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            @try {
                
                [[WTLoginManager sharedInstance] logout];
                
            } @catch (NSException *e) {
                [self sendLogoutCallback:@"Error occured"];
                NSLog(@"Error: %@", [e description]);
                [self sendErrorEvent:kEventTypeLogout withMessage:[e description]];
                
            }
        });
        
    });

    
}

RCT_EXPORT_METHOD(silentLogin:(NSString *) identifier userInfo:(NSDictionary *) userInfo callback:(RCTResponseSenderBlock)callback) {
    self.loginSenderBlock = callback;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // Get view controller on which to present the flow
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIViewController *_rootViewController = (UIViewController *)window.rootViewController;
            
            @try {
                
                [[WTLoginManager sharedInstance] silentLoginWithIdentifier:identifier userInfo:userInfo fromVC:_rootViewController];
                
            } @catch (NSException *e) {
                [self sendLoginCallback:@"Error occured"];
                NSLog(@"Error: %@", [e description]);
                [self sendErrorEvent:kEventTypeSilentLogin withMessage:[e description]];
            }
        });
    });
    
    
    
    
}


RCT_EXPORT_METHOD(login:(RCTResponseSenderBlock)callback) {

    self.loginSenderBlock = callback;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Get view controller on which to present the flow
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIViewController *_rootViewController = (UIViewController *)window.rootViewController;
            
            @try {
                
                
                [[WTLoginManager sharedInstance] loginFromVC:_rootViewController];
                
                
            } @catch (NSException *e) {
                [self sendLoginCallback:@"Error occured"];
                NSLog(@"Error: %@", [e description]);
                [self sendErrorEvent:kEventTypeLogin withMessage:[e description]];
                
            }
        });
    });
    

}

RCT_EXPORT_METHOD(loadOrganizationProfile:(BOOL) autoOpenChat callback:(RCTResponseSenderBlock)callback) {
    
    self.orgProfileSenderBlock = callback;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Get view controller on which to present the flow
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIViewController *_rootViewController = (UIViewController *)window.rootViewController;
            
            @try {
                
                [_rootViewController presentOrgProfileVCWithAutoOpenChat:autoOpenChat delegate:self animated:YES completion:^{
                    
                    
                }];
                
            } @catch (NSException *e) {
                if (self.orgProfileSenderBlock) {
                    NSLog(@"Error: %@", [e description]);
                    self.orgProfileSenderBlock(@[@(NO), @"Error occurred"]);
                }
                self.orgProfileSenderBlock = nil;
                [self sendErrorEvent:kEventTypeOrgProfile withMessage:[e description]];
            }
        });
    });
    
    
}

RCT_EXPORT_METHOD(loadChatList:(RCTResponseSenderBlock)callback) {
    
    self.chatListSenderBlock = callback;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Get view controller on which to present the flow
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIViewController *_rootViewController = (UIViewController *)window.rootViewController;
            
            @try {
                
                [_rootViewController presentChatListVCWithDelegate:self animated:YES completion:^{
                    
                    
                }];
                
            } @catch (NSException *e) {
                if (self.chatListSenderBlock) {
                    NSLog(@"Error: %@", [e description]);
                    self.chatListSenderBlock(@[@(NO), @"Error occurred"]);
                }
                self.chatListSenderBlock = nil;
                [self sendErrorEvent:kEventTypeChatList withMessage:[e description]];
                
            }
        });
    });
    
}

RCT_EXPORT_METHOD(loadUsers:(RCTResponseSenderBlock)callback) {
    self.userListSenderBlock = callback;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Get view controller on which to present the flow
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIViewController *_rootViewController = (UIViewController *)window.rootViewController;
            
            @try {
                
                [_rootViewController presentUsersVCWithDelegate:self animated:YES completion:^{
                    
                    
                }];
                
                
            } @catch (NSException *e) {
                if (self.userListSenderBlock) {
                    NSLog(@"Error: %@", [e description]);
                    self.userListSenderBlock(@[@(NO), @"Error occurred"]);
                }
                self.userListSenderBlock = nil;
                [self sendErrorEvent:kEventTypeUsers withMessage:[e description]];
                
            }
        });
    });
    
}

#pragma mark -


RCT_EXPORT_METHOD(ClearTempFiles) {
    [WTSDKManager ClearTempDirectory];
}

// To show or hide guide button
RCT_EXPORT_METHOD(ShowGuideButton:(BOOL) show)               // default = YES
{
    [WTSDKManager ShowGuideButton:show];
}

// To enable or disable sending audio message
RCT_EXPORT_METHOD(AllowSendAudioMessage:(BOOL) allow)  // default = YES
{
    [WTSDKManager ShouldAllowSendAudioMessage:allow];
}

// To show or hide add participants option in new ticket page and chat item profile page
RCT_EXPORT_METHOD(AllowAddParticipants:(BOOL) allow)    // default = YES
{
    [WTSDKManager ShouldAllowAddParticipant:allow];
}

// To show or hide remove participants option in chat item profile
RCT_EXPORT_METHOD(AllowRemoveParticipants:(BOOL) allow) // default = NO
{
    [WTSDKManager ShouldAllowRemoveParticipant:allow];
}

// To show or hide welcome message
RCT_EXPORT_METHOD(ShowWelcomeMessage:(BOOL) show)            // default = NO
{
    [WTSDKManager ShowWelcomeMessage:show];
}

// To show or hide Profile Info page
RCT_EXPORT_METHOD(ShowProfileInfoPage:(BOOL) show)           // default = YES
{
    [WTSDKManager ShowProfileInfoPage:show];
}

// To create auto tickets:
//Chat ticket will create automatically when auto tickets is enabled, otherwise default ticket creation page will popup
RCT_EXPORT_METHOD(EnableAutoTickets:(BOOL) enable)           // default = NO
{
    [WTSDKManager EnableAutoTickets:enable];
}

// To show or hide close chat button in chat page
RCT_EXPORT_METHOD(ShowExitButton:(BOOL) show)                // default = NO
{
    [WTSDKManager ShowExitButton:show];
}

// To show or hide participants in chat profile page
RCT_EXPORT_METHOD(ShowChatParticipants:(BOOL) show)          // default = YES
{
    [WTSDKManager ShowChatParticipants:show];
}

// To enable or disbale chat profile page
RCT_EXPORT_METHOD(EnableChatProfile:(BOOL) enable)           // default = YES
{
    [WTSDKManager EnableChatProfile:enable];
}

// To allow modify  in chat profile page
RCT_EXPORT_METHOD(AllowModifyChatProfile:(BOOL) allow)       // default = YES
{
    [WTSDKManager AllowModifyChatProfile:allow];
}

// To set Inactive chat timeout:
//Chat session will end if user is inactive for timeout interval duration. If timeout interval is 0, chat session will not end automatically. The default timout interval is 1800 seconds (30 minutes).
RCT_EXPORT_METHOD(SetInactiveChatTimeoutInterval:(double) timeoutInterval)   // default = 1800 seconds (30 minutes).
{
    [WTSDKManager SetInactiveChatTimeoutInterval:timeoutInterval];
}

#pragma mark -

RCT_EXPORT_METHOD(updateUserImage:(NSString *) localImagePath callback:(RCTResponseSenderBlock) callback)
{
    [[WTLoginManager sharedInstance] uploadUserImageAtPath:localImagePath onCompletion:^(BOOL success, NSString *error) {
        if (success) {
            callback(@[@(YES), [NSNull null]]);
        }
        else {
            if (error) {
                callback(@[@(NO), error]);
            }
            else {
                callback(@[@(NO), @"Error Occured"]);
            }
        }
        
    }];
}

RCT_EXPORT_METHOD(updateUserName:(NSString *) userName callback:(RCTResponseSenderBlock) callback)
{
    [[WTLoginManager sharedInstance] updateUserProfileName:userName onCompletion:^(BOOL success, NSString *error) {
        if (success) {
            callback(@[@(YES), [NSNull null]]);
        }
        else {
            if (error) {
                callback(@[@(NO), error]);
            }
            else {
                callback(@[@(NO), @"Error Occured"]);
            }
        }
        
    }];
}


#pragma mark -
- (void) sendErrorEvent:(NSInteger) eventType withMessage:(NSString *) errorMessage {
    if (_hasListeners) {
//        [self sendWannatalkEvent:eventType error:errorMessage];
        [self sendEventWithName:EVENT_ERROR body:@{ @"code": @(eventType), @"message": errorMessage }];
    }
}

- (void) sendLoginStatus:(BOOL) loggedIn {
    if (_hasListeners) {
        
        NSString *message;
        if (loggedIn) {
            message = @"User Logged In";
        }
        else {
            message = @"User Logged Out";
        }
        [self sendEventWithName:EVENT_LOGIN body:@{ @"userLoggedIn": @(loggedIn), @"message": message }];
    }
}

- (void) sendLoginEvent:(NSString *) error {
    if (_hasListeners) {
        
        if (error) {
            [self sendEventWithName:EVENT_LOGIN body:@{ @"userLoggedIn": @(NO), @"error": error }];
        }
        else {
            [self sendEventWithName:EVENT_LOGIN body:@{ @"userLoggedIn": @(YES)}];
        }
    }
}

//- (void) sendWannatalkEvent:(NSInteger) eventType error:(NSString *) error {
//    if (_hasListeners) {
//        NSMutableDictionary *body = [NSMutableDictionary new];
//        body[@"eventType"] = @(eventType);
//        body[@"success"] = @(error == nil);
//        body[@"error"] = error;
//
//        //[self sendEventWithName:EVENT_WANNATALK body:body];
//    }
//}

//
//- (void) sendCallbackV2:(RCTResponseSenderBlock)callback error:(NSString *) error {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if (callback) {
//            if (error == nil) {
//                callback(@[@(YES), [NSNull null]]);
//            }
//            else {
//                callback(@[@(NO), error]);
//            }
//
//        }
//        callback = nil;
//    });
//}


- (void) sendLogoutCallback:(NSString *) error {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

           if (self.logoutSenderBlock) {
               if (error == nil) {
                   self.logoutSenderBlock(@[@(YES), [NSNull null]]);
               }
               else {
                   self.logoutSenderBlock(@[@(NO), error]);
               }
               
           }
           self.logoutSenderBlock = nil;
        
    });
    
}

- (void) sendLoginCallback:(NSString *) error {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.loginSenderBlock) {
            if (error == nil) {
                self.loginSenderBlock(@[@(YES), [NSNull null]]);
            }
            else {
                self.loginSenderBlock(@[@(NO), error]);
            }
            
        }
        self.loginSenderBlock = nil;
        
    });
}


#pragma mark - WTSDKManager Delegate Methods
+ (UIViewController *) GetWindowRootViewController {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *_rootViewController = (UIViewController *)window.rootViewController;
    return _rootViewController;
}

- (UINavigationController *) prepareViewHierachiesToLoadChatRoom:(BOOL) aiTopic {
    // Get view controller on which to present the flow
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//    UINavigationController *_rootViewController = (UINavigationController *)window.rootViewController;
    
    UINavigationController *_rootViewController = (UINavigationController *) [WannatalkCore GetWindowRootViewController];
    return _rootViewController;
//    if ([_rootViewController isKindOfClass:[UINavigationController class]]) {
//        return _rootViewController;
//    }
//    return nil;
}

#pragma mark - WTLoginManager Delegate Methods

// This method will be invoked when user sign in successfully
- (void) wtAccountDidLoginSuccessfully {
    [self sendLoginStatus:YES];
    [self sendLoginCallback:nil];
//    [self sendWannatalkEvent:kEventTypeLogin error:nil];
}
// This method will be invoked when user sign out successfully
- (void) wtAccountDidLogOutSuccessfully {
    [self sendLoginStatus:NO];
//    [self sendWannatalkEvent:kEventTypeLogout error:nil];
    [self sendLogoutCallback:nil];
}

// If implemented, this method will be invoked when login fails
- (void) wtAccountDidLoginFailWithError:(NSString *) error {
//    [self sendWannatalkEvent:kEventTypeLogin error:error];
    [self sendLoginCallback:error];
}
// If implemented, this method will be invoked when logout fails
- (void) wtAccountDidLogOutFailedWithError:(NSString *) error {
//    [self sendWannatalkEvent:kEventTypeLogout error:error];
    [self sendLogoutCallback:error];
}

#pragma mark - WTSDKManager Delegate Methods

// If implemented, this method will be invoked when organization profile loads successfully
- (void) wtsdkOrgProfileDidLoadSuccesfully {
//    [self sendWannatalkEvent:kEventTypeOrgProfile error:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (self.orgProfileSenderBlock) {
            self.orgProfileSenderBlock(@[@(YES), [NSNull null]]);
        }
        self.orgProfileSenderBlock = nil;
    });

}


// If implemented, this method will be invoked when organization profile fails to load
- (void) wtsdkOrgProfileDidLoadFailWithError:(NSString *) error {
//    [self sendWannatalkEvent:kEventTypeOrgProfile error:error];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (self.orgProfileSenderBlock) {
            self.orgProfileSenderBlock(@[@(NO), error]);
        }
        self.orgProfileSenderBlock = nil;
        
    });

}

// If implemented, this method will be invoked when chat list page loads successfully
- (void) wtsdkChatListDidLoadSuccesfully {
//    [self sendWannatalkEvent:kEventTypeChatList error:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (self.chatListSenderBlock) {
            self.chatListSenderBlock(@[@(YES), [NSNull null]]);
        }
        self.chatListSenderBlock = nil;
    });
}

// If implemented, this method will be invoked when chat list page fails to load
- (void) wtsdkChatListDidLoadFailWithError:(NSString *) error {
//    [self sendWannatalkEvent:kEventTypeChatList error:error];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (self.chatListSenderBlock) {
            self.chatListSenderBlock(@[@(NO), error]);
        }
        self.chatListSenderBlock = nil;
    });
}

// If implemented, this method will be invoked when user list page loads successfully
- (void) wtsdkUsersDidLoadSuccesfully {
//    [self sendWannatalkEvent:kEventTypeUsers error:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (self.userListSenderBlock) {
            self.userListSenderBlock(@[@(YES), [NSNull null]]);
        }
        self.userListSenderBlock = nil;
    });
}

// If implemented, this method will be invoked when user list page fails to load
- (void) wtsdkUsersDidLoadFailWithError:(NSString *) error {
//    [self sendWannatalkEvent:kEventTypeUsers error:error];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (self.userListSenderBlock) {
            self.userListSenderBlock(@[@(YES)]);
        }
        self.userListSenderBlock = nil;
    });
}

@end
