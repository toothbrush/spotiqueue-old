//
//  DNDropDownButton.m
//  Spotiqueue
//
//  Created by Paul van der Walt on 13/03/13.
//  Copyright (c) 2013 denknerd.org. All rights reserved.
//

#import "DNDropDownButton.h"

@implementation DNDropDownButton

@synthesize menu;

- (void)popupMenu  {

    CGEventRef cgEvent = CGEventCreateMouseEvent(NULL,
                                                 kCGEventLeftMouseDown,
                                                 [self convertPoint:[NSEvent mouseLocation]
                                                             toView:self.superview],
                                                 kCGMouseButtonLeft);
    NSEvent *theEvent = [NSEvent eventWithCGEvent:cgEvent];

    [NSMenu popUpContextMenu:menu withEvent:theEvent forView:self.superview];

    
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    DLog(@"button init");
    if (self) {
        // Initialization code here.
              
    }
    
    return self;
}

- (void)awakeFromNib {
    [self setTarget:self];
    [self setAction:@selector(popupMenu)];

}

@end
