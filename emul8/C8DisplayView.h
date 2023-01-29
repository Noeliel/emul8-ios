// SPDX-FileCopyrightText: 2016 Noeliel
//
// SPDX-License-Identifier: LGPL-2.0-only

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "emu/env.h"

@interface C8DisplayView : UIView {
    byte *matrix;
}
- (void)linkFramebuffer:(byte *)buffer;
@end