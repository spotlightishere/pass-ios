ARCHS=armv7 armv7s
TARGET=iphone:latest
CFLAGS=-fobjc-arc -I modules/Valet -I modules/Valet/Valet -I modules/Valet/Other

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = pass
pass_FILES = main.m passwordstoreApplication.mm PasswordsViewController.mm PassEntry.mm PassDataController.mm PassEntryViewController.mm modules/Valet/Valet/VALValet.m modules/Valet/Valet/VALSecureEnclaveValet.m
pass_FRAMEWORKS = UIKit CoreGraphics Security
TARGET_CODESIGN_FLAGS = -Sent.xml

include $(THEOS_MAKE_PATH)/application.mk

build-install: clean package install

