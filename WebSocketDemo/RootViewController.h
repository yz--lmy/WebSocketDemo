//
//  RootViewController.h
//  WebSocketDemo
//
//  Created by sjkx123456 on 15/8/17.
//  Copyright (c) 2015年 sjkx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"

@interface RootViewController : UIViewController<SRWebSocketDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    SRWebSocket * _webSocket;
    UITableView * _msgTabView;
}
@property(nonatomic,strong)NSMutableArray * messagesAry;
@end

@interface Message : NSObject
{
    
}
@property (nonatomic, copy, readonly) NSString *message;
@property (nonatomic, readonly)  BOOL fromMe;

- (id)initWithMessage:(NSString *)message fromMe:(BOOL)fromMe;

@end