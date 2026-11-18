#import <Preferences/Preferences.h>

@interface VibrateStrongRootListController : PSListController
@end

@implementation VibrateStrongRootListController
- (id)specifiers {
    if (_specifiers == nil) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}
- (void)respring {
    [self.view endEditing:YES];
    system("killall -9 SpringBoard");
}
@end