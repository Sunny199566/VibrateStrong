#import <substrate.h>
#import <CoreHaptics/CoreHaptics.h>

static CHHapticEngine *sharedHapticEngine = nil;

static void playStrongVibration() {
    if (!sharedHapticEngine) {
        NSError *err = nil;
        sharedHapticEngine = [[CHHapticEngine alloc] initAndReturnError:&err];
        if (!sharedHapticEngine) return;
        [sharedHapticEngine startAndReturnError:nil];
    }

    NSError *err = nil;
    // iOS16兼容写法，用字典构造Haptic Pattern
    NSDictionary *eventDict = @{
        CHHapticEventParameterIDHapticEventType: CHHapticEventTypeHapticContinuous,
        CHHapticEventParameterIDRelativeTime: @(0.0),
        CHHapticEventParameterIDDuration: @(0.8),
        CHHapticEventParameterIDHapticIntensity: @(1.0),
        CHHapticEventParameterIDHapticSharpness: @(0.8)
    };
    CHHapticPattern *pattern = [[CHHapticPattern alloc] initWithEvents:@[eventDict] parameters:@[] error:&err];
    if (!pattern) return;

    id<CHHapticPatternPlayer> player = [sharedHapticEngine createPlayerWithPattern:pattern error:&err];
    if (player) {
        [player startAtTime:0 error:&err];
    }
}

%hook RingtoneManager
- (void)vibrate {
    %orig;
    playStrongVibration();
}
%end