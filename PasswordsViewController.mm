/*
 * Copyright (C) 2012  Brian A. Mattern <rephorm@rephorm.com>.
 * Copyright (C) 2015  David Beitey <david@davidjb.com>.
 * All Rights Reserved.
 * This file is licensed under the GPLv2+.
 * Please see COPYING for more information
 */
#import <UIKit/UIKit.h>
#import "PasswordsViewController.h"
#import "PassDataController.h"
#import "PassEntry.h"
#import "PassEntryViewController.h"
#import "Valet/Valet.h"

@implementation PasswordsViewController

@synthesize entries;

- (void)viewDidLoad {
  [super viewDidLoad];
  if (self.title == nil) {
    self.title = NSLocalizedString(@"Passwords", @"Password title");
  }

  UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear Keychain" style:UIBarButtonItemStylePlain target:self action:@selector(clearPassphrase) ];
  self.navigationItem.rightBarButtonItem = clearButton;
}

- (void)clearPassphrase {
  // TODO Refactor into shared function
  VALSecureEnclaveValet *keychain = [[VALSecureEnclaveValet alloc] initWithIdentifier:@"Pass"];
  [keychain removeObjectForKey:@"gpg-passphrase-touchid"];

  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Keychain cleared" message:@"Passphrase has been removed from the keychain" preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
  [alert addAction:defaultAction];
  [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  return [self.entries numEntries];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"EntryCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }

  PassEntry *entry = [self.entries entryAtIndex:indexPath.row];

  cell.textLabel.text = entry.name;
  if (entry.is_dir)
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  else
    cell.accessoryType = UITableViewCellAccessoryNone;

  return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  // Return unique, capitalised first letters of entries
  NSMutableArray *firstLetters = [[NSMutableArray alloc] init];
  [firstLetters addObject:UITableViewIndexSearch];
  for (int i = 0; i < [self.entries numEntries]; i++) {
    NSString *letterString = [[[self.entries entryAtIndex:i].name substringToIndex:1] uppercaseString];
    if (![firstLetters containsObject:letterString]) {
      [firstLetters addObject:letterString];
    }
  }
  return firstLetters;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
  for (int i = 0; i < [self.entries numEntries]; i++) {
    NSString *letterString = [[[self.entries entryAtIndex:i].name substringToIndex:1] uppercaseString];
    if ([letterString isEqualToString:title]) {
      [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
      break;
    }
  }
  return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];

  PassEntry *entry = [self.entries entryAtIndex:indexPath.row];

  if (entry.is_dir) {
    // push subdir view onto stack
    PasswordsViewController *subviewController = [[PasswordsViewController alloc] init];
    subviewController.entries = [[PassDataController alloc] initWithPath:entry.path];
    subviewController.title = entry.name;
    [[self navigationController] pushViewController:subviewController animated:YES];
  } else {
    PassEntryViewController *detailController = [[PassEntryViewController alloc] init];
    detailController.entry = entry;
    [[self navigationController] pushViewController:detailController animated:YES];
  }
}

@end

