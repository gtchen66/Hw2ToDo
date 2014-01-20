//
//  ToDoTableViewController.h
//  Hw2ToDo
//
//  Created by George Chen on 1/17/14.
//  Copyright (c) 2014 George Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToDoTableViewController : UITableViewController <UITextFieldDelegate>

- (IBAction)EditTable:(id)sender;
- (IBAction)AddEntryToTable:(id)sender;

@end
