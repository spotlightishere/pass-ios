/*
 * Copyright (C) 2012  Brian A. Mattern <rephorm@rephorm.com>.
 * Copyright (C) 2015  David Beitey <david@davidjb.com>.
 * All Rights Reserved.
 * This file is licensed under the GPLv2+.
 * Please see COPYING for more information
 */
#import <UIKit/UIKit.h>
@class PassEntry;

@interface PassEntryViewController: UITableViewController {
}

@property(nonatomic,retain) PassEntry *entry;
@property(nonatomic,retain) UIPasteboard *pasteboard;
@property(nonatomic,assign) BOOL useTouchID;

@end
