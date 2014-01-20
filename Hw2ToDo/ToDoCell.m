//
//  ToDoCell.m
//  Hw2ToDo
//
//  Created by George Chen on 1/17/14.
//  Copyright (c) 2014 George Chen. All rights reserved.
//

#import "ToDoCell.h"

@implementation ToDoCell
- (IBAction)touchDownInToDoCell:(id)sender {
    NSLog(@"touch inside cell");
    
    // NSLog(@"object is %lu",(unsigned long)[sender indexOfObject:self]);
}
- (IBAction)doneEditing:(id)sender {
    NSLog(@"Editing has completed inside this cell");
    NSLog(@"Content of this cell was <%@>",self.taskTextField.text);
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSLog(@"inside initWithStyle in ToDoCell");
    }
    NSLog(@"inside initWithStyle in ToDoCell part 2");

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (BOOL) textFieldShouldReturn:(UITextField *)textField {
//    NSLog(@"inside textFieldShouldReturn in ToDoCell");
//    return YES;
//}

@end
