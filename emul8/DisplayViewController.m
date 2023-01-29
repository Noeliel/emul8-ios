// SPDX-FileCopyrightText: 2016 Noeliel
//
// SPDX-License-Identifier: LGPL-2.0-only

#import <UIKit/UIKit.h>
#import "C8DisplayView.h"

#if (TARGET_OS_SIMULATOR)
#define BASE_DIR @"/Users/User/Desktop"
#define ROM_DIR @"roms"
#else
#define BASE_DIR NSHomeDirectory()
#define ROM_DIR @"Documents/chip8"
#endif

@interface DisplayViewController : UIViewController <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate> {
    IBOutlet C8DisplayView *_display;
    IBOutlet UILongPressGestureRecognizer *_recog1;
    IBOutlet UILongPressGestureRecognizer *_recog2;
    IBOutlet UITableView *_romListView;
    IBOutlet UIView *_emuContainer;
}
- (void)refreshDisplay;
@end

static DisplayViewController *hacky_reference;

@implementation DisplayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    hacky_reference = self;
    [_display linkFramebuffer:display];
    
    /*
    dispatch_queue_t emuQueue = dispatch_queue_create("emuqueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(emuQueue, ^{
        run("/User/BRIX");
    });
     */
    
    // [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:@"BRIX"].UTF8String
    
    //pthread_t thread = 0;
    //pthread_create(&thread, NULL, run, [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:@"BRIX"].UTF8String);
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)refreshDisplay
{
    [_display setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)handleTap:(UILongPressGestureRecognizer *)sender
{
    if (sender == _recog1)
    {
        if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged)
            set_key_state(0x4, 1);
        else
            set_key_state(0x4, 0);
    }
    else if (sender == _recog2)
    {
        if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged)
            set_key_state(0x6, 1);
        else
            set_key_state(0x6, 0);
    }
}

- (NSArray *)romList
{
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[BASE_DIR stringByAppendingPathComponent:ROM_DIR] error:nil];
    
    NSMutableArray *romList = [@[] mutableCopy];
    
    BOOL isDir = YES;
    
    for (int i = 0; i < fileList.count; i++)
    {
        [[NSFileManager defaultManager] fileExistsAtPath:[[BASE_DIR stringByAppendingPathComponent:ROM_DIR] stringByAppendingPathComponent:fileList[i]] isDirectory:&isDir];
        if (!isDir)
            [romList addObject:fileList[i]];
    }
    
    return [romList autorelease];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self romList].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"romCell"] autorelease];
    
    cell.textLabel.text = [self romList][indexPath.row];
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSString *romPath = [[BASE_DIR stringByAppendingPathComponent:ROM_DIR] stringByAppendingPathComponent:[self romList][indexPath.row]];
    
    [UIView transitionWithView:[self view] duration:0.5 options:(UIViewAnimationOptionTransitionFlipFromRight) animations:^{
        
        _romListView.hidden = YES;
        _emuContainer.hidden = NO;
        
    } completion:^(BOOL finished) {
        
        dispatch_queue_t emuQueue = dispatch_queue_create("emuqueue", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(emuQueue, ^{
            run(romPath.UTF8String);
        });
    }];
}

@end

void redraw()
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [hacky_reference refreshDisplay];
    });
}