//
//  JRAddAccountViewController.m
//  JRDemo
//
//  Created by Ginger on 2018/2/8.
//  Copyright © 2018年 Ginger. All rights reserved.
//

#import "JRAddAccountViewController.h"

typedef NS_ENUM(NSInteger, ConfigType) {
    ConfigTypeAccount,
    ConfigTypePassword,
    ConfigTypeAuthName,
    ConfigTypeServer,
    ConfigTypeServerRealm,
    ConfigTypePort,
    ConfigTypeTransport,
    ConfigTypeCount,
};

@interface JRAddAccountViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *accountTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *authNameTextField;
@property (nonatomic, strong) UITextField *serverTextField;
@property (nonatomic, strong) UITextField *serverRealmTextField;
@property (nonatomic, strong) UITextField *portTextField;
@property (nonatomic, strong) UISegmentedControl *transportTypeSegment;

@end

@implementation JRAddAccountViewController

+ (void)presentWithNavigationController:(void (^)(JRAddAccountViewController *))configBlock presentingViewController:(UIViewController *)viewController
{
    JRAddAccountViewController *vc = [[JRAddAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    if (configBlock) {
        configBlock(vc);
    }
    [viewController presentViewController:navigationController animated:YES completion:nil];
}

- (UITextField *)createTextField {
    UITextField *textField = [[UITextField alloc] init];
    textField.textAlignment = NSTextAlignmentRight;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyNext;
    textField.enablesReturnKeyAutomatically = YES;
    return textField;
}

- (UITextField *)accountTextField {
    if (!_accountTextField) {
        _accountTextField = [self createTextField];
        _accountTextField.placeholder = NSLocalizedString(@"ACCOUNT_INFO_USERNAME", nil);
    }
    return _accountTextField;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [self createTextField];
        _passwordTextField.placeholder = NSLocalizedString(@"ACCOUNT_INFO_PASSWORD", nil);
        _passwordTextField.secureTextEntry = YES;
    }
    return _passwordTextField;
}

- (UITextField *)authNameTextField {
    if (!_authNameTextField) {
        _authNameTextField = [self createTextField];
        _authNameTextField.placeholder = NSLocalizedString(@"ACCOUNT_INFO_AUTHNAME", nil);
    }
    return _authNameTextField;
}

- (UITextField *)serverTextField {
    if (!_serverTextField) {
        _serverTextField = [self createTextField];
        _serverTextField.placeholder = NSLocalizedString(@"ACCOUNT_INFO_SERVER", nil);
    }
    return _serverTextField;
}

- (UITextField *)serverRealmTextField {
    if (!_serverRealmTextField) {
        _serverRealmTextField = [self createTextField];
        _serverRealmTextField.placeholder = NSLocalizedString(@"ACCOUNT_INFO_SERVER_REALM", nil);
    }
    return _serverRealmTextField;
}

- (UITextField *)portTextField {
    if (!_portTextField) {
        _portTextField = [self createTextField];
        _portTextField.placeholder = NSLocalizedString(@"ACCOUNT_INFO_PORT", nil);
        _portTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _portTextField;
}

- (UISegmentedControl *)transportTypeSegment {
    if (!_transportTypeSegment) {
        _transportTypeSegment = [[UISegmentedControl alloc] initWithItems:@[@"UDP", @"TCP", @"TLS"]];
        _transportTypeSegment.translatesAutoresizingMaskIntoConstraints = NO;
        _transportTypeSegment.selectedSegmentIndex = 0;
    }
    return _transportTypeSegment;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIBarButtonItemStylePlain target:self action:@selector(leftBarItemAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"OK", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemAction)];
}

- (void)leftBarItemAction {
    if (_accountDelegate && [_accountDelegate respondsToSelector:@selector(addAccountCancel:)]) {
        [_accountDelegate addAccountCancel:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightBarItemAction {
    if ([self addAccount]) {
        [self.view endEditing:YES];
        if (_accountDelegate && [_accountDelegate respondsToSelector:@selector(addAccountFinish:account:)]) {
            [_accountDelegate addAccountFinish:self account:self.accountTextField.text];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"add fail");
        //Todo
    }
}

- (BOOL)addAccount {
    NSString *account = self.accountTextField.text;
    if (account.length == 0) {
        return NO;
    }
    
    NSString *password = self.passwordTextField.text;
    if (password.length == 0) {
        return NO;
    }
    
    NSString *authName = self.authNameTextField.text;
    if (authName.length == 0) {
        return NO;
    }
    
    NSString *server = self.serverTextField.text;
    if (server.length == 0) {
        return NO;
    }
    
    NSString *serverRealm = self.serverRealmTextField.text;
    if (serverRealm.length == 0) {
        return NO;
    }
    
    NSString *port = self.portTextField.text;
    if (port.length == 0) {
        return NO;
    }
    
    BOOL result = [JRAccount creatAccount:account];
    if (!result) {
        return NO;
    }
    
    JRAccountConfigParam *nameParam = [[JRAccountConfigParam alloc] init];
    nameParam.stringParam = account;
    [JRAccount setAccount:account config:nameParam forKey:JRAccountConfigKeyName];
    
    JRAccountConfigParam *passwordParam = [[JRAccountConfigParam alloc] init];
    passwordParam.stringParam = password;
    [JRAccount setAccount:account config:passwordParam forKey:JRAccountConfigKeyPassword];
    
    JRAccountConfigParam *authParam = [[JRAccountConfigParam alloc] init];
    authParam.stringParam = authName;
    [JRAccount setAccount:account config:authParam forKey:JRAccountConfigKeyAuthName];
    
    JRAccountConfigParam *ipParam = [[JRAccountConfigParam alloc] init];
    ipParam.stringParam = server;
    [JRAccount setAccount:account config:ipParam forKey:JRAccountConfigKeyServer];
    
    JRAccountConfigParam *realmParam = [[JRAccountConfigParam alloc] init];
    realmParam.stringParam = serverRealm;
    [JRAccount setAccount:account config:realmParam forKey:JRAccountConfigKeyServerRealm];
    
    JRAccountConfigParam *portParam = [[JRAccountConfigParam alloc] init];
    portParam.intParam = [port integerValue];
    [JRAccount setAccount:account config:portParam forKey:JRAccountConfigKeyPort];
    
    JRAccountConfigParam *typeParam = [[JRAccountConfigParam alloc] init];
    typeParam.enumParam = self.transportTypeSegment.selectedSegmentIndex;
    [JRAccount setAccount:account config:typeParam forKey:JRAccountConfigKeyTransport];
    
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ConfigTypeCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case ConfigTypeAccount: {
            cell.textLabel.text = NSLocalizedString(@"ACCOUNT_INFO_USERNAME", nil);
            [cell.contentView addSubview:self.accountTextField];
            
            NSArray *hCons = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-120-[_accountTextField]-20-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_accountTextField)];
            [cell.contentView addConstraints:hCons];
            
            NSArray *vCons = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_accountTextField]-0-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_accountTextField)];
            [cell.contentView addConstraints:vCons];
        }
            break;
        case ConfigTypePassword: {
            cell.textLabel.text = NSLocalizedString(@"ACCOUNT_INFO_PASSWORD", nil);
            [cell.contentView addSubview:self.passwordTextField];
            
            NSArray *hCons = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-120-[_passwordTextField]-20-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_passwordTextField)];
            [cell.contentView addConstraints:hCons];
            
            NSArray *vCons = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_passwordTextField]-0-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_passwordTextField)];
            [cell.contentView addConstraints:vCons];
        }
            break;
        case ConfigTypeAuthName: {
            cell.textLabel.text = NSLocalizedString(@"ACCOUNT_INFO_AUTHNAME", nil);
            [cell.contentView addSubview:self.authNameTextField];
            
            NSArray *hCons = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-120-[_authNameTextField]-20-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_authNameTextField)];
            [cell.contentView addConstraints:hCons];
            
            NSArray *vCons = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_authNameTextField]-0-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_authNameTextField)];
            [cell.contentView addConstraints:vCons];
        }
            break;
        case ConfigTypeServer: {
            cell.textLabel.text = NSLocalizedString(@"ACCOUNT_INFO_SERVER", nil);
            [cell.contentView addSubview:self.serverTextField];
            
            NSArray *hCons = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-120-[_serverTextField]-20-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_serverTextField)];
            [cell.contentView addConstraints:hCons];
            
            NSArray *vCons = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_serverTextField]-0-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_serverTextField)];
            [cell.contentView addConstraints:vCons];
        }
            break;
        case ConfigTypeServerRealm: {
            cell.textLabel.text = NSLocalizedString(@"ACCOUNT_INFO_SERVER_REALM", nil);
            [cell.contentView addSubview:self.serverRealmTextField];
            
            NSArray *hCons = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-120-[_serverRealmTextField]-20-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_serverRealmTextField)];
            [cell.contentView addConstraints:hCons];
            
            NSArray *vCons = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_serverRealmTextField]-0-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_serverRealmTextField)];
            [cell.contentView addConstraints:vCons];
        }
            break;
        case ConfigTypePort: {
            cell.textLabel.text = NSLocalizedString(@"ACCOUNT_INFO_PORT", nil);
            [cell.contentView addSubview:self.portTextField];
            
            NSArray *hCons = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-120-[_portTextField]-20-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_portTextField)];
            [cell.contentView addConstraints:hCons];
            
            NSArray *vCons = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_portTextField]-0-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_portTextField)];
            [cell.contentView addConstraints:vCons];
        }
            break;
        case ConfigTypeTransport: {
            cell.textLabel.text = NSLocalizedString(@"ACCOUNT_INFO_TRANSPORT", nil);
            [cell.contentView addSubview:self.transportTypeSegment];
            NSArray *hCons = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_transportTypeSegment(150.0)]-20-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_transportTypeSegment)];
            [cell.contentView addConstraints:hCons];
            
            NSArray *vCons = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_transportTypeSegment(24.0)]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_transportTypeSegment)];
            [cell.contentView addConstraints:vCons];
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_accountTextField]) {
        [_passwordTextField becomeFirstResponder];
    } else if ([textField isEqual:_passwordTextField]) {
        [_authNameTextField becomeFirstResponder];
    } else if ([textField isEqual:_authNameTextField]) {
        [_serverTextField becomeFirstResponder];
    } else if ([textField isEqual:_serverTextField]) {
        [_serverRealmTextField becomeFirstResponder];
    } else if ([textField isEqual:_serverRealmTextField]) {
        [_portTextField becomeFirstResponder];
    } else if ([textField isEqual:_portTextField]) {
        [_portTextField resignFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
