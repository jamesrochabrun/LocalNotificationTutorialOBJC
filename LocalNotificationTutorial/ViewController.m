//
//  ViewController.m
//  LocalNotificationTutorial
//
//  Created by James Rochabrun on 11/8/16.
//  Copyright © 2016 James Rochabrun. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>


@interface ViewController ()<UNUserNotificationCenterDelegate>
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, assign) NSTimeInterval countDownInterval;
@property (nonatomic, strong) UIDatePicker *timePicker;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:9.0/255.0 green:26.0/255.0 blue:56.0/255.0 alpha:1.0];
    
    _timePicker = [UIDatePicker new];
    _timePicker.backgroundColor = [UIColor clearColor];
    _timePicker.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    [_timePicker addTarget:self action:@selector(userSelectTime:) forControlEvents:UIControlEventValueChanged];
    [_timePicker setValue:[UIColor colorWithRed:253.0/255.0 green:210.0/255.0 blue:5.0/255.0 alpha:1.0] forKey:@"textColor"];
    _timePicker.datePickerMode = UIDatePickerModeCountDownTimer;
    dispatch_async(dispatch_get_main_queue(), ^{
        _timePicker.countDownDuration = _countDownInterval;
    });
    [self.view addSubview:_timePicker];
    
    _button = [UIButton new];
    _button.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:27.0/255.0 blue:73.0/255.0 alpha:1.0];
    [_button setTitle:@"SET TIMER" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(generateLocalNotification:) forControlEvents:UIControlEventTouchUpInside];
    _button.layer.cornerRadius = 20;
    _button.alpha = 0.3;
    _button.userInteractionEnabled = NO;
    [self.view addSubview:_button];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect frame = _timePicker.frame;
    frame.size.height = _timePicker.intrinsicContentSize.height;
    frame.size.width = self.view.frame.size.width;
    frame.origin.x = 0;
    frame.origin.y = (self.view.frame.size.height - frame.size.height) /2;
    _timePicker.frame = frame;
    
    frame = _button.frame;
    frame.size.height = 50;
    frame.size.width = 200;
    frame.origin.x = (self.view.frame.size.width - frame.size.width) /2;
    frame.origin.y = ((CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(_timePicker.frame)) - frame.size.height) / 2 + CGRectGetMaxY(_timePicker.frame);
    _button.frame = frame;
    
}

- (void)userSelectTime:(UIDatePicker *)sender {
    
    _countDownInterval = (NSTimeInterval)sender.countDownDuration;
    
    if (_countDownInterval >= 120) {
        _button.alpha = 1;
        _button.userInteractionEnabled = YES;
    } else {
        _button.alpha = 0.3;
        _button.userInteractionEnabled = NO;
    }
}

- (void)generateLocalNotification:(id)sender {
    
    UNMutableNotificationContent *localNotification = [UNMutableNotificationContent new];
    localNotification.title = [NSString localizedUserNotificationStringForKey:@"Time for a run!" arguments:nil];
    localNotification.body = [NSString localizedUserNotificationStringForKey:@"BTW, running late to happy hour does not count as workout" arguments:nil];
    localNotification.sound = [UNNotificationSound defaultSound];
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:_countDownInterval repeats:NO];
    
    localNotification.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] +1);
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Time for a run!" content:localNotification trigger:trigger];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"NOTIFICATION CREATED");
    }];
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Notification alert" message:@"This app just sent you a notification, do you want to see it?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ignore = [UIAlertAction actionWithTitle:@"IGNORE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"USER DECIDED TO IGNORE THE NOTIFICATION");
    }];
    UIAlertAction *view = [UIAlertAction actionWithTitle:@"SEE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self takeActionWithLocalNotification:notification];
    }];
    
    [alertController addAction:ignore];
    [alertController addAction:view];
    
    [self presentViewController:alertController animated:YES completion:^{
    }];
}


- (void)takeActionWithLocalNotification:(UNNotification *)localNotification {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:localNotification.request.content.title message:localNotification.request.content.body preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"OK, USER SAW THE NOTIFICATION");
    }];
    
    [alertController addAction:ok];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:^{
        }];
    });
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    [self takeActionWithLocalNotification:response.notification];
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
