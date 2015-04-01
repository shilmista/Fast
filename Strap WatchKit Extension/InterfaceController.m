//
//  InterfaceController.m
//  Strap WatchKit Extension
//
//  Created by Tony Cheng on 3/31/15.
//  Copyright (c) 2015 Tony Cheng. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()
@property (nonatomic, weak) IBOutlet WKInterfaceButton *button;
@property (nonatomic) BOOL isGeorge;

- (IBAction)buttonDidTap:(WKInterfaceButton *)sender;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    self.isGeorge = YES;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - action
- (IBAction)buttonDidTap:(WKInterfaceButton *)sender {
    if (self.isGeorge) {
        [self.button setTitle:@"Hi Kwame!"];
    }
    else {
        [self.button setTitle:@"Hi George!"];
    }
    self.isGeorge = !self.isGeorge;
}

@end



