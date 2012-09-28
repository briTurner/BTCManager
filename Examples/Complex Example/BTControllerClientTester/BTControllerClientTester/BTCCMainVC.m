//
//  BTCCMainVC.m
//  BTControllerClientTester
//
//  Created by Brian Turner on 7/11/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BTCCMainVC.h"
#import "BTCCConnectedVC.h"


@interface BTCCMainVC ()

@end

@implementation BTCCMainVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        manager = [BTCManager sharedManager];
        [manager configureManagerAsControllerWithSessionID:@"btsSessionID" serverAvailableBlock:^(NSString *serverID, NSString *serverDisplayName) {
            BOOL alreadyContainsServer = NO;
            for (NSDictionary *server in servers) {
                if ([[server valueForKey:@"serverID"] isEqualToString:serverID]) {
                    alreadyContainsServer = YES;
                    break;
                }
            }
            
            if (!alreadyContainsServer) {
                
                NSMutableDictionary *server = [NSMutableDictionary dictionary];
                [server setValue:serverID forKey:@"serverID"];
                [server setValue:serverDisplayName forKey:@"serverDisplayName"];
                [servers addObject:server];
                [tableView reloadData];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedToServer:) name:BTCManagerNotificationConnectedToServer object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectedFromServer::) name:BTCManagerNotificationDisconnectedFromServer object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverUnavailable:) name:BTCManagerNotificationServerUnavailable object:nil];
        
        servers = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    tableView = nil;
    displayNameTF = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)connect:(id)sender {
    [manager startSession];
}


#pragma mark - btcmanagerdelegate Methods

- (void)serverUnavailable:(NSNotification *)note {
    NSDictionary *dic = [note userInfo];
    NSString *serverID = [dic valueForKey:kBTCPeerID];
    
    NSDictionary *serverToRemove = nil;
    for (NSDictionary *server in servers) {
        if ([[server valueForKey:@"serverID"] isEqualToString:serverID]) {
            serverToRemove = server;
            break;
        }
    }
    if (serverToRemove)
        [servers removeObject:serverToRemove];
    [tableView reloadData];
}

- (void)connectedToPeer:(NSNotification *)note {
    NSDictionary *dic = [note userInfo];
    NSString *displayName = [dic valueForKey:kBTCPeerDisplayName];
    
    NSLog(@"peer connected %@", displayName);
}

- (void)connectedToServer:(NSNotification *)note {
    NSDictionary *dic = [note userInfo];
    NSString *serverID = [dic valueForKey:kBTCPeerID];
    
    BTCCConnectedVC *vc = [[BTCCConnectedVC alloc] initWithNibName:nil bundle:nil];
    [vc setConnectedServer:serverID];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)disconnectedFromServer:(NSNotification *)note {
    NSDictionary *dic = [note userInfo];
    NSString *serverID = [dic valueForKey:kBTCPeerID];
    
    for (int i = 0; i < [servers count]; i++) {
        NSDictionary *server = [servers objectAtIndex:i];
        if ([[server valueForKey:@"serverID"] isEqualToString:serverID]) {
            [server setValue:[NSNumber numberWithBool:NO] forKey:@"connected"];
            break;
        }
    }
    [tableView reloadData];
}


#pragma mark - UITableVIewStuff

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [servers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *server =  [servers objectAtIndex:[indexPath row]];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    [[cell textLabel] setText:[server valueForKey:@"serverDisplayName"]];
    
    if ([server valueForKey:@"connected"])
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *server = [servers objectAtIndex:[indexPath row]];
    [manager connectToServer:[server valueForKey:@"serverID"]];
}

@end
