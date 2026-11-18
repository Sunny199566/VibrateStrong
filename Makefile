ARCHS = arm64e
TARGET = iphone:clang:16.5:16.5
THEOS_PACKAGE_SCHEME = rootless
THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222

INSTALL_TARGET_PROCESSES = SpringBoard MobilePhone

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VibrateStrong

VibrateStrong_FILES = Tweak.xm Preferences/RootController.m
VibrateStrong_FRAMEWORKS = UIKit CoreHaptics AudioToolbox
VibrateStrong_CFLAGS = -fobjc-arc
VibrateStrong_CCFLAGS = -std=c++17

include $(THEOS_MAKE_PATH)/tweak.mk