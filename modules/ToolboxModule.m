/*
* @Author: mustafa
* @Date:   2016-08-08 22:01:35
* @Last Modified by:   mustafa
* @Last Modified time: 2016-08-10 10:30:36
*/

#include "ToolboxModule.h"
#include "../ToolboxView.h"

@implementation ToolboxModule
+(instancetype)sharedInstance {
  static ToolboxModule *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[ToolboxModule alloc] init];
    sharedInstance->_activeView = nil;
  });
  return sharedInstance;
}

+(instancetype)sharedInstanceWithTB:(ToolboxView*)tbview {
  ToolboxModule *module = [ToolboxModule sharedInstance];
  [module setTBView:tbview];

  return module;
}

-(void)setAppIcon:(ToolboxView*)icon {
  _appIcon = icon;
}

-(UIView*)appIcon {
  return _appIcon;
}

-(CGFloat)center:(CGRect)view superview:(CGRect)superview type:(NSInteger)type {
  HBLogDebug(@"Type:%zd Superview height:%f View height:%f", type, superview.size.height, view.size.height);
  if (type == 1) {
    return (superview.size.width/2)-(view.size.width/2);
  } else if (type == 2) {
    return (superview.size.height/2)-(view.size.height/2);
  }

  return 0.0;
}

-(NSMutableArray*)views {
  return _views;
}

-(ToolboxView*)tbview {
  return _tbview;
}

-(UIView*)activeView {
  return _activeView;
}

-(void)setActiveView:(ToolboxModule*)activeView {
  _activeView = activeView;
}

-(void)registerModule:(ToolboxModule*)module {
  [_views addObject:module];
  [[self tbview] addView:module];
}

-(void)setTBView:(ToolboxView*)tbview {
  _tbview = tbview;
}

-(void)viewUpdateWhenActive {

}

-(void)showView:(UIView*)view {
  [[self tbview] showView:view];
}

-(UIScrollView*)scrollView {
  return _scrollView;
}

-(UIScrollView*)menu {
  return _menu;
}

-(void)setScrollView:(UIScrollView*)scrollView {
  if (_scrollView) {
    HBLogDebug(@"Won't set scrollView");
    return;
  }
  _scrollView = scrollView;
}

-(void)setMenu:(UIScrollView*)menu {
  if (_menu) {
    HBLogDebug(@"Won't set menu");
    return;
  }
  _menu = menu;
}
@end