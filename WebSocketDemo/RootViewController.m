//
//  RootViewController.m
//  WebSocketDemo
//
//  Created by sjkx123456 on 15/8/17.
//  Copyright (c) 2015年 sjkx. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0f)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    _messagesAry = [NSMutableArray array];
    self.navigationItem.title = @"打开连接...";
    UIBarButtonItem * leftBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"Ping" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarBtnClick:)];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    UITextField * tf = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30.0f)];
    tf.backgroundColor = [UIColor orangeColor];
    tf.delegate = self;
    tf.keyboardType = UIKeyboardAppearanceDefault;
    tf.returnKeyType = UIReturnKeyDone;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    
    _msgTabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height)];
    _msgTabView.backgroundColor = [UIColor whiteColor];
    _msgTabView.dataSource = self;
    _msgTabView.delegate = self;
    _msgTabView.tableFooterView = tf;
    _msgTabView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _msgTabView.separatorColor = [UIColor grayColor];
    [self.view addSubview:_msgTabView];
    
    [self reconnect];
    
}

-(void)reconnect
{
    _webSocket.delegate = nil;
    [_webSocket close];
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://localhost:9000/chat"]]];
    _webSocket.delegate = self;
    [_webSocket open];
}

-(void)leftBarBtnClick:(UIBarButtonItem *)item
{
    [_webSocket sendPing:[@"ping" dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark  SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"Received \"%@\"", message);
    [_messagesAry addObject:[[Message alloc] initWithMessage:message fromMe:NO]];
    [_msgTabView reloadData];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Websocket Connected");
    self.navigationItem.title = @"已连接!";
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"Websocket Failed With Error %@", error);
    self.navigationItem.title = @"Connection Failed! (see logs)";
    _webSocket = nil;

}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"WebSocket closed");
    self.navigationItem.title = @"连接已关闭!";
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    NSLog(@"Websocket received pong %@",[[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding]);
}


#pragma mark UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messagesAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"cellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    Message * msg = [_messagesAry objectAtIndex:indexPath.row];
    cell.backgroundColor = msg.fromMe ? [UIColor colorWithRed:247.0f/255.0f green:198.0f/255.0f blue:69.0f/255.0f alpha:1.0f] : [UIColor colorWithRed:197.0f/255.0f green:255.0f/255.0f blue:58.0f/255.0f alpha:1.0f];
    cell.textLabel.text = [[_messagesAry objectAtIndex:indexPath.row] message];
    
    
    return cell;

}


#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [_webSocket send:textField.text];
    [_messagesAry addObject:[[Message alloc] initWithMessage:textField.text fromMe:YES]];
    [_msgTabView reloadData];
    textField.text = @"";
    return YES;
}

-(void)dealloc
{
    [_webSocket close];
    _webSocket = nil;
    _messagesAry = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

@implementation Message

- (id)initWithMessage:(NSString *)message fromMe:(BOOL)fromMe;
{
    self = [super init];
    if (self) {
        _fromMe = fromMe;
        _message = message;
    }
    
    return self;
}


@end
