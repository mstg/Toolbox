include $(THEOS)/makefiles/common.mk

TOOL_NAME = ToolboxWeatherDaemon
ToolboxWeatherDaemon_FILES = main.m
ToolboxWeatherDaemon_FRAMEWORKS = CoreLocation
ToolboxWeatherDaemon_CODESIGN_FLAGS = -Sent.plist
ToolboxWeatherDaemon_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk

after-ToolboxWeatherDaemon-stage::
	$(ECHO_NOTHING)$(FAKEROOT) chown root:wheel $(THEOS_STAGING_DIR)/Library/LaunchDaemons/no.gezen.toolboxweatherdaemon.plist$(ECHO_END)
