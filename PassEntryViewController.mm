/*
 * Copyright (C) 2012  Brian A. Mattern <rephorm@rephorm.com>.
 * Copyright (C) 2015  David Beitey <david@davidjb.com>.
 * All Rights Reserved.
 * This file is licensed under the GPLv2+.
 * Please see COPYING for more information
 */
#import "PassEntryViewController.h"
#import "PassEntry.h"
#import "Valet/Valet.h"

@interface PassEntryViewController()
@property (nonatomic,retain) VALSecureEnclaveValet *keychain;
@property (nonatomic,retain) NSString *keychain_key;
- (void)copyName;
- (void)showAlertWithMessage:(NSString *)message alertTitle:(NSString *)title;
- (void)decryptGpgWithPasswordOnly:(BOOL)passwordOnly copyToPasteboard:(BOOL)pasteboard showInAlert:(BOOL)showAlert;
- (void)requestGpgPassphrase:(BOOL)passwordOnly entryTitle:(NSString *)title copyToPasteboard:(BOOL)pasteboard showInAlert:(BOOL)showAlert;
@end


@implementation PassEntryViewController
@synthesize entry;

- (void)viewDidLoad {
  [super viewDidLoad];
  // self.title = NSLocalizedString(@"Passwords", @"Password title");

  self.keychain = [[VALSecureEnclaveValet alloc] initWithIdentifier:@"Pass"];
  self.useTouchID = [[self.keychain class] supportsSecureEnclaveKeychainItems];
  self.pasteboard = [UIPasteboard generalPasteboard];

  // TODO Further work required for non-TouchID devices
  if (self.useTouchID) {
    // Local TouchID authentication
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
  return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"EntryDetailCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
  }

  switch(indexPath.row) {
    case 0:
      cell.textLabel.text = @"Name";
      cell.detailTextLabel.text = self.entry.name;
      break;
    case 1:
      cell.textLabel.text = @"Password";
      cell.detailTextLabel.text = @"Tap to show";
      break;
    case 2:
      cell.textLabel.text = @"Password";
      cell.detailTextLabel.text = @"Tap to copy";
      break;
    case 3:
      cell.textLabel.text = @"Full text";
      cell.detailTextLabel.text = @"Tap to show";
      break;
    case 4:
      cell.textLabel.text = @"Full text";
      cell.detailTextLabel.text = @"Tap to copy";
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
      // Password, first line only, alert
      [self decryptGpgWithPasswordOnly:YES copyToPasteboard:NO showInAlert:YES];
      break;
    case 2:
      // Password, first line only, pasteboard
      [self decryptGpgWithPasswordOnly:YES copyToPasteboard:YES showInAlert:NO];
      break;
    case 3:
      // Full text, all lines, alert
      [self decryptGpgWithPasswordOnly:NO copyToPasteboard:NO showInAlert:YES];
      break;
    case 4:
      // Full text, all lines, passboard
      [self decryptGpgWithPasswordOnly:NO copyToPasteboard:YES showInAlert:NO];
      break;
    default:
      break;
  }
}

- (void)copyToPasteboard:(NSString *)string {
  self.pasteboard.string = string;
}

- (void)showAlertWithMessage:(NSString *)message alertTitle:(NSString *)title {
  UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
  [alert addAction:defaultAction];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)copyName {
  [self copyToPasteboard:self.entry.name];
}

- (void) performPasswordAction:(NSString *)password entryTitle:(NSString *)title copyToPasteboard:(BOOL)pasteboard showInAlert:(BOOL)showAlert {
  if (pasteboard) {
    [self copyToPasteboard:password];
  }
  if (showAlert) {
    [self showAlertWithMessage:password alertTitle:title];
  }
}

- (void)decryptGpgWithPasswordOnly:(BOOL)passwordOnly copyToPasteboard:(BOOL)pasteboard showInAlert:(BOOL)showAlert {
  BOOL result = NO;
  NSString *password; // Decryped password
  NSString *keychain_passphrase; // iOS keychain passphrase

  if (self.useTouchID) {
    keychain_passphrase = [self.keychain stringForKey:self.keychain_key userPrompt:@"Unlock your keychain to access this password."];
  } else {
    keychain_passphrase = [self.keychain stringForKey:self.keychain_key];
  }

  if (keychain_passphrase) {
    password = [self.entry passWithPassphrase:keychain_passphrase passwordOnly:passwordOnly];
    if (password) {
      [self performPasswordAction:password entryTitle:self.entry.name copyToPasteboard:pasteboard showInAlert:showAlert];
      result = YES;
    }
  }

  if (!result) {
    // GPG decryption failed with stored keychain passphrase or no keychain passphrase present
    // so try requesting the passphase
    [self requestGpgPassphrase:passwordOnly entryTitle:self.entry.name copyToPasteboard:pasteboard showInAlert:showAlert];
  }
}

- (void)requestGpgPassphrase:(BOOL)passwordOnly entryTitle:(NSString *)title copyToPasteboard:(BOOL)pasteboard showInAlert:(BOOL)showAlert {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Passphrase" message:@"Enter passphrase for your GPG key" preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
  [alert addAction:cancelAction];

  UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    NSString *keychain_passphrase = ((UITextField *)[alert.textFields objectAtIndex:0]).text;
    // If the passphrase decrypts the entry, save it
    NSString *password = [self.entry passWithPassphrase:keychain_passphrase passwordOnly:YES];
    if (password) {
        if (self.useTouchID) {
            [self.keychain setString:keychain_passphrase forKey:self.keychain_key]; //userPrompt:@"Securely store your GPG passphrase"];
        } else {
            [self.keychain setString:keychain_passphrase forKey:self.keychain_key];
        }

        [self performPasswordAction:password entryTitle:title copyToPasteboard:pasteboard showInAlert:showAlert];

    } else {
        UIAlertController *invalidAlert = [UIAlertController alertControllerWithTitle:@"Passphrase" message:@"Passphrase invalid" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [invalidAlert addAction:okayAction];
        [self presentViewController:invalidAlert animated:YES completion:nil];
    }
  }];
  [alert addAction:defaultAction];

  [alert addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
    textField.placeholder = @"Passphrase";
    textField.secureTextEntry = YES;
  }];

  [self presentViewController:alert animated:YES completion:nil];
}

@end
