#import <substrate.h>
#import <AudioToolbox/AudioToolbox.h>

static void playStrongVibration() {
    // 系统长震动，iPhone15Pro 可用
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    // 叠加一次，增强效果
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