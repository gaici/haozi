//
//  RCDChatViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 胡利武. All rights reserved.
//

#import "RCDChatViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDChatViewController.h"
#import "RCDDiscussGroupSettingViewController.h"
#import "RCDRoomSettingViewController.h"
#import "RCDPrivateSettingViewController.h"
#import "RCDGroupDetailViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDHttpTool.h"

@interface RCDChatViewController ()

@end

@implementation RCDChatViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    self.enableSaveNewPhotoToLocalSystem = YES;

    if (self.conversationType != ConversationType_CHATROOM) {
      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
          initWithImage:[UIImage imageNamed:@"Setting"]
                  style:UIBarButtonItemStylePlain
                 target:self
                 action:@selector(rightBarButtonItemClicked:)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }

    [self notifyUpdateUnreadMessageCount];
/***********如何自定义面板功能***********************
 自定义面板功能首先要继承RCConversationViewController，如现在所在的这个文件。
 然后在viewDidLoad函数的super函数之后去编辑按钮：
 插入到指定位置的方法如下：
 [self.pluginBoardView insertItemWithImage:imagePic
                                     title:title
                                   atIndex:0
                                       tag:101];
 或添加到最后的：
 [self.pluginBoardView insertItemWithImage:imagePic
                                     title:title
                                       tag:101];
 删除指定位置的方法：
 [self.pluginBoardView removeItemAtIndex:0];
 删除指定标签的方法：
 [self.pluginBoardView removeItemWithTag:101];
 删除所有：
 [self.pluginBoardView removeAllItems];
 更换现有扩展项的图标和标题:
 [self.pluginBoardView updateItemAtIndex:0 image:newImage title:newTitle];
 或者根据tag来更换
 [self.pluginBoardView updateItemWithTag:101 image:newImage title:newTitle];
 以上所有的接口都在RCPluginBoardView.h可以查到。
 
 当编辑完扩展功能后，下一步就是要实现对扩展功能事件的处理，放开被注掉的函数
 pluginBoardView:clickedItemWithTag:
 在super之后加上自己的处理。
 
 */

}

- (void)leftBarButtonItemPressed:(id)sender {
  //需要调用super的实现
  [super leftBarButtonItemPressed:sender];

  [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  此处使用自定义设置，开发者可以根据需求自己实现
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */
- (void)rightBarButtonItemClicked:(id)sender {
  if (self.conversationType == ConversationType_PRIVATE) {

    RCDPrivateSettingViewController *settingVC =
        [[RCDPrivateSettingViewController alloc] init];
    settingVC.conversationType = self.conversationType;
    settingVC.targetId = self.targetId;
//    settingVC.conversationTitle = self.userName;
//    //设置讨论组标题时，改变当前聊天界面的标题
//    settingVC.setDiscussTitleCompletion = ^(NSString *discussTitle) {
//      self.title = discussTitle;
//    };
    //清除聊天记录之后reload data
    __weak RCDChatViewController *weakSelf = self;
    settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
      if (isSuccess) {
        [weakSelf.conversationDataRepository removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf.conversationMessageCollectionView reloadData];
        });
      }
    };

    [self.navigationController pushViewController:settingVC animated:YES];

  } else if (self.conversationType == ConversationType_DISCUSSION) {

    RCDDiscussGroupSettingViewController *settingVC =
        [[RCDDiscussGroupSettingViewController alloc] init];
    settingVC.conversationType = self.conversationType;
    settingVC.targetId = self.targetId;
    settingVC.conversationTitle = self.userName;
    //设置讨论组标题时，改变当前聊天界面的标题
    settingVC.setDiscussTitleCompletion = ^(NSString *discussTitle) {
      self.title = discussTitle;
    };
    //清除聊天记录之后reload data
    __weak RCDChatViewController *weakSelf = self;
    settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
      if (isSuccess) {
        [weakSelf.conversationDataRepository removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf.conversationMessageCollectionView reloadData];
        });
      }
    };

    [self.navigationController pushViewController:settingVC animated:YES];
  }

  //聊天室设置
  else if (self.conversationType == ConversationType_CHATROOM) {
    RCDRoomSettingViewController *settingVC =
        [[RCDRoomSettingViewController alloc] init];
    settingVC.conversationType = self.conversationType;
    settingVC.targetId = self.targetId;
    [self.navigationController pushViewController:settingVC animated:YES];
  }

  //群组设置
  else if (self.conversationType == ConversationType_GROUP) {
//    RCSettingViewController *settingVC = [[RCSettingViewController alloc] init];
//    settingVC.conversationType = self.conversationType;
//    settingVC.targetId = self.targetId;
//    //清除聊天记录之后reload data
//    __weak RCDChatViewController *weakSelf = self;
//    settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
//      if (isSuccess) {
//        [weakSelf.conversationDataRepository removeAllObjects];
//        dispatch_async(dispatch_get_main_queue(), ^{
//          [weakSelf.conversationMessageCollectionView reloadData];
//        });
//      }
//    };
//    [self.navigationController pushViewController:settingVC animated:YES];
      UIStoryboard *secondStroyBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
      RCDGroupDetailViewController *detail=[secondStroyBoard instantiateViewControllerWithIdentifier:@"RCDGroupDetailViewController"];
      NSMutableArray *groups=RCDHTTPTOOL.allGroups ;
      __weak RCDChatViewController *weakSelf = self;
      detail.clearHistoryCompletion = ^(BOOL isSuccess) {
          if (isSuccess) {
              [weakSelf.conversationDataRepository removeAllObjects];
              dispatch_async(dispatch_get_main_queue(), ^{
                  [weakSelf.conversationMessageCollectionView reloadData];
              });
          }
      };
      if (groups) {
          for (RCDGroupInfo *group in groups) {
              if ([group.groupId isEqualToString: self.targetId]) {
                  detail.groupInfo=group;
                  [self.navigationController pushViewController:detail animated:NO];
                  return;
              }
          }
      }
//      [RCDDataSource getGroupInfoWithGroupId:self.targetId completion:^(RCGroup *groupInfo) {
//          detail.groupInfo=[[RCDGroupInfo alloc]init];
//          detail.groupInfo.groupId=groupInfo.groupId;
//          detail.groupInfo.groupName=groupInfo.groupName;
//          dispatch_async(dispatch_get_main_queue(), ^{
//              [self.navigationController pushViewController:detail animated:NO];
//          });
//          
//      }];
      
      
  }
  //客服设置
  else if (self.conversationType == ConversationType_CUSTOMERSERVICE) {
    RCSettingViewController *settingVC = [[RCSettingViewController alloc] init];
    settingVC.conversationType = self.conversationType;
    settingVC.targetId = self.targetId;
    //清除聊天记录之后reload data
    __weak RCDChatViewController *weakSelf = self;
    settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
      if (isSuccess) {
        [weakSelf.conversationDataRepository removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf.conversationMessageCollectionView reloadData];
        });
      }
    };
    [self.navigationController pushViewController:settingVC animated:YES];
  }
}

