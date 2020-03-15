package com.reactlibrary;

import android.app.Application;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import java.util.HashMap;
import java.util.Map;

import com.facebook.react.bridge.ActivityEventListener;
// import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
// import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;

import android.content.Context;
import android.widget.Toast;

import com.facebook.react.ReactApplication;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.UiThreadUtil;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import android.util.Log;

import wannatalk.wannatalksdk.WTCore.Interface.IWTLoginManager;
import wannatalk.wannatalksdk.WTCore.Interface.IWTCompletion;
import wannatalk.wannatalksdk.WTCore.WTSDKManager;
import wannatalk.wannatalksdk.WTCore.WTSDKConstants;
import wannatalk.wannatalksdk.WTLogin.WTLoginManager;


import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;

public class WannatalkCoreModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    private final ActivityEventListener mActivityEventListener=new BaseActivityEventListener(){@Override public void onActivityResult(Activity activity,int requestCode,int resultCode,Intent data){super.onActivityResult(activity,requestCode,resultCode,data);
    // if (requestCode == RC_WANNATALK) {

    // }

    }};
    public WannatalkCoreModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        ReactApplication reactApplication = ((ReactApplication) reactContext.getApplicationContext());

        // UiThreadUtil.assertOnUiThread();
        final ReactInstanceManager reactInstanceManager = reactApplication.getReactNativeHost()
                .getReactInstanceManager();

        // ReactContext reactContext = reactInstanceManager.getCurrentReactContext();
        // if (reactContext == null)
        // {
        reactInstanceManager.addReactInstanceEventListener(new ReactInstanceManager.ReactInstanceEventListener() {
            @Override
            public void onReactContextInitialized(final ReactContext reactContext) {

                new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        invoke();
                    }
                }, 500);
                reactInstanceManager.removeReactInstanceEventListener(this);
            }
        });
        if (!reactInstanceManager.hasStartedCreatingInitialContext()) {
            reactInstanceManager.createReactContextInBackground();
        }
        // } else {
        // invoke();
        // }

        reactContext.addActivityEventListener(mActivityEventListener);
    }
    private void invoke() {

        // Context context = getApplicationContext();
        final Application applicationContext = (Application) this.reactContext.getApplicationContext();
        // console.log("Appliction" + applicationContext);

        // WTSDKManager.Load(null, applicationContext);
        // WTSDKManager.InitializeSDK();
        WTLoginManager.setIwtLoginManager(iwtLoginManager);
    }

    @Override
    public String getName() {
        return "WannatalkCore";
    }

    @ReactMethod
    public void isUserLoggedIn(Callback callback) {
        callback.invoke(WTLoginManager.IsUserLoggedIn());
    }

    Callback loginCallback;
    Callback logoutCallback;

    @ReactMethod
    void login(Callback callback) {
        loginCallback = callback;
        Activity currentActivity = getCurrentActivity();
        WTLoginManager.StartLoginActivity(currentActivity);

    }

    @ReactMethod
    void silentLogin(final String identifier, final ReadableMap params, Callback callback) {
        loginCallback = callback;
        Activity currentActivity = getCurrentActivity();
        // Silent authentication without otp verification

        Bundle bundle = new Bundle();
        if (params != null) {
            ReadableMapKeySetIterator iterator = params.keySetIterator();
            while (iterator.hasNextKey()) {
                String key = iterator.nextKey();
                String value = params.getString(key);
                bundle.putString(key, value);
            }
        }

        WTLoginManager.SilentLoginActivity(identifier, bundle, currentActivity);

    }

    @ReactMethod
    void logout(Callback callback) {
        logoutCallback = callback;
        Activity currentActivity = getCurrentActivity();
        WTLoginManager.Logout(currentActivity);
    }

    // Callback orgProfileCallback;
    // Callback chatListCallback;
    // Callback userListCallback;

    @ReactMethod
    void loadOrganizationProfile(Boolean autoOpenChat, final Callback callback) {

        // Load organization profile
        Activity currentActivity = getCurrentActivity();
        // WTSDKManager.LoadOrganizationActivity(currentActivity, autoOpenChat);
        WTSDKManager.LoadOrganizationActivity(currentActivity, true, new IWTCompletion() {
            @Override
            public void onCompletion(boolean success, String error) {
                // Log.e(TAG, "success: " + success + " error: " + error);

                if (callback != null) {
                    callback.invoke(success, error);
                }
            }
        });
    }

    @ReactMethod
    void loadChatList(final Callback callback) {
        // Load chat list
        Activity currentActivity = getCurrentActivity();
        // WTSDKManager.LoadChatListActivity(currentActivity);
        WTSDKManager.LoadChatListActivity(currentActivity, new IWTCompletion() {
            @Override
            public void onCompletion(boolean success, String error) {
                if (callback != null) {
                    callback.invoke(success, error);
                }
            }
        });
    }

    @ReactMethod
    void loadUsers(final Callback callback) {
        // Load users
        Activity currentActivity = getCurrentActivity();
        // WTSDKManager.LoadUsersActivity(currentActivity);
        WTSDKManager.LoadUsersActivity(currentActivity, new IWTCompletion() {
            @Override
            public void onCompletion(boolean success, String error) {
                if (callback != null) {
                    callback.invoke(success, error);
                }
            }
        });
    }

    // @ReactMethod
    // public static void sendNotification(RemoteMessage remoteMessage, Context
    // context) {
    // WTBaseSDKManager.SendNotification(remoteMessage, context);
    // }

    // @ReactMethod
    // public static void SetDeviceToken(String deviceToken) {
    // WTBaseSDKManager.SetDeviceToken(deviceToken);
    // }

    @ReactMethod
    public static void ClearOldTempFiles() {
        WTSDKManager.ClearOldTempFiles();
    }

    @ReactMethod
    public static void ClearTempFiles() {
        WTSDKManager.ClearTempFiles();
    }

    @ReactMethod
    public static void ShowGuideButton(boolean show) {
        WTSDKManager.ShowGuideButton(show);
    }

    @ReactMethod
    public static void ShowProfileInfoPage(boolean show) {
        WTSDKManager.ShowProfileInfoPage(show);
    }

    @ReactMethod
    public static void AllowSendAudioMessage(boolean allow) {
        WTSDKManager.AllowSendAudioMessage(allow);
    }

    @ReactMethod
    public static void AllowAddParticipants(boolean allow) {
        WTSDKManager.AllowAddParticipants(allow);
    }

    @ReactMethod
    public static void AllowRemoveParticipants(boolean allow) {
        WTSDKManager.AllowRemoveParticipants(allow);
    }

    @ReactMethod
    public static void ShowWelcomeMessage(boolean show) {
        WTSDKManager.ShowWelcomeMessage(show);
    }

    @ReactMethod
    public static void EnableAutoTickets(boolean enable) {
        WTSDKManager.EnableAutoTickets(enable);
    }

    @ReactMethod
    public static void ShowExitButton(boolean show) {
        WTSDKManager.ShowExitButton(show);
    }

    @ReactMethod
    public static void ShowChatParticipants(boolean show) {
        WTSDKManager.ShowChatParticipants(show);
    }

    @ReactMethod
    public static void EnableChatProfile(boolean enable) {
        WTSDKManager.EnableChatProfile(enable);
    }

    @ReactMethod
    public static void AllowModifyChatProfile(boolean allow) {
        WTSDKManager.AllowModifyChatProfile(allow);
    }

    @ReactMethod
    public static void SetInactiveChatTimeoutInterval(long timeoutInSeconds) {
        WTSDKManager.SetInactiveChatTimeoutInterval(timeoutInSeconds);
    }



    @ReactMethod
    public static void updateUserImage(String localImagePath, final Callback callback) {
        WTLoginManager.UploadUserImageAtPath(localImagePath, new IWTCompletion() {
            @Override
            public void onCompletion(boolean success, String error) {
                callback.invoke(success, error);
            }
        });
    }


    @ReactMethod
    public static void updateUserName(String userName, final Callback callback) {
        WTLoginManager.UpdateUserProfileName(userName, new IWTCompletion() {
            @Override
            public void onCompletion(boolean success, String error) {
                callback.invoke(success, error);
            }
        });

    }




    private void sendErrorEvent(int errorCode, String message) {
        WritableMap params = Arguments.createMap();
            params.putInt("code", errorCode);
            params.putString("message", message);
            reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("error-event", params);
    }

    private void sendLoginEvent(Boolean loggedIn) {
        WritableMap params = Arguments.createMap();
            params.putBoolean("userLoggedIn", loggedIn);
            if (loggedIn) {
                params.putString("message", "User Logged In");
            }
            else {
                params.putString("message", "User Logged Out");
            }
            reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("login-event", params);
    }

private void sendLoginCallback(String error) {
    if (loginCallback != null) {
        loginCallback.invoke(error == null, error);
    }
    loginCallback = null;
}

private void sendLogoutCallback(String error) {
    if (logoutCallback != null) {
        logoutCallback.invoke(error == null, error);
    }
    logoutCallback = null;
}

    IWTLoginManager iwtLoginManager = new IWTLoginManager() {

        @Override
        public void wtsdkUserLoggedIn() {
            sendLoginCallback(null);
            sendLoginEvent(true);
        }

        @Override
        public void wtsdkUserLoginFailed(String error) {
            sendLoginCallback(error);
        }

        @Override
        public void wtsdkUserLoggedOut() {
            sendLogoutCallback(null);
            sendLoginEvent(false);
        }

        @Override
        public void wtsdkUserLogoutFailed(String error) {
            sendLogoutCallback(error);
        }

    };
}
