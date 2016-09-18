//
//  LoginViewViewController.m
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/16/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import "LoginViewController.h"
#import "DashBoardViewController.h"
#import "DataBaseManager.h"
#import "MyUserDefaults.h"
#import <LocalAuthentication/LocalAuthentication.h>


@import Firebase;

@interface LoginViewController ()<UITextFieldDelegate>
@property(nonatomic, strong) IBOutlet UIButton* loginButton;
@property(nonatomic, strong) IBOutlet UITextField* emailTextField;
@property(nonatomic, strong) IBOutlet UITextField* passwordTextField;
@property(nonatomic, strong) IBOutlet UITextField* patientIdTextField;
@property(nonatomic, strong) IBOutlet UIImageView* backgroundImageView;


@property(nonatomic, strong) IBOutlet UIView* fingerPrintAlertView;
@property(nonatomic, strong) IBOutlet UIButton* fingerPrintAlertNo;
@property(nonatomic, strong) IBOutlet UIButton* fingerPrintAlertYes;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    if ([MyUserDefaults isTouchIDAllowed])
    {
        
        NSString* email = [MyUserDefaults retrieveEmail];
        NSString* patientId = [MyUserDefaults retrievePatientId];
        NSString* password = [MyUserDefaults retrievePassword];
        
        if (email && email.length > 0 && password && password.length > 0 && patientId && patientId.length > 0)
        {
            self.emailTextField.text = email;
            self.patientIdTextField.text = patientId;
            self.passwordTextField.text = password;
            
            LAContext *myContext = [[LAContext alloc] init];
            NSError *authError = nil;
            NSString *myLocalizedReasonString = @"Touch ID for \"PatientLink\" Log in securely with Touch ID";
            
            if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
                [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                          localizedReason:myLocalizedReasonString
                                    reply:^(BOOL success, NSError *error) {
                                        if (success)
                                        {
                                            [self loginButton:nil];
                                            // User authenticated successfully, take appropriate action
                                        }
                                        else
                                        {
                                            self.emailTextField.text = @"";
                                            self.patientIdTextField.text = @"";
                                            self.passwordTextField.text = @"";
                                            // User did not authenticate successfully, look at error and take appropriate action
                                        }
                                    }];
            } else {
                // Could not evaluate policy; look at authError and present an appropriate message to user
            }
        }
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if ([self.emailTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.emailTextField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.emailTextField.leftView = paddingView;
        self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    
    
    if ([self.passwordTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.passwordTextField.leftView = paddingView;
        self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    
    if ([self.patientIdTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.patientIdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.patientIdTextField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.patientIdTextField.leftView = paddingView;
        self.patientIdTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButton:(id)sender
{
    if (self.emailTextField.text.length != 0 && self.passwordTextField.text.length != 0 && self.patientIdTextField.text.length != 0)
    {
        
        [[FIRAuth auth] createUserWithEmail:self.emailTextField.text password:self.passwordTextField.text
                                 completion:^(FIRUser *_Nullable user,
                                              NSError *_Nullable error)
         {
             if (nil == error)
             {
                 [[DataBaseManager sharedInstance] retreivePatientInfoAndUpdateWithEmail:self.emailTextField.text patientId:self.patientIdTextField.text];
                 
                 if (![MyUserDefaults isTouchIDAllowed])
                 {
                     [self showFingerPrintAlertView];
                 }
             }
             else
             {
                 [[FIRAuth auth] signInWithEmail:self.emailTextField.text password:self.passwordTextField.text completion:^(FIRUser *_Nullable user,
                                                                                                                           NSError *_Nullable error)
                 {
                     if (nil == error)
                     {
                         [[DataBaseManager sharedInstance] retreivePatientInfoAndUpdateWithEmail:self.emailTextField.text patientId:self.patientIdTextField.text];
                         
                         if (![MyUserDefaults isTouchIDAllowed])
                         {
                             [self showFingerPrintAlertView];
                         }
                         else
                         {
                             [MyUserDefaults storeUserInfo:self.emailTextField.text patientId:self.patientIdTextField.text andPassword:self.passwordTextField.text];
                            
                             DashBoardViewController* dashBoardViewController = [[DashBoardViewController alloc] initWithNibName:@"DashBoardViewController" bundle:nil];
                             [self.navigationController pushViewController:dashBoardViewController animated:YES];
                         }
                     }
                     else
                     {
                         UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Login Invalid" preferredStyle:UIAlertControllerStyleAlert];
                         
                         UIAlertAction* ok = [UIAlertAction
                                              actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                                              {
                                                  //Do some thing here
                                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                                                  
                                              }];
                         [alertController addAction:ok];
                         
                         [self presentViewController:alertController animated:YES completion:nil];
                         
                     }
                 }];
             }
         }];
    }
}


- (void)showFingerPrintAlertView
{
    [self.fingerPrintAlertView setHidden:NO];
    [self.emailTextField setUserInteractionEnabled:NO];
    [self.passwordTextField setUserInteractionEnabled:NO];
    [self.patientIdTextField setUserInteractionEnabled:NO];
    [self.loginButton setUserInteractionEnabled:NO];
    
    [self.emailTextField setAlpha:.8];
    [self.passwordTextField setAlpha:.8];
    [self.patientIdTextField setAlpha:.8];
    [self.loginButton setAlpha:.8];
    [self.backgroundImageView setAlpha:.8];
}

- (void)hideFingerPrintAlertView
{
    [self.fingerPrintAlertView setHidden:YES];
    [self.emailTextField setUserInteractionEnabled:YES];
    [self.passwordTextField setUserInteractionEnabled:YES];
    [self.patientIdTextField setUserInteractionEnabled:YES];
    [self.loginButton setUserInteractionEnabled:YES];
    
    [self.emailTextField setAlpha:1];
    [self.passwordTextField setAlpha:1];
    [self.patientIdTextField setAlpha:1];
    [self.loginButton setAlpha:1];
    [self.backgroundImageView setAlpha:1];
}

- (IBAction)fingerPrintAllow:(id)sender
{
    [MyUserDefaults allowTouchID];
    [MyUserDefaults storeUserInfo:self.emailTextField.text patientId:self.patientIdTextField.text andPassword:self.passwordTextField.text];
    [self hideFingerPrintAlertView];
    DashBoardViewController* dashBoardViewController = [[DashBoardViewController alloc] initWithNibName:@"DashBoardViewController" bundle:nil];
    [self.navigationController pushViewController:dashBoardViewController animated:YES];
}


- (IBAction)fingerPrintDisallow:(id)sender
{
    [MyUserDefaults disableTouchID];
    [MyUserDefaults storeUserInfo:self.emailTextField.text patientId:self.patientIdTextField.text andPassword:self.passwordTextField.text];
    [self hideFingerPrintAlertView];
    DashBoardViewController* dashBoardViewController = [[DashBoardViewController alloc] initWithNibName:@"DashBoardViewController" bundle:nil];
    [self.navigationController pushViewController:dashBoardViewController animated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

@end
