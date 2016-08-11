include $(THEOS)/makefiles/common.mk

SUBPROJECTS += modules

include $(THEOS_MAKE_PATH)/aggregate.mk

TWEAK_NAME = Toolbox
Toolbox_FILES = Tweak.xm ToolboxView.m ToolboxListModulesView.m
Toolbox_LIBRARIES = ToolboxHelper

include $(THEOS_MAKE_PATH)/tweak.mk

#logify/SBFullscreenZoomView_logify.xm
#logify/SBUIAnimationZoomUpApp_logify.xm

#export THEOS_DEVICE_IP=172.20.10.1
#export THEOS_DEVICE_PORT=22

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += modules/Weather \
	modules/Settings

include $(THEOS_MAKE_PATH)/aggregate.mk