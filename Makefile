DEBUG = 0
FINALPACKAGE = 1
TARGET := iphone:clang:latest:14.5
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TOOL_NAME = vnodebypass

vnodebypass_FILES = main.m vnode/vnode.m vnode/kernel.m vnode/fishhook.c
vnodebypass_CFLAGS = -fobjc-arc
vnodebypass_CODESIGN_FLAGS = -Sent.plist
vnodebypass_INSTALL_PATH = /usr/bin
vnodebypass_FRAMEWORKS = IOKit

include $(THEOS_MAKE_PATH)/tool.mk
SUBPROJECTS += app
SUBPROJECTS += debian-script
SUBPROJECTS += VBModule
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	chmod -R 755 $(THEOS_STAGING_DIR)
	chmod 6755 $(THEOS_STAGING_DIR)/usr/bin/vnodebypass
	chmod 6755 $(THEOS_STAGING_DIR)/Applications/vnodebypass.app/vnodebypass
	chmod 666 $(THEOS_STAGING_DIR)/DEBIAN/control