/**
 *  打开大图。开发者可以重写，自己下载并且展示图片。默认使用内置controller
 *
 *  @param imageMessageContent 图片消息内容
 */
- (void)presentImagePreviewController:(RCMessageModel *)model;
{
  RCImagePreviewController *_imagePreviewVC =
      [[RCImagePreviewController alloc] init];
  _imagePreviewVC.messageModel = model;
  _imagePreviewVC.title = @"图片预览";

  UINavigationController *nav = [[UINavigationController alloc]
      initWithRootViewController:_imagePreviewVC];

  [self presentViewController:nav animated:YES completion:nil];
}

- (void)didLongTouchMessageCell:(RCMessageModel *)model inView:(UIView *)view {
    [super didLongTouchMessageCell:model inView:view];
    NSLog(@"%s", __FUNCTION__);
}


/**
 *  更新左上角未读消息数
 */
- (void)notifyUpdateUnreadMessageCount {
  __weak typeof(&*self) __weakself = self;
  int count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
    @(ConversationType_PRIVATE),
    @(ConversationType_DISCUSSION),
    @(ConversationType_APPSERVICE),
    @(ConversationType_PUBLICSERVICE),
    @(ConversationType_GROUP)
  ]];
  dispatch_async(dispatch_get_main_queue(), ^{
      NSString *backString = nil;
    if (count > 0 && count < 1000) {
      backString = [NSString stringWithFormat:@"返回(%d)", count];
    } else if (count >= 1000) {
      backString = @"返回(...)";
    } else {
      backString = @"返回";
    }
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 6, 67, 23);
    UIImageView *backImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigator_btn_back"]];
    backImg.frame = CGRectMake(-10, 0, 22, 22);
    [backBtn addSubview:backImg];
    UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 65, 22)];
    backText.text = backString;//NSLocalizedStringFromTable(@"Back", @"RongCloudKit", nil);
    backText.font = [UIFont systemFontOfSize:15];
    [backText setBackgroundColor:[UIColor clearColor]];
    [backText setTextColor:[UIColor whiteColor]];
    [backBtn addSubview:backText];
    [backBtn addTarget:__weakself action:@selector(leftBarButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [__weakself.navigationItem setLeftBarButtonItem:leftButton];
  });
}

- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage
{
    //保存图片
    UIImage *image = newImage;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

//- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag{
//    [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
//    switch (tag) {
//        case 101: {
//            //这里加你自己的事件处理
//        } break;
//        default:
//            break;
//    }
//}

@end
