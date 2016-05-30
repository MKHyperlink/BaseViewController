//
//  BaseViewController.m
//  PoChannel
//
//  Created by iOS team on 11/12/13.
//  Copyright (c) 2013 iOS team. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
@synthesize mWaitingTimer;

- (id)initWithCoder:(NSCoder*)coder 	//Init from storyboard
{
    if (self = [super initWithCoder:coder]) {
        [self paramaterInit];
    }
    return self;
}

- (id) init
{
    self = [super init];
    if(self){
        [self paramaterInit];
    }
    return self;
}

- (void) paramaterInit{
    isEnableLoadingTimeout = YES;
    loadingTimeout = WAITING_TIME;
    isShowTimeoutToast = YES;
}

- (void) setShowTimeoutToast:(BOOL) enable{
    isShowTimeoutToast = enable;
}

- (void) setLoadingTimeout:(int) timeout{
    loadingTimeout = timeout;
}

- (void) setLoadingTimeoutEnable:(BOOL) isEnable{
    isEnableLoadingTimeout = isEnable;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setLoadingMessage:(NSString *) text{
    loadingMessage = text;
}

- (void)showLoading{
    if(isLoading){
        return;
    }
    timerCounter = 0;
    isLoading = YES;
    if(isEnableLoadingTimeout){
        mWaitingTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                             target: self
                                           selector: @selector(handleTimer)
                                           userInfo: nil
                                            repeats: YES];
    }
    
    processingHint = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    processingHint.mode = MBProgressHUDModeIndeterminate;
    if(loadingMessage){
        processingHint.detailsLabel.text = loadingMessage;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void) showLoadingWithHiddenLoadingProcess
{
    if(isLoading){
        return;
    }
    timerCounter = 0;
    isLoading = YES;
    if(isEnableLoadingTimeout){
        mWaitingTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                         target: self
                                                       selector: @selector(handleTimer)
                                                       userInfo: nil
                                                        repeats: YES];
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void) showLoadingNoLockToolBar{
    if(isLoading){
        return;
    }
    timerCounter = 0;
    isLoading = YES;
    if(isEnableLoadingTimeout){
        mWaitingTimer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                         target: self
                                                       selector: @selector(handleTimer)
                                                       userInfo: nil
                                                        repeats: YES];
    }
    
    processingHint = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    processingHint.mode = MBProgressHUDModeIndeterminate;
    if(loadingMessage){
        processingHint.detailsLabel.text = loadingMessage;
    }
}

-(void) stopLoading{
    timerCounter = 0;
    
    [mWaitingTimer invalidate];
    
    [processingHint hideAnimated:TRUE];
    [processingHint removeFromSuperview];
    processingHint = nil;
    loadingMessage = nil;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    if (_mLoadingEventBlock != nil) {
        
        dispatch_queue_t loadingQueue = dispatch_queue_create("loadingQueue", nil);
        dispatch_async(loadingQueue, ^(void) {
            _mLoadingEventBlock();
            _mLoadingEventBlock = nil;
            isLoading = NO;
        });
    }else{
        isLoading = NO;
    }
}

- (BOOL) isLoading
{
    return isLoading;
}

- (void) showToast:(NSString *) text {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
//    HUD.labelText = text;         // only single line
    HUD.detailsLabel.text = text;    // allow multi line
    HUD.mode = MBProgressHUDModeText;
    HUD.offset = CGPointMake(HUD.offset.x, 160);
    [HUD showWhileExecuting:@selector(threadSleep:) onTarget:self withObject:HUD animated:YES];
}

- (void) threadSleep:(MBProgressHUD *)HUD {
    sleep(TOAST_INTERVAL);
    [Utils performInMainThread:^{
        [HUD removeFromSuperview];
    }];
    
    if (_mToastEventBlock != nil) {
        _mToastEventBlock();
        _mToastEventBlock = nil;
    }
}

- (void) handleTimer{
    timerCounter++;
    if(timerCounter>loadingTimeout){
        [mWaitingTimer invalidate];
        if(isShowTimeoutToast) [self showToast:NSLocalizedStringFromTable(@"Loading Timeout", LOCALIZATION_FILE, @"Loading Timeout")];
        [self stopLoading];
        timerCounter = 0;
        [Utils performInMainThread:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BASEVIEW_TIMEOUT_NOTIFICATION object:self userInfo:nil];
        }];
    }
}

- (void) showOkDialog:(NSString *) title
              message:(NSString *) message
             okAction:(void(^)()) okPredicate {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: title
                                                                              message: message
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[ToolsFunction stringTable:@"STRID_000_001"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (okPredicate) okPredicate();
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) showConfirmDialog:(NSString *) title
                   message:(NSString *) message
                  okAction:(void(^)()) okPredicate
              cancelAction:(void(^)()) cancelPredicate {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: title
                                                                              message: message
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[ToolsFunction stringTable:@"STRID_000_001"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (okPredicate) okPredicate();
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[ToolsFunction stringTable:@"STRID_000_002"] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if (cancelPredicate) cancelPredicate();
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) showConfirmDialogWithTextInput:(NSString *) title
                                message:(NSString *) message
                            placeholder:(NSString *) placeholder
                            displayText:(NSString *) displayText
                               okAction:(void(^)(NSString * text)) okPredicate
                           cancelAction:(void(^)()) cancelPredicate {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: title
                                                                              message: message
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        if (displayText) {
            textField.text = displayText;
        }
        textField.placeholder = placeholder?placeholder:@"";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:[ToolsFunction stringTable:@"STRID_000_001"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * text = textfields[0];
        
        if (okPredicate) okPredicate(text.text);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[ToolsFunction stringTable:@"STRID_000_002"] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if (cancelPredicate) cancelPredicate();
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) showActionSheet:(NSString *) title
                 message:(NSString *) message
        buttonTitleArray:(NSArray<NSString *> *) btnTitleAry
       buttonActionArray:(NSArray<void(^)()> *) btnActAry {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: title
                                                                              message: message
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertActionStyle actStyle;
    for (int i=0; i<btnTitleAry.count; i++) {
        
        actStyle = UIAlertActionStyleDefault;
        if (i==(btnTitleAry.count-1)) {
            actStyle = UIAlertActionStyleCancel;
        }
        [alertController addAction:[UIAlertAction actionWithTitle:btnTitleAry[i]
                                                            style:actStyle
                                                          handler:^(UIAlertAction *action) {
                                                              
            if (i<btnActAry.count && btnActAry[i]) {
                void (^ block)() = btnActAry[i];
                block();
            }
        }]];
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void) setToastEventBlock:(EventBlock)block
{
    _mToastEventBlock = [block copy];
}

- (void) setLoadingEventBlock:(EventBlock)block
{
    _mLoadingEventBlock = [block copy];
}

- (void) rejectMultitouchFromView:(UIView*)parentView {
    for (UIView *subViews in parentView.subviews) {
        [self removeMultitouchSubviews:subViews];
        
    }
}
- (void)removeMultitouchSubviews:(UIView *)subView
{
    if (subView.subviews.count>0) {
        for (UIView *subViews in subView.subviews) {
            [self removeMultitouchSubviews:subViews];
        }
    }
    else
    {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton* btn = (UIButton*)subView;
            [btn setExclusiveTouch:YES];
        }
    }
}

@end
