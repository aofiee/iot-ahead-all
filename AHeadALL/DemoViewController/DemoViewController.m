//
//  DemoViewController.m
//  AHeadALL
//
//  Created by SkullTree on 5/23/2560 BE.
//  Copyright © 2560 SkullTree. All rights reserved.
//

#import "DemoViewController.h"
#import <GCDAsyncSocket.h>

#define HOST @"192.168.2.45"
#define PORT 20000
@interface DemoViewController () <GCDAsyncSocketDelegate>
{
    IBOutlet UITextField * ipSocket;
    IBOutlet UISwitch * led1,* led2,* led3,* led4;
    IBOutlet UISlider * dimmer;
    IBOutlet UIButton * connectBtn, * onOffAllBtn;
    BOOL isConnected;
}
@property(strong)  GCDAsyncSocket *socket;
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(IBAction)dimmerControl:(id)sender
{
    UISlider * tmp = (UISlider*)sender;
    if([led4 isOn]){
        int i = (int)ceilf(tmp.value);
        NSLog(@"%@", [NSString stringWithFormat:@"*1*%d*21##",i]);
        [self sendMessageAction:[NSString stringWithFormat:@"*1*%d*21##",i]];
    }
    
    
}
-(IBAction)ledSwitchOnOff:(id)sender
{
    UISwitch * tmp = (UISwitch*)sender;
    switch (tmp.tag) {
        case 0:
            if([tmp isOn]){
                [self sendMessageAction:@"*1*1*11##"];
            }else{
                [self sendMessageAction:@"*1*0*11##"];
            }
            break;
        case 1:
            if([tmp isOn]){
                [self sendMessageAction:@"*1*1*12##"];
            }else{
                [self sendMessageAction:@"*1*0*12##"];
            }
            break;
        case 2:
            if([tmp isOn]){
                [self sendMessageAction:@"*1*1*13##"];
            }else{
                [self sendMessageAction:@"*1*0*13##"];
            }
            break;
        case 3:
            if([tmp isOn]){
                [self sendMessageAction:@"*1*1*21##"];
                dimmer.value = 1.0;
                dimmer.enabled = YES;
            }else{
                [self sendMessageAction:@"*1*0*21##"];
                dimmer.value = 1.0;
                dimmer.enabled = NO;
            }
            //เบาแสง 1-9
            break;
    }
}
-(void)setupSocket
{
    self.socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
    if(![_socket connectToHost:HOST onPort:PORT error:&err])
    {
        NSLog(@"error %@",err.description);
        isConnected = NO;
    }else
    {
        NSLog(@"ok");
    }
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    isConnected = YES;
    [connectBtn setTitle:@"Connected" forState:UIControlStateNormal];
    NSLog(@"Connected to:%@",host);
    [self sendMessageAction:@"*99*0##"];
    [_socket readDataWithTimeout:-1 tag:0];
    led1.enabled = YES;
    led2.enabled = YES;
    led3.enabled = YES;
    led4.enabled = YES;
    onOffAllBtn.enabled = YES;
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *newMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@%@",sock.connectedHost,newMessage);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    isConnected = NO;
    [connectBtn setTitle:@"Disconnect" forState:UIControlStateNormal];    
    NSLog(@"error %@", err.localizedDescription);
    led1.enabled = NO;
    led2.enabled = NO;
    led3.enabled = NO;
    led4.enabled = NO;
    onOffAllBtn.enabled = NO;
    dimmer.enabled = NO;
}

- (void)sendMessageAction:(NSString*)command {
    [_socket writeData:[command dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    NSLog(@"Send:%@",command);
    [_socket readDataWithTimeout:-1 tag:0];
}
//Open the port
//Connected to:192.168.2.45
//192.168.2.45*#*1##
//Send:*99*0##
//192.168.2.45*#*1##
//Send:*1*1*0##
//192.168.2.45*#*1##
//Send:*1*0*0##
//192.168.2.45*#*1##
-(IBAction)onOffAllBtnClicked:(id)sender
{
    if([onOffAllBtn.titleLabel.text isEqualToString:@"เปิดไฟทั้งหมด"]){
        [self sendMessageAction:@"*1*1*0##"];
        led1.enabled = YES;
        led2.enabled = YES;
        led3.enabled = YES;
        led4.enabled = YES;
        onOffAllBtn.enabled = YES;
        dimmer.enabled = YES;
        led1.on = YES;
        led2.on = YES;
        led3.on = YES;
        led4.on = YES;
        [onOffAllBtn setTitle:@"ปิดไฟทั้งหมด" forState:UIControlStateNormal];
    }else{
        [self sendMessageAction:@"*1*0*0##"];
        led1.enabled = NO;
        led2.enabled = NO;
        led3.enabled = NO;
        led4.enabled = NO;
        onOffAllBtn.enabled = NO;
        dimmer.enabled = NO;
        dimmer.value = 1.0;
        
        led1.on = NO;
        led2.on = NO;
        led3.on = NO;
        led4.on = NO;
        [onOffAllBtn setTitle:@"เปิดไฟทั้งหมด" forState:UIControlStateNormal];
    }
}
-(IBAction)connectBtnClicked:(id)sender
{
    [self setupSocket];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
