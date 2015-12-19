/*
 * Copyright (C) 2012  Brian A. Mattern <rephorm@rephorm.com>.
 * Copyright (C) 2015  David Beitey <david@davidjb.com>.
 * All Rights Reserved.
 * This file is licensed under the GPLv2+.
 * Please see COPYING for more information
 */
#import "PasswordsViewController.h"
#import "PassDataController.h"

#define PASS_DIR @"/var/mobile/.password-store"

@interface passwordstoreApplication: UIApplication <UIApplicationDelegate>
{
    UIWindow *_window;
    PasswordsViewController *_viewController;
    PassDataController *_entries;
}
@property (nonatomic, retain) UIWindow *window;
@end

@implementation passwordstoreApplication
@synthesize window = _window;
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _entries = [[PassDataController alloc] initWithPath:PASS_DIR];

    _viewController = [[PasswordsViewController alloc] init];
    _viewController.entries = _entries;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_viewController];

    // Ensures app is able to change orientation; subviews don't work
    _window.rootViewController = navigationController;
    [_window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // remove passphrase on app exit for now
    //  NSLog(@"App will terminate");
    //  [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:@"passphrase"];
}

@end

// vim:ft=objc
