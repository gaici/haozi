//
//  RCDMessageNotifyTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/11/20.
//  Copyright (c) 2014年 胡利武. All rights reserved.
//

#import "RCDMessageNotifySettingTableViewController.h"
#import "MBProgressHUD.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDMessageNotifySettingTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *notifySwitch;
@end

@implementation RCDMessageNotifySettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //通知开启状态
//    UIUserNotificationType userNotiType = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
//    if (userNotiType != UIUserNotificationTypeNone) {
//        [self.notifySwitch setEnabled:YES];
//    }else{
//        [self.notifySwitch setEnabled:NO];
//    }
    [[RCIMClient sharedRCIMClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (spansMin > 0) {
                self.notifySwitch.on = NO;
            } else {
                self.notifySwitch.on = YES;
            }
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.notifySwitch.on = YES;
        });
    }];
}
- (IBAction)onSwitch:(id)sender {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"设置中...";
    if (!self.notifySwitch.on) {
        [[RCIMClient sharedRCIMClient] setConversationNotificationQuietHours:@"00:00:00" spanMins:1339 success:^{
            NSLog(@"setConversationNotificationQuietHours succeed");
            [[RCIM sharedRCIM] setDisableMessageNotificaiton:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
            });
        } error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设置失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alert show];
                self.notifySwitch.on = YES;
                [hud hide:YES];
            });
        }];
    } else {
        [[RCIMClient sharedRCIMClient] removeConversationNotificationQuietHours:^{
            [[RCIM sharedRCIM] setDisableMessageNotificaiton:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
            });
        } error:^(RCErrorCode status) {

            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"取消失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alert show];
                self.notifySwitch.on = NO;
                [hud hide:YES];
            });
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}



@end
