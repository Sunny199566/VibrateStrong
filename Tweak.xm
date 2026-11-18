#import <substrate.h>
#import <CoreHaptics/CoreHaptics.h>
#import <CallKit/CallKit.h>

@interface VibrateCallDelegate : NSObject <CXCallObserverDelegate>
@end

static CHHapticEngine *hapticEngine = nil;
static BOOL isPlaying = NO;
static CXCallObserver *callObserver;
static id delegateInstance;

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

@implementation VibrateCallDelegate
- (void)callObserver:(CXCallObserver *)observer callChanged:(CXCall *)call {
    if (!call.isOutgoing && !call.hasConnected && !call.hasEnded) {
        playHeavyHaptic();
    }
}
@end

%ctor {
    delegateInstance = [[VibrateCallDelegate alloc] init];
    callObserver = [[CXCallObserver alloc] init];
    [callObserver setDelegate:delegateInstance queue:dispatch_get_main_queue()];
}