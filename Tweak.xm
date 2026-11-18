#import <substrate.h>
#import <UIKit/UIKit.h>
#include <dispatch/dispatch.h>

static void playDoubleHeavyImpact() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
        [gen prepare];
        [gen impactOccurred];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.18 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIImpactFeedbackGenerator *gen2 = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
            [gen2 prepare];
            [gen2 impactOccurred];
        });
    });
}

%hook UINotificationFeedbackGenerator
- (void)notificationOccurred:(long long)type {
    %orig;
    playDoubleHeavyImpact();
}
%end