/*
* @Author: mustafa
* @Date:   2016-08-08 21:59:08
* @Last Modified by:   mustafa
* @Last Modified time: 2016-08-10 10:23:37
*/

#import <objc/runtime.h>
#import "../ToolboxView.h"

@interface SBApplication : NSObject
@end

@interface SBApplicationController
-(SBApplicationController*)sharedInstance;
-(SBApplication*)applicationWithBundleIdentifier:(NSString*)identifier;
@end

@interface SBIcon
@end

@interface SBApplicationIcon : SBIcon
-(SBApplicationIcon*)initWithApplication:(SBApplication*)application;
@end

@interface SBIconView : UIView
-(SBIconView*)initWithContentType:(long long)type;
-(void)setIcon:(SBIcon*)icon;
-(CGRect)iconImageFrame;
@end

@interface ToolboxModule : UIView {
  UIView *_appIcon;
  NSMutableArray *_views;
  ToolboxView *_tbview;
  ToolboxModule *_activeView;
  UIScrollView *_scrollView;
  UIScrollView *_menu;
}
+(instancetype)sharedInstance;
+(instancetype)sharedInstanceWithTB:(ToolboxView*)tbview;
-(void)setAppIcon:(UIView*)icon;
-(UIView*)appIcon;
-(CGFloat)center:(CGRect)view superview:(CGRect)superview type:(NSInteger)type;/*X: 1, Y:2*/
-(NSMutableArray*)views;
-(ToolboxView*)tbview;
-(ToolboxModule*)activeView;
-(void)setActiveView:(ToolboxModule*)activeView;
-(void)registerModule:(ToolboxModule*)module;
-(void)setTBView:(ToolboxView*)tbview;
-(void)viewUpdateWhenActive;
-(void)showView:(UIView*)view;
-(UIScrollView*)scrollView;
-(UIScrollView*)menu;
-(void)setScrollView:(UIScrollView*)scrollView;
-(void)setMenu:(UIScrollView*)menu;
@end