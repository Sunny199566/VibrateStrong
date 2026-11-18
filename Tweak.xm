#import <substrate.h>
#import <CoreHaptics/CoreHaptics.h>

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
    // 连续两段厚重大震：0~0.35s震，间隔0.15s，0.5~0.85s再来一次
    NSDictionary *ahapDict = @{
        @"Version": @1,
        @"Pattern": @[
            @{
                @"Event": @{
                    @"EventType": @"HapticContinuous",
                    @"Time": @0.0,
                    @"Duration": @0.35,
                    @"EventParameters": @[
                        @{@"ParameterID": @"HapticIntensity", @"ParameterValue": @1.0},
                        @{@"ParameterID": @"HapticSharpness", @"ParameterValue": @0.10}
                    ]
                }
            },
            @{
                @"Event": @{
                    @"EventType": @"HapticContinuous",
                    @"Time": @0.50,
                    @"Duration": @0.35,
                    @"EventParameters": @[
                        @{@"ParameterID": @"HapticIntensity", @"ParameterValue": @1.0},
                        @{@"ParameterID": @"HapticSharpness", @"ParameterValue": @0.10}
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isPlaying = NO;
        });
    } else {
        isPlaying = NO;
    }
}

// 1. APP推送通知震动（微信、QQ、各类消息通知）
%hook SBNotificationHapticPlayer
- (void)playHapticForNotification:(id)notification {
    %orig;
    playHeavyDoubleHaptic();
}
%end

// 2. 来电震动（静音来电、响铃来电，全部走这里）
%hook SBRingerHapticPlayer
- (void)playRingerHaptic {
    %orig;
    playHeavyDoubleHaptic();
}
%end