//
//  ThirdInterfaceController.m
//  Strap
//
//  Created by Tony Cheng on 3/31/15.
//  Copyright (c) 2015 Tony Cheng. All rights reserved.
//

#import "ThirdInterfaceController.h"


@interface ThirdInterfaceController()
- (IBAction)dismissButtonPressed:(id)sender;
@end


@implementation ThirdInterfaceController

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

#pragma mark - IBAction
- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissController];
}

@end



