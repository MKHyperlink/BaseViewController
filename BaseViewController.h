//
//  BaseViewController.h
//  PoChannel
//
//  Created by iOS team on 11/12/13.
//  Copyright (c) 2013 iOS team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#define TOAST_INTERVAL  3   //seconds
#define WAITING_TIME    30  //seconds
#define WAIT_PRESS_TIME 30   //seconds
#define BASEVIEW_TIMEOUT_NOTIFICATION @"BASEVIEW_TIMEOUT_NOTIFICATION"

typedef void (^EventBlock) (void);

@interface BaseViewController : UIViewController {
    MBProgressHUD *processingHint;
    NSString *loadingMessage;
    int timerCounter;
    BOOL isLoading;
    BOOL isEnableLoadingTimeout;
    BOOL isShowTimeoutToast;
    int loadingTimeout;
    NSString *mCurrentView;
}

@property (nonatomic, retain) NSTimer *mWaitingTimer;
@property (nonatomic, copy) EventBlock mToastEventBlock;
@property (nonatomic, copy) EventBlock mLoadingEventBlock;

- (void) setShowTimeoutToast:(BOOL) enable;
- (void) setLoadingTimeout:(int) timeout;
- (void) setLoadingTimeoutEnable:(BOOL) isEnable;
- (void) setLoadingMessage:(NSString *) text;
- (void) showLoading;
- (void) showLoadingNoLockToolBar;
- (void) stopLoading;
- (void) showToast:(NSString *) text;

- (void) showOkDialog:(NSString *) title
              message:(NSString *) message
             okAction:(void(^)()) okPredicate;

- (void) showConfirmDialog:(NSString *) title
                   message:(NSString *) message
                  okAction:(void(^)()) okPredicate
              cancelAction:(void(^)()) cancelPredicate;
- (void) showConfirmDialogWithTextInput:(NSString *) title
                                message:(NSString *) message
                            placeholder:(NSString *) placeholder
                            displayText:(NSString *) displayText
                               okAction:(void(^)(NSString * text)) okPredicate
                           cancelAction:(void(^)()) cancelPredicate;

- (void) showActionSheet:(NSString *) title
                 message:(NSString *) message
        buttonTitleArray:(NSArray<NSString *> *) btnTitleAry
       buttonActionArray:(NSArray<void(^)()> *) btnActAry;


- (void) setToastEventBlock:(EventBlock)block;
- (void) setLoadingEventBlock:(EventBlock)block;

- (BOOL) isLoading;
- (void) showLoadingWithHiddenLoadingProcess;

- (void) rejectMultitouchFromView:(UIView*)parentView;

@end
