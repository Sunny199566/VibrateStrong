#import <substrate.h>
#import <CoreHaptics/CoreHaptics.h>
#include <dispatch/dispatch.h>

static CHHapticEngine *hapticEngine = nil;
static BOOL isPlaying = NO;

static void playMaxHeavyHaptic() {
    if (isPlaying) return;
    isPlaying = YES;

    if (!hapticEngine) {
        NSError *err;
        hapticEngine = [[CHHapticEngine alloc] initAndReturnError:&err];
        if (!hapticEngine) {
            isPlaying = NO;
            return;
        }
        [hapticEngine startAndReturnError:&err];
        hapticEngine.stoppedHandler = ^(CHHapticEngineStoppedReason reason) {
            NSError *e;
            [hapticEngine startAndReturnError:&e];
        };
    }

    NSError *err = nil;
    // 连续两段厚重闷震，强度拉满，低锐度，感知极强
    NSDictionary *ahapDict = @{
        @"Version": @1,
        @"Pattern": @[
            @{
                @"Event": @{
                    @"EventType": @"HapticContinuous",
                    @"Time": @0.0,
                    @"Duration": @0.40,
                    @"EventParameters": @[
                        @{@"ParameterID": @"HapticIntensity", @"ParameterValue": @1.0},
                        @{@"ParameterID": @"HapticSharpness", @"ParameterValue": @0.06}
                    ]
                }
            },
            @{
                @"Event": @{
                    @"EventType": @"HapticContinuous",
                    @"Time": @0.55,
                    @"Duration": @0.40,
                    @"EventParameters": @[
                        @{@"ParameterID": @"HapticIntensity", @"ParameterValue": @1.0},
                        @{@"ParameterID": @"HapticSharpness", @"ParameterValue": @0.06}
                    ]
                }
            }
        ]
    };
    CHHapticPattern *pattern = [[CHHapticPattern alloc] initWithDictionary:ahapDict error:&err];
    if (!pattern) {
        isPlaying = NO;
        return;
    }
    id<CHHapticPatternPlayer> player = [hapticEngine createPlayerWithPattern:pattern error:&err];
    if (player) {
        [player startAtTime:0 error:&err];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isPlaying = NO;
        });
    } else {
        isPlaying = NO;
    }
}

// 替换通知反馈，不再使用SBNotificationHapticPlayer
%hook UINotificationFeedbackGenerator
- (void)notificationOccurred:(long long)type {
    %orig;
    playMaxHeavyHaptic();
}
%end