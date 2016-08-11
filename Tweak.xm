#import <objc/runtime.h>
#include <dlfcn.h>
#import "import.h"
#import "ToolboxView.h"
#import "ToolboxListModulesView.h"
#import "modules/ToolboxModule.h"

%hook SBDockView
static char _dockKey;
static char _dockViewKey;
static char _tbViewKey;
static BOOL _tbVisible = false;

-(id)initWithDockListView:(SBDockIconListView*)dock forSnapshot:(BOOL)arg2 {
  SBDockView *orig = %orig;
  CGRect _dockFrame = dock.frame;
  objc_setAssociatedObject(self, &_dockKey, dock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(self, &_dockViewKey, orig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  UISwipeGestureRecognizer *showTB = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showTB:)];
  showTB.direction = UISwipeGestureRecognizerDirectionRight;
  [orig addGestureRecognizer:showTB];

  UISwipeGestureRecognizer *hideTB = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideTB:)];
  hideTB.direction = UISwipeGestureRecognizerDirectionUp;
  [orig addGestureRecognizer:hideTB];

  ToolboxView *tbview = [[ToolboxView alloc] initWithFrame:_dockFrame];

  [ToolboxModule sharedInstanceWithTB:tbview];

  NSFileManager *fm = [NSFileManager defaultManager];
  NSArray *_dir_content = [fm contentsOfDirectoryAtPath:@"/Library/Toolbox" error:nil];
  NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.dylib'"];
  NSArray *dylibs = [_dir_content filteredArrayUsingPredicate:fltr];

  for (NSString *dylib in dylibs) {
    dlopen([[NSString stringWithFormat:@"/Library/Toolbox/%@", dylib] UTF8String], RTLD_NOW);
    HBLogInfo(@"Toolbox - Load module (%@)", dylib);
  }

  [tbview initMenu];

  [tbview setAlpha:0];
  tbview.hidden = YES;
  [orig addSubview:tbview];

  objc_setAssociatedObject(self, &_tbViewKey, tbview, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  return orig;
}

%new
-(void)showTB:(UISwipeGestureRecognizer*)recognizer {
  if (recognizer.direction == UISwipeGestureRecognizerDirectionRight && (!_tbVisible || [[ToolboxModule sharedInstance] activeView] != nil)) {
    HBLogDebug(@"Swiped right");

    SBDockIconListView *dock = objc_getAssociatedObject(self, &_dockKey);
    ToolboxView *tbview = objc_getAssociatedObject(self, &_tbViewKey);
    [tbview showMenu];
    //SBDockView *dockView = objc_getAssociatedObject(self, &_dockViewKey);
    _tbVisible = true;

    tbview.hidden = NO;

    [UIView animateWithDuration:0.3
      delay:0.0
      options:UIViewAnimationOptionCurveEaseOut
      animations:^{
        [dock setAlpha:0];
        [tbview setAlpha:1];
        //[tbview updateViews];
        MSHookIvar<UIView*>(self, "_iconListView") = (UIView*)tbview;
      }
      completion:^(BOOL finished){
        if (finished) {
          dock.hidden = YES;
        }
      }];
  }
}

%new
-(void)hideTB:(UISwipeGestureRecognizer*)recognizer {
  if (recognizer.direction == UISwipeGestureRecognizerDirectionUp && _tbVisible) {
    HBLogDebug(@"Swiped up");

    SBDockIconListView *dock = objc_getAssociatedObject(self, &_dockKey);
    ToolboxView *tbview = objc_getAssociatedObject(self, &_tbViewKey);
    _tbVisible = false;
    dock.hidden = NO;

    [UIView animateWithDuration:0.3
      delay:0.0
      options:UIViewAnimationOptionCurveEaseOut
      animations:^{
        [dock setAlpha:1];
        [tbview setAlpha:0];
        MSHookIvar<UIView*>(self, "_iconListView") = (UIView*)dock;
      }
      completion:^(BOOL finished) {
        if (finished) {
          tbview.hidden = YES;
        }
      }];
  }
}
%end