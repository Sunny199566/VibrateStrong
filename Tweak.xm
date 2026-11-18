#import <substrate.h>
#import <CoreHaptics/CoreHaptics.h>
#import <AudioToolbox/AudioToolbox.h>

static CHHapticEngine *sharedHapticEngine = nil;
static BOOL tweakEnable = YES;
static float callIntensity = 1.0f;
static float notifyIntensity = 1.0f;
static float duration = 0.8f;

// 读取偏好设置
static void readPrefs() {
    NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.xxx.vibratestrong"];
    tweakEnable = [prefs[@"enable"] boolValue];
    callIntensity = [prefs[@"callInt"] floatValue] ?: 1.0f;
    notifyIntensity = [prefs[@"notifyInt"] floatValue] ?: 1.0f;
    duration = [prefs[@"dur"] floatValue] ?: 0.8f;
}

// 播放强震动
static void playStrongHaptic(float intensity, float dur) {
    if (!tweakEnable) return;
    NSError *err;
    if (!sharedHapticEngine) {
        sharedHapticEngine = [[CHHapticEngine alloc] initAndReturnError:&err];
        sharedHapticEngine.stoppedHandler = ^(CHHapticEngineStoppedReason reason) {
            sharedHapticEngine = nil;
        };
        [sharedHapticEngine startAndReturnError:&err];
    }
    CHHapticEventParameter *intParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:intensity];
    CHHapticEventParameter *sharpParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:0.9f];
    CHHapticEvent *event = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticContinuous parameters:@[intParam, sharpParam] relativeTime:0 duration:dur];
    CHHapticPattern *pattern = [[CHHapticPattern alloc] initWithEvents:@[event] parameters:@[] error:&err];
    id<CHHapticPatternPlayer> player = [sharedHapticEngine makePlayerWithPattern:pattern error:&err];
    [player startAtTime:0 error:&err];
}

// ========== Hook：SpringBoard通知震动 ==========
static void (*origAudioServicesPlayAlertSound)(SystemSoundID ssid);
void hookAudioServicesPlayAlertSound(SystemSoundID ssid) {
    readPrefs();
    if (ssid == kSystemSoundID_Vibrate && tweakEnable) {
        playStrongHaptic(notifyIntensity, duration);
        return; // 屏蔽原生弱震动
    }
    origAudioServicesPlayAlertSound(ssid);
}

// ========== Hook：MobilePhone来电震动（来电铃响震动） ==========
static void (*origPlayRingtoneVibrate)(id self, SEL _cmd);
void hookPlayRingtoneVibrate(id self, SEL _cmd) {
    readPrefs();
    if (tweakEnable) {
        playStrongHaptic(callIntensity, duration);
        return;
    }
    origPlayRingtoneVibrate(self, _cmd);
}

%ctor {
    MSHookFunction((void*)AudioServicesPlayAlertSound, (void*)hookAudioServicesPlayAlertSound, (void**)&origAudioServicesPlayAlertSound);

    // MobilePhone里面来电震动selector，iOS17.0： -[RingtoneManager playVibration]
    Class ringCls = objc_getClass("RingtoneManager");
    if (ringCls) {
        MSHookMessageEx(ringCls, @selector(playVibration), (IMP)hookPlayRingtoneVibrate, (IMP*)&origPlayRingtoneVibrate);
    }
}