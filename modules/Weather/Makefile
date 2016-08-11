SDKVERSION = 9.2
SYSROOT = $(THEOS)/sdks/iPhoneOS9.2.sdk

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = ToolboxWeatherModule
ToolboxWeatherModule_FILES = ToolboxWeatherModule.m
ToolboxWeatherModule_PRIVATE_FRAMEWORKS = Weather WeatherUI
ToolboxWeatherModule_LIBRARIES = ToolboxHelper
ToolboxWeatherModule_INSTALL_PATH = /Library/Toolbox

include $(THEOS_MAKE_PATH)/library.mk
SUBPROJECTS += toolboxweatherdaemon
include $(THEOS_MAKE_PATH)/aggregate.mk
