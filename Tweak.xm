#import <substrate.h>
#import <CoreHaptics/CoreHaptics.h>
#import <CallKit/CallKit.h>

static CHHapticEngine *hapticEngine = nil;
static BOOL isPlaying = NO;

static void playHeavyHaptic() {
    if (isPlaying) return;
    isPlaying = YES;
    
    if (!hapticEngine) {
        NSError *err = nil;
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
    // 厚重大幅度猛震，低锐度，不是清脆滴答
    NSDictionary *ahapDict = @{
        @"Version": @1,
        @"Pattern": @[
            @{
                @"Event": @{
                    @"EventType": @"HapticContinuous",
                    @"Time": @0.0,
                    @"Duration": @0.7,
                    @"EventParameters": @[
                        @{@"ParameterID": @"HapticIntensity", @"ParameterValue": @1.0},
                        @{@"ParameterID": @"HapticSharpness", @"ParameterValue": @0.12}
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isPlaying = NO;
        });
    } else {
        isPlaying = NO;
    }
}

static CXCallObserver *callObserver;

%ctor {
    callObserver = [[CXCallObserver alloc] init];
    [callObserver setCallObserverDelegate:objc_getClass("VibrateCallDelegate") queue:dispatch_get_main_queue()];
}

@interface VibrateCallDelegate : NSObject <CXCallObserverDelegate>
@end
@implementation VibrateCallDelegate
- (void)callObserver:(CXCallObserver *)observer callChanged:(CXCall *)call {
    // 检测到新来电（呼出不触发，只处理入站）
    if (call.isOutgoing == NO && call.hasConnected == NO && call.hasEnded == NO) {
        playHeavyHaptic();
    }
}
@end