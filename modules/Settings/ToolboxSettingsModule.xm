/*
* @Author: mustafa
* @Date:   2016-08-10 09:19:16
* @Last Modified by:   mstg
* @Last Modified time: 2016-08-12 20:37:33
*/

#include "ToolboxSettingsModule.h"
#include <objc/runtime.h>
#include <version.h>

@interface TBLabel : UILabel
@end

@implementation TBLabel
- (void)drawTextInRect:(CGRect)rect {
  UIEdgeInsets insets = {0, 5, 0, 5};
  [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
@end

@implementation ToolboxSettingsModule
+(void)load {
  [[ToolboxModule sharedInstance] registerModule:[[ToolboxSettingsModule alloc] init]];
}

-(ToolboxSettingsModule*)init {
  self = [super init];

  if (self) {
    SBApplication *prefApp = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:@"com.apple.Preferences"];
    SBApplicationIcon *prefAppIcon = [[%c(SBApplicationIcon) alloc] initWithApplication:prefApp];

    SBIconView *app = [[%c(SBIconView) alloc] initWithContentType:1];
    [app setIcon:prefAppIcon];
    [self setAppIcon:(UIView*)app];
    _lastx = 5;
  }

  return self;
}

-(void)addButton:(NSString*)text selector:(SEL)_selector {
  TBLabel *button = [[TBLabel alloc] initWithFrame:self.frame];
  button.textAlignment = NSTextAlignmentCenter;
  UIFont *__font = [UIFont systemFontOfSize:18 weight:UIFontWeightUltraLight];
  button.font = __font;
  button.textColor = [UIColor whiteColor];
  button.text = text;
  button.layer.cornerRadius = 5;
  button.clipsToBounds = YES;
  button.layer.borderWidth = 1.0;
  button.layer.borderColor = [[UIColor whiteColor] CGColor];
  [button sizeToFit];

  CGRect _center = CGRectMake(_lastx,
    [[ToolboxModule sharedInstance] center:button.frame superview:self.frame type:2], button.frame.size.width + 10,
    button.frame.size.height + 10);
  _lastx += 10 + _center.size.width;
  [button setFrame:_center];

  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:_selector];
  [button setUserInteractionEnabled:YES];
  [button addGestureRecognizer:tap];

  [self addSubview:button];
}

-(void)layoutSubviews {
  [super layoutSubviews];

  [self addButton:@"Respring" selector:@selector(respring)];
  [self addButton:@"Power down" selector:@selector(powerdown)];
  [self addButton:@"Reboot" selector:@selector(reboot)];
}

-(void)respring {
  SpringBoard *sb = (SpringBoard *)[%c(SpringBoard) sharedApplication];
  if ([sb respondsToSelector:@selector(relaunchSpringBoard)]) {
    [sb _relaunchSpringBoardNow];
  } else {
    FBSSystemService *service = [%c(FBSSystemService) sharedService];
    NSSet *actions = [NSSet setWithObject:[%c(SBSRelaunchAction) actionWithReason:@"RestartRenderServer" options:4 targetURL:nil]];
    [service sendActions:actions withResult:nil];
  }
}

-(void)powerdown {
  SpringBoard *sb = (SpringBoard *)[%c(SpringBoard) sharedApplication];
  [sb powerDown];
}

-(void)reboot {
  SpringBoard *sb = (SpringBoard *)[%c(SpringBoard) sharedApplication];
  [sb reboot];
}
@end