#import <substrate.h>
#import <UIKit/UIKit.h>
#include <dispatch/dispatch.h>
#import <objc/runtime.h>

static void playDoubleHeavyTaptic() {
    dispatch_async(dispatch_get_main_queue(), ^{
        Class cls = objc_getClass("_UIReturnFeedbackGenerator");
        if (!cls) return;
        id gen = [[cls alloc] init];
        [gen setValue:@2 forKey:@"_feedbackType"];
        SEL trigger = @selector(feedbackOccurred);
        if ([gen respondsToSelector:trigger]) {
            objc_msgSend(gen, trigger);
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.18 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            id gen2 = [[cls alloc] init];
            [gen2 setValue:@2 forKey:@"_feedbackType"];
            if ([gen2 respondsToSelector:trigger]) {
                objc_msgSend(gen2, trigger);
            }
        });
    });
}

%hook UINotificationFeedbackGenerator
- (void)notificationOccurred:(long long)type {
    %orig;
    playDoubleHeavyTaptic();
}
%end