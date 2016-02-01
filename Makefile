ARCHS=armv7 armv7s arm64
TARGET=iphone:latest

APPLICATION_NAME = pass
pass_FILES = main.m passwordstoreApplication.mm PasswordsViewController.mm PassEntry.mm PassDataController.mm PassEntryViewController.mm modules/Valet/Valet/VALValet.m modules/Valet/Valet/VALSecureEnclaveValet.m
pass_FRAMEWORKS = UIKit CoreGraphics Security
pass_CFLAGS=-fobjc-arc -I modules/Valet -I modules/Valet/Valet -I modules/Valet/Other

TARGET_CODESIGN_FLAGS = -Sent.xml

include modules/theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk

build-install: clean package install

