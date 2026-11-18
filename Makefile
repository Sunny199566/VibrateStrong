ARCHS = arm64e
TARGET = iphone:clang:16.5:16.5
THEOS_PACKAGE_SCHEME = rootless
THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VibrateTest

VibrateTest_FILES = Tweak.xm
VibrateTest_FRAMEWORKS = UIKit
VibrateTest_CFLAGS = -fobjc-arc
VibrateTest_CXXFLAGS = -std=c++17

include $(THEOS_MAKE_PATH)/tweak.mk