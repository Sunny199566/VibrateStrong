#import <substrate.h>
#import <AudioToolbox/AudioToolbox.h>
#import <notify.h>

static void playStrongVibration() {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    });
}

static int notifyToken;

%ctor {
    // 监听来电响铃通知，SpringBoard内广播
    notify_register_dispatch("com.apple.springboard.ringer-start", &notifyToken, dispatch_get_main_queue(), ^(int token) {
        playStrongVibration();
    });
}