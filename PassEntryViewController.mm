/*
 * Copyright (C) 2012  Brian A. Mattern <rephorm@rephorm.com>.
 * All Rights Reserved.
 * This file is licensed under the GPLv2+.
 * Please see COPYING for more information
 */
#import "PassEntryViewController.h"
#import "PassEntry.h"
#import "A0SimpleKeychain.h"

@interface PassEntryViewController()
@property (nonatomic,retain) NSString *passphrase;
@property (nonatomic,retain) A0SimpleKeychain *keychain;
@property (nonatomic,retain) NSString *keychain_key;
@property (nonatomic,assign) BOOL useTouchID;
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)requestPassphrase;
- (void)copyName;
- (BOOL)copyPass;
@end


@implementation PassEntryViewController
@synthesize entry;
@synthesize passphrase;
@synthesize keychain;
@synthesize keychain_key;

- (void)viewDidLoad {
  [super viewDidLoad];
//  self.title = NSLocalizedString(@"Passwords", @"Password title");
  // Deleting the old passphrase
  // TODO Add a clear keychain button on the home screen
  //[self.keychain deleteEntryForKey:@"passphrase"];
  //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passphrase removed" message:@"Old passphrase was removed from keychain." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
  //[alert show];
  //return;

  self.useTouchID = YES; // Make this optional for non iOS 8.
  if (self.useTouchID) {
    // Local TouchID authentication
    self.keychain.useAccessControl = YES;
    self.keychain.defaultAccessiblity = A0SimpleKeychainItemAccessibleWhenPasscodeSetThisDeviceOnly;
    self.keychain_key = @"gpg-passphrase-touchid";
  } else {
    self.keychain_key = @"passphrase";
  }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"EntryDetailCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
  }

  switch(indexPath.row) {
    case 0:
      cell.textLabel.text = @"Name";
      cell.detailTextLabel.text = self.entry.name;
      break;
    case 1:
      cell.textLabel.text = @"Password";
      cell.detailTextLabel.text = @"********";
      break;
    case 2:
      cell.textLabel.text = @"Full text";
      cell.detailTextLabel.text = @"********";
      break;
    default:
      break;
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  switch(indexPath.row) {
    case 0:
      // Name
      [self copyName];
      break;
    case 1:
      // Password, first line only
      if (self.useTouchID) {
        self.passphrase = [self.keychain stringForKey:self.keychain_key promptMessage:@"Do you wish to copy this password?"];
      } else {
        self.passphrase = [self.keychain stringForKey:self.keychain_key];
      }
      if (self.passphrase == nil) {
        [self requestPassphrase];
      } else {
        [self copyPass];
      }
      break;
    case 2:
      // Full text, all lines
      // TODO Add implementation
      break;
    default:
      break;
  }
}

- (void)copyName {
  [UIPasteboard generalPasteboard].string = self.entry.name;
}

- (BOOL)copyPass {
  NSString *pass = [self.entry passWithPassphrase:self.passphrase];
  if (pass == nil) {
    [self.keychain deleteEntryForKey:self.keychain_key];
    return NO;
  } else {
    [UIPasteboard generalPasteboard].string = pass;
    return YES;
  }
}

- (void)requestPassphrase {
    // Deprecated in iOS 8, see https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIAlertView_Class/index.html#//apple_ref/occ/cl/UIAlertView
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passphrase" message:@"Enter passphrase for your GPG key" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
  alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
  [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1) {
    self.passphrase = [alertView textFieldAtIndex:0].text;
    [self.keychain setString:self.passphrase forKey:self.keychain_key promptMessage:@"Securely store your passphrase?"];
    if (![self copyPass]) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passphrase" message:@"Passphrase invalid" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
      [alert show];
    }
  }
}

@end
