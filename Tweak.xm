#import <substrate.h>
#import <AudioToolbox/AudioToolbox.h>

static void playStrongVibration() {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    });
}

%hook RingtoneManager
- (void)vibrate {
    %orig;
    playStrongVibration();
}
%end