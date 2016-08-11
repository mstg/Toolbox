#include "ToolboxView.h"
#include <objc/runtime.h>
#include "modules/ToolboxModule.h"

@implementation ToolboxView
-(ToolboxView*)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    UIScrollView *_scroll = [[UIScrollView alloc] initWithFrame:frame];
    _scroll.hidden = YES;
    _scroll.alpha = 0;
    [_scroll setContentSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
    [[ToolboxModule sharedInstance] setScrollView:_scroll];
    [self addSubview:_scroll];

    _views = [[NSMutableArray alloc] init];
    [_views retain];
    [_scroll retain];
  }
  return self;
}

-(void)addView:(UIView*)view {
  view.frame = self.frame;

  [[self views] addObject:view];
}

-(void)showView:(UIView*)view {
  ToolboxListModulesView *_menu = (ToolboxListModulesView*)[[ToolboxModule sharedInstance] menu];
  UIScrollView *_scroll = [[ToolboxModule sharedInstance] scrollView];
  ToolboxModule *mView = (ToolboxModule*)view;
  [mView viewUpdateWhenActive];
  [_scroll setContentSize:CGSizeMake(view.frame.size.width, _scroll.frame.size.height)];
  [_scroll addSubview:mView];
  _scroll.hidden = NO;

  HBLogDebug(@"Scroll not hidden");

  [UIView animateWithDuration:0.3
    delay:0.0
    options:UIViewAnimationOptionCurveEaseOut
    animations:^{
      [_menu setAlpha:0];
      [_scroll setAlpha:1];
    }
    completion:^(BOOL finished){
      if (finished) {
        _menu.hidden = YES;
        [[ToolboxModule sharedInstance] setActiveView:mView];
        HBLogDebug(@"Menu hidden");
      }
    }];
}

-(NSMutableArray*)views {
  return _views;
}

-(NSArray*)visibleIcons {
  return @[];
}

-(BOOL)containsIcon:(id)arg1 {
  return NO;
}

-(void)updateViews {
  for (ToolboxModule* view in [self views]) {
    [view viewUpdateWhenActive];
  }
}

-(void)initMenu {
  ToolboxListModulesView *_menu = [[ToolboxListModulesView alloc] initWithFrame:self.frame tbview:(UIScrollView*)self];
  [[ToolboxModule sharedInstance] setMenu:(UIScrollView*)_menu];
  [self addSubview:_menu];
}

-(void)showMenu {
  ToolboxListModulesView *_menu = (ToolboxListModulesView*)[[ToolboxModule sharedInstance] menu];
  UIScrollView *_scroll = [[ToolboxModule sharedInstance] scrollView];
  _menu.hidden = NO;
  [UIView animateWithDuration:0.3
    delay:0.0
    options:UIViewAnimationOptionCurveEaseOut
    animations:^{
      _scroll.alpha = 0;
      _menu.alpha = 1;
    }
    completion:^(BOOL finished){
      if (finished) {
        _scroll.hidden = YES;
        [[ToolboxModule sharedInstance] setActiveView:nil];
        for (UIView *view in [_scroll subviews]) {
          [view removeFromSuperview];
        }
      }
    }];
}

-(void)dealloc {
  [super dealloc];
  UIScrollView *_scroll = [[ToolboxModule sharedInstance] scrollView];
  ToolboxListModulesView *_menu = [[ToolboxListModulesView alloc] initWithFrame:self.frame tbview:(UIScrollView*)self];
  [_views release];
  [_scroll release];
  [_menu release];
}
@end