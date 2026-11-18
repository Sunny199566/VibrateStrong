#import <substrate.h>
#import <UIKit/UIKit.h>
#include <dispatch/dispatch.h>

%ctor {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
        [gen prepare];
        [gen impactOccurred];
    });
}