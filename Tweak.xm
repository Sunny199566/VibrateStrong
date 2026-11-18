#import <substrate.h>
#import <CoreHaptics/CoreHaptics.h>
#include <dispatch/dispatch.h>

static CHHapticEngine *hapticEngine = nil;
static BOOL isPlaying = NO;

static void playHeavyDoubleHaptic() {
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
    // 两下厚重闷震，强度拉满，低锐度，幅度大，感知极强
    NSDictionary *ahapDict = @{
        @"Version": @1,
        @"Pattern": @[
            @{
                @"Event": @{
                    @"EventType": @"HapticContinuous",
                    @"Time": @0.0,
                    @"Duration": @0.38,
                    @"EventParameters": @[
                        @{@"ParameterID": @"HapticIntensity", @"ParameterValue": @1.0},
                        @{@"ParameterID": @"HapticSharpness", @"ParameterValue": @0.08}
                    ]
                }
            },
            @{
                @"Event": @{
                    @"EventType": @"HapticContinuous",
                    @"Time": @0.52,
                    @"Duration": @0.38,
                    @"EventParameters": @[
                        @{@"ParameterID": @"HapticIntensity", @"ParameterValue": @1.0},
                        @{@"ParameterID": @"HapticSharpness", @"ParameterValue": @0.08}
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isPlaying = NO;
        });
    } else {
        isPlaying = NO;
    }
}

// 只保留App通知震动Hook，来电部分全部删掉
%hook SBNotificationHapticPlayer
- (void)playHapticForNotification:(id)notification {
    %orig;
    playHeavyDoubleHaptic();
}
%end