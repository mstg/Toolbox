/*
* @Author: mustafa
* @Date:   2016-08-10 09:19:08
* @Last Modified by:   mustafa
* @Last Modified time: 2016-08-10 21:31:14
*/

#include "../ToolboxModule.h"

@interface FBSSystemService
+(id)sharedService;
-(void)sendActions:(id)arg1 withResult:(/*^block*/id)arg2 ;
@end

@interface SBSRelaunchAction
+(id)actionWithReason:(id)arg1 options:(unsigned long long)arg2 targetURL:(id)arg3 ;
@end

@interface SpringBoard : NSObject
- (void)_relaunchSpringBoardNow;
-(void)powerDown;
-(void)reboot;
@end

@interface ToolboxSettingsModule : ToolboxModule {
  CGFloat _lastx;
}
-(ToolboxSettingsModule*)init;
-(void)addButton:(NSString*)text selector:(SEL)_selector;
@end