#import <substrate.h>
#import <CoreHaptics/CoreHaptics.h>
#import <notify.h>

static CHHapticEngine *hapticEngine = nil;

static void playHeavyHaptic() {
    if (!hapticEngine) {
        NSError *err = nil;
        hapticEngine = [[CHHapticEngine alloc] initAndReturnError:&err];
        if (!hapticEngine) return;
        [hapticEngine startAndReturnError:nil];
        // 引擎自动重启，防止被系统挂掉
        hapticEngine.stoppedHandler = ^(CHHapticEngineStoppedReason reason) {
            NSError *e;
            [hapticEngine startAndReturnError:&e];
        };
    }

    NSError *err = nil;
    // AHAP字典，原生iOS13+支持，持续强震，满强度，低锐度=厚重大幅度震动（不是清脆滴答）
    NSDictionary *ahapDict = @{
        @"Version": @1,
        @"Pattern": @[
            @{
                @"Event": @{
                    @"EventType": @"HapticContinuous",
                    @"Time": @0.0,
                    @"Duration": @0.6,
                    @"EventParameters": @[
                        @{@"ParameterID": @"HapticIntensity", @"ParameterValue": @1.0},
                        @{@"ParameterID": @"HapticSharpness", @"ParameterValue": @0.15}
                    ]
                }
            }
        ]
    };

    CHHapticPattern *pattern = [[CHHapticPattern alloc] initWithDictionary:ahapDict error:&err];
    if (!pattern) return;

    id<CHHapticPatternPlayer> player = [hapticEngine createPlayerWithPattern:pattern error:&err];
    if (player) {
        [player startAtTime:0 error:&err];
    }
}

static int ringNotifyToken;
static int silentVibrateNotifyToken;

%ctor {
    // 响铃来电
    notify_register_dispatch("com.apple.springboard.ringer-start", &ringNotifyToken, dispatch_get_main_queue(), ^(int token) {
        playHeavyHaptic();
    });
    // 静音模式来电震动
    notify_register_dispatch("com.apple.springboard.incoming-call-vibrate", &silentVibrateNotifyToken, dispatch_get_main_queue(), ^(int token) {
        playHeavyHaptic();
    });
}