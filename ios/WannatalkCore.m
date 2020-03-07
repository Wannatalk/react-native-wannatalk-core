#import "WannatalkCore.h"
#import <WTExternalSDK/WTExternalSDK.h>
#import <React/RCTLog.h>
#import <React/RCTConvert.h>

@interface WannatalkCore() <WTLoginManagerDelegate, WTSDKManagerDelegate> {
    BOOL _hasListeners;
}

@end

@implementation WannatalkCore

typedef NS_ENUM(NSInteger, WTFunctionCodes)
{
    WTFCLogin = 1,
    WTFCSilentLogin,
    WTFCLogout,
    WTFCLoadOrganizationProfile,
    WTFCLoadChatList,
    WTFCLoadUsers
};


- (instancetype) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"error-event", @"login-event"];
}

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

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(isUserLoggedIn:(RCTResponseSenderBlock)callback) {
    
    callback(@[@([WTLoginManager sharedInstance].isUserLoggedIn)]);
}

RCT_EXPORT_METHOD(logout) {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            @try {
                
                [[WTLoginManager sharedInstance] logout];
                
            } @catch (NSException *e) {
                [self sendErrorEvent:WTFCLogout withMessage:[e description]];
                
            }
        });
        
    });

    
}



RCT_EXPORT_METHOD(silentLogin:(NSString *) identifier userInfo:(NSDictionary *) userInfo)  {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Get view controller on which to present the flow
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIViewController *_rootViewController = (UIViewController *)window.rootViewController;
            
            @try {
                
                [WTLoginManager sharedInstance].delegate = self;
                
                [[WTLoginManager sharedInstance] silentLoginWithIdentifier:identifier userInfo:userInfo fromVC:_rootViewController];
                
            } @catch (NSException *e) {
                [self sendErrorEvent:WTFCSilentLogin withMessage:[e description]];
                
            }
        });
    });
    
    
    
    
}


RCT_EXPORT_METHOD(login) {

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Get view controller on which to present the flow
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIViewController *_rootViewController = (UIViewController *)window.rootViewController;
            
            @try {
                
                [WTLoginManager sharedInstance].delegate = self;
                [[WTLoginManager sharedInstance] loginFromVC:_rootViewController];
                
                
            } @catch (NSException *e) {
                [self sendErrorEvent:WTFCLogin withMessage:[e description]];
                
            }
        });
    });
    

}
#pragma mark - Delegate Methods

- (void) wtAccountDidLoginSuccessfully {

    [self sendLoginStatus:YES];
}

- (void) wtAccountDidLogOutSuccessfully {

    [self sendLoginStatus:NO];
}

#pragma mark -

- (void) wtsdkOrgProfileDidLoadFailWithError:(NSString *)error {
    
}

- (void) wtsdkOrgProfileDidLoadSuccesfully {
    
}

#pragma mark -

RCT_EXPORT_METHOD(loadOrganizationProfile:(BOOL) autoOpenChat) {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Get view controller on which to present the flow
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIViewController *_rootViewController = (UIViewController *)window.rootViewController;
            
            @try {
                
                [_rootViewController presentOrgProfileVCWithAutoOpenChat:autoOpenChat delegate:self animated:YES completion:^{
                    
                    
                }];
                
            } @catch (NSException *e) {
                [self sendErrorEvent:WTFCLoadOrganizationProfile withMessage:[e description]];
                
                
            }
        });
    });
    
    
}

RCT_EXPORT_METHOD(loadChatList) {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Get view controller on which to present the flow
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIViewController *_rootViewController = (UIViewController *)window.rootViewController;
            
            @try {
                
                [_rootViewController presentChatListVCWithDelegate:self animated:YES completion:^{
                    
                    
                }];
                
            } @catch (NSException *e) {
                [self sendErrorEvent:WTFCLoadChatList withMessage:[e description]];
                
            }
        });
    });
    
}


RCT_EXPORT_METHOD(loadUsers) {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Get view controller on which to present the flow
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIViewController *_rootViewController = (UIViewController *)window.rootViewController;
            
            @try {
                
                [_rootViewController presentUsersVCWithDelegate:self animated:YES completion:^{
                    
                    
                }];
                
                
            } @catch (NSException *e) {
                
                [self sendErrorEvent:WTFCLoadUsers withMessage:[e description]];
                
            }
        });
    });
    
}

- (void) sendErrorEvent:(NSInteger) errorCode withMessage:(NSString *) errorMessage {
    if (_hasListeners) {
        [self sendEventWithName:@"error-event" body:@{ @"code": @(errorCode), @"message": errorMessage }];
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
        [self sendEventWithName:@"login-event" body:@{ @"userLoggedIn": @(loggedIn), @"message": message }];
    }
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

@end
