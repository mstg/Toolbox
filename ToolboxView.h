/*
* @Author: mustafa
* @Date:   2016-08-08 20:17:19
* @Last Modified by:   mustafa
* @Last Modified time: 2016-08-10 10:24:45
*/

#include "ToolboxListModulesView.h"

@interface ToolboxView : UIView {
  NSMutableArray *_views;
}
-(ToolboxView*)initWithFrame:(CGRect)frame;
-(void)addView:(UIView*)view;
-(void)showView:(UIView*)view;
-(NSMutableArray*)views;
-(NSArray*)visibleIcons;
-(BOOL)containsIcon:(id)arg1;
-(void)updateViews;
-(void)initMenu;
-(void)showMenu;
@end