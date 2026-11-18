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
    CHHapticEvent *event = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticContinuous relativeTime:0 duration:0.8 parameters:@[
        [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:1.0],
        [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:0.8]
    ]];
    CHHapticPattern *pattern = [[CHHapticPattern alloc] initWithEvents:@[event] parameters:@[] error:&err];
    if (!pattern) return;

    // ✅ 重点：这里改成 createPlayerWithPattern:error:
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