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
@property (nonatomic,retain) A0SimpleKeychain *keychain;
@property (nonatomic,retain) NSString *keychain_key;
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)requestPassphrase;
- (void)copyName;
- (BOOL)copyPass:(BOOL)passwordOnly;
@end


@implementation PassEntryViewController
@synthesize entry;

- (void)viewDidLoad {
  [super viewDidLoad];
//  self.title = NSLocalizedString(@"Passwords", @"Password title");
  self.keychain = [A0SimpleKeychain keychain];
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
  return 3;
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
      // Try and decrypt password; if that fails, request it
      if (![self copyPass]) {
        [self requestPassphrase];
      }
      break;
    case 2:
      // Full text, all lines
      if (![self copyPass:NO]) {
        [self requestPassphrase];
      }
      break;
    default:
      break;
  }
}

- (void)copyToPasteboard:(NSString *)string {
  [UIPasteboard generalPasteboard].string = string;
}

- (void)copyName {
  [self copyToPasteboard:self.entry.name];
}

- (BOOL)copyPass {
  return [self copyPass:YES];
}

- (BOOL)copyPass:(BOOL)passwordOnly {
  NSString *passphrase = [self.keychain stringForKey:self.keychain_key promptMessage:@"Unlock your keychain to access this password."];
  NSString *pass;

  if (passphrase) {
    pass = [self.entry passWithPassphrase:passphrase passwordOnly:passwordOnly];
    if (pass) {
      [self copyToPasteboard:pass];
      return YES;
    } else {
      [self.keychain deleteEntryForKey:self.keychain_key];
      [self debugAlert:@"Removed incorrect GPG passphrase from keychain."];
      return NO;
    }
  } else {
      return NO;
  }
}

- (void)requestPassphrase {
    // Deprecated in iOS 8, see https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIAlertView_Class/index.html#//apple_ref/occ/cl/UIAlertView
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passphrase" message:@"Enter passphrase for your GPG key" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
  alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
  [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *passphrase;
  NSString *password;
  if (buttonIndex == 1) {
    passphrase = [alertView textFieldAtIndex:0].text;

    // If the passphrase decrypts the entry, save it
    password = [self.entry passWithPassphrase:passphrase passwordOnly:YES];
    if (password) {
      [self.keychain setString:passphrase forKey:self.keychain_key promptMessage:@"Securely store your GPG passphrase"];
      [self copyToPasteboard:password];
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passphrase" message:@"Passphrase invalid" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
      [alert show];
    }
  }
}

//Example: [self debugAlert:@"Pass was nil; would delete here"];
- (void)debugAlert:(NSString *)alertMessage {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:alertMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
  [alert show];
}

@end
