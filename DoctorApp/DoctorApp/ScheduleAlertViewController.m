//
//  ScheduleAlertViewController.m
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/18/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import "ScheduleAlertViewController.h"
#import "DataBaseManager.h"

NSString* CurrentdateFormat = @"yyyy-MM-dd HH:mm";

@interface ScheduleAlertViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITextField* dateTextField;
@property (nonatomic, strong) UIButton* currentlySelectedButton;
@property (nonatomic, strong) NSString* selectedTime;
@end

@implementation ScheduleAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dateTextField.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveSchedule:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm a";
    NSDate *date = [dateFormatter dateFromString:self.selectedTime];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *time24 = [dateFormatter stringFromDate:date];
    
    
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    NSDate* dateField = [dateFormatter dateFromString:self.dateTextField.text];
    
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSString* finalDate = [dateFormatter stringFromDate:dateField];
    
    
    NSString* formattedDate = [NSString stringWithFormat:@"%@ %@", finalDate, time24];
    
    
    
    [[DataBaseManager sharedInstance] addAppointmentWithDate:formattedDate];
    
    
    dateFormatter.dateFormat = CurrentdateFormat;
    
    NSDate* calendarDate = [dateFormatter dateFromString:formattedDate];
    
    [self addCalendarEvent:calendarDate];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)selectTime:(id)sender
{
    if (self.currentlySelectedButton)
    {
        [self.currentlySelectedButton setBackgroundColor:[self colorFromHexString:@"#8FC7E6"]];
    }
    self.currentlySelectedButton = (UIButton*)sender;
    
    [self.currentlySelectedButton setBackgroundColor:[UIColor grayColor]];
    
    self.selectedTime = self.currentlySelectedButton.titleLabel.text;
}

- (void)addCalendarEvent:(NSDate*)date
{
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = @"Doctor's Appointment";
        event.startDate = date; //today
        event.endDate = [event.startDate dateByAddingTimeInterval:60*60];  //set 1 hour meeting
        event.calendar = [store defaultCalendarForNewEvents];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
    }];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
