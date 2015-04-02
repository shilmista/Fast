//
//  SecondPageInterfaceController.m
//  Strap
//
//  Created by Tony Cheng on 3/31/15.
//  Copyright (c) 2015 Tony Cheng. All rights reserved.
//

#import "SecondPageInterfaceController.h"
#import "InterfaceController.h"

@interface SecondPageInterfaceController()
- (IBAction)buttonTapped:(id)sender;
- (IBAction)toAppTapped:(id)sender;
@end


@implementation SecondPageInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Button
- (IBAction)buttonTapped:(id)sender {

}

- (IBAction)toAppTapped:(id)sender {
    [WKInterfaceController openParentApplication:nil reply:^(NSDictionary *replyInfo, NSError *error) {
    }];
}

@end



