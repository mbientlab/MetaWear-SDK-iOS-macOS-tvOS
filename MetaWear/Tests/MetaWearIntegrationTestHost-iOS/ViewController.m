//
//  ViewController.m
//  MetaWear
//
//  Created by Stephen Schiffli on 9/27/16.
//  Copyright © 2016 Stephen Schiffli. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)sendPushNotification:(id)sender
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Test Notification";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

@end
