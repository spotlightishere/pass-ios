/*
 * Copyright (C) 2012  Brian A. Mattern <rephorm@rephorm.com>.
 * Copyright (C) 2015  David Beitey <david@davidjb.com>.
 * All Rights Reserved.
 * This file is licensed under the GPLv2+.
 * Please see COPYING for more information
 */
@interface PassEntry : NSObject {
  NSString *name;
}

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *path;
@property (nonatomic,assign) BOOL is_dir;
@property (nonatomic,readonly) NSString *pass;

- (NSString *)passWithPassphrase:(NSString *)passphrase passwordOnly:(BOOL)passwordOnly;

@end
