//
//  BTCCConnectedVC.m
//  BTControllerClientTester
//
//  Created by Brian Turner on 7/12/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BTCCConnectedVC.h"
#import "BTCButton.h"
#import "BTCJoyStickView.h"

@interface BTCCConnectedVC () {
    UITextField *textField;
}

@end

@implementation BTCCConnectedVC
@synthesize connectedServer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        manager = [BTCManager sharedManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    BTCButton *button = [[BTCButton alloc] initWithFrame:CGRectMake(10, 10, 100, 40)];
    [button setTag:1];
    [button setTitle:@"button 1" forState:UIControlStateNormal];
    [[self view] addSubview:button];
    
    BTCButton *button2 = [[BTCButton alloc] initWithFrame:CGRectMake(10, 60, 100, 40)];
    [button2 setTag:2];
    [[self view] addSubview:button2];
    
    BTCJoyStickView *js = [[BTCJoyStickView alloc] initWithFrame:CGRectMake(10, 150, 150, 150)];
    [js setTag:1];
    [[self view] addSubview:js];
    
    BTCJoyStickView *js2 = [[BTCJoyStickView alloc] initWithFrame:CGRectMake(160, 150, 150, 150)];
    [js2 setTag:2];
    [[self view] addSubview:js2];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, 180, 30)];
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    [[self view] addSubview:textField];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button3 setTitle:@"butotn" forState:UIControlStateNormal];
    [button3 setFrame:CGRectMake(120, 60, 100, 30)];
    [button3 addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:button3];
    // Do any additional setup after loading the view from its nib.
}

- (void)buttonPressed:(id)sender {
    [textField resignFirstResponder];
    NSString *someString = [textField text];
    NSData *data = [someString dataUsingEncoding:NSUTF8StringEncoding];
    [manager sendArbitraryData:data withIdentifier:1 reliably:NO toPeers:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [manager disconnect];
}

@end
