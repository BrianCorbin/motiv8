//
//  CAsettingsTableViewController.m
//  motiv8
//
//  Created by Brian Corbin on 6/11/14.
//  Copyright (c) 2014 Caramel Apps. All rights reserved.
//

#import "CAsettingsTableViewController.h"

@interface CAsettingsTableViewController ()

- (IBAction)doneAction:(UIBarButtonItem *)sender;
- (IBAction)timeIntervalChangedAction:(UIDatePicker *)sender;
@property (weak, nonatomic) IBOutlet UIDatePicker *timeIntervalPicker;
@property (weak, nonatomic) IBOutlet UILabel *timeIntervalLbl;
@property (weak, nonatomic) IBOutlet UITableViewCell *datePickerCell;

@property BOOL pickerIsShowing;


@end

@implementation CAsettingsTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger timeIntervalInt = [[NSUserDefaults standardUserDefaults] integerForKey:@"TimeInterval"];
    NSString* timeIntervalStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"TimeIntervalStr"];
    
    _timeIntervalLbl.text = timeIntervalStr;
    _timeIntervalPicker.hidden = YES;
    _timeIntervalPicker.countDownDuration = (int)timeIntervalInt;
    _pickerIsShowing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        if(_pickerIsShowing)
            [self hideTimeIntervalPickerCell];
        else
            [self showTimeIntervalPickerCell];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    if(indexPath.row == 1)
        height = self.pickerIsShowing ? 164.0 : 0.0f;
    return height;
}

-(void)hideTimeIntervalPickerCell
{
    _pickerIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.timeIntervalPicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.timeIntervalPicker.hidden = YES;
                     }];
}

-(void)showTimeIntervalPickerCell
{
    self.pickerIsShowing = YES;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.timeIntervalPicker.hidden = NO;
    self.timeIntervalPicker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.timeIntervalPicker.alpha = 1.0f;
        
    }];
}

- (IBAction)doneAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)timeIntervalChangedAction:(UIDatePicker *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:(int)_timeIntervalPicker.countDownDuration forKey:@"TimeInterval"];
    int seconds = (int)_timeIntervalPicker.countDownDuration;
    int hours = seconds/3600;
    seconds -= hours*3600;
    int minutes = 0;
    if(seconds != 0)
        minutes = seconds/60;
    self.timeIntervalLbl.text = [NSString stringWithFormat:@"%dh %dm", hours, minutes];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%dh %dm", hours, minutes] forKey:@"TimeIntervalStr"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
