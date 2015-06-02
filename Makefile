export ARCHS=arm64 armv7 armv7s
export TARGET=iphone:latest

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = passwordstore
passwordstore_FILES = main.m passwordstoreApplication.mm PasswordsViewController.mm PassEntry.mm PassDataController.mm PassEntryViewController.mm A0SimpleKeychain.m
passwordstore_FRAMEWORKS = UIKit CoreGraphics Security
TARGET_CODESIGN_FLAGS = -Sent.xml

include $(THEOS_MAKE_PATH)/application.mk

build-install: clean package install

