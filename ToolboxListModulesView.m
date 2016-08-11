/*
* @Author: mustafa
* @Date:   2016-08-10 06:37:39
* @Last Modified by:   mustafa
* @Last Modified time: 2016-08-10 21:13:43
*/

#import "ToolboxListModulesView.h"
#include "modules/ToolboxModule.h"
#import "ToolboxView.h"

@implementation ToolboxListModulesView
-(ToolboxListModulesView*)initWithFrame:(CGRect)frame tbview:(UIView*)tbview {
  self = [super initWithFrame:frame];

  if (self) {
    self.contentSize = CGSizeMake(0, frame.size.height);

    NSMutableArray *views = [(ToolboxView*)tbview views];
    _tagRegister = [[NSMutableArray alloc] init];
    [_tagRegister retain];

    CGFloat lastx = 0;

    NSInteger i = 0;
    for (ToolboxModule *view in views) {
      SBIconView *icon = (SBIconView*)[view appIcon];
      CGRect _centerApp = icon.frame;
      _centerApp.origin.y = [[ToolboxModule sharedInstance] center:_centerApp superview:self.frame type:2];
      _centerApp.origin.x = lastx + 30;
      lastx += 30 + _centerApp.size.width;
      [icon setFrame:_centerApp];

      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleModuleTap:)];
      [icon setTag:i];
      [icon setUserInteractionEnabled:YES];
      [icon addGestureRecognizer:tap];
      [_tagRegister addObject:view];
      i++;
      HBLogDebug(@"Add icon");

      icon.alpha = 0;

      [self addSubview:icon];
      self.contentSize = CGSizeMake(self.contentSize.width + icon.frame.size.width, self.contentSize.height);

      [UIView animateWithDuration:0.3
        delay:0.0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
          icon.alpha = 1;
        }
        completion:nil];
    }
  }
  return self;
}

-(void)handleModuleTap:(UITapGestureRecognizer*)recognizer {
  [[ToolboxModule sharedInstance] showView:[_tagRegister objectAtIndex:recognizer.view.tag]];
}

-(void)dealloc {
  [super dealloc];
  [_tagRegister release];
}
@end