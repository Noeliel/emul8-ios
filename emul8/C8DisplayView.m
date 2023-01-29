// SPDX-FileCopyrightText: 2016 Noeliel
//
// SPDX-License-Identifier: LGPL-2.0-only

#import "C8DisplayView.h"

@implementation C8DisplayView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    if (matrix == NULL)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    for (int y = 0; y < DISPLAY_HEIGHT; y++)
    {
        for (int x = 0; x < DISPLAY_WIDTH; x++)
        {
            if (matrix[x + (DISPLAY_WIDTH * y)] == 1)
                CGContextFillRect(context, CGRectMake(x * 8, y * 8, 8, 8));
        }
    }
}

- (void)linkFramebuffer:(byte *)buffer
{
    matrix = buffer;
}

@end