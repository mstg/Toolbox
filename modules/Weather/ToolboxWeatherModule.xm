/*
* @Author: mustafa
* @Date:   2016-08-08 21:51:58
* @Last Modified by:   mstg
* @Last Modified time: 2016-08-12 20:37:09
*/

#include "ToolboxWeatherModule.h"
#include <dlfcn.h>
#include <xpc/xpc.h>

typedef void(^comp)(NSString *ret, NSString *loc, NSString *condition, City *city_obj);

static void update_temp(comp _comp) {
  xpc_object_t connection = xpc_connection_create_mach_service("no.gezen.toolboxweatherdaemon", NULL, 0);
  xpc_connection_set_event_handler(connection, ^(xpc_object_t obj) {});

  xpc_connection_resume(connection);
  xpc_object_t object = xpc_dictionary_create(NULL, NULL, 0);
  xpc_dictionary_set_string(object, "message", "GiefLocation");

  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);

  xpc_connection_send_message_with_reply(connection, object, dispatch_get_main_queue(), ^(xpc_object_t reply) {
    size_t length;
    const void *bytes = xpc_dictionary_get_data(reply, "message", &length);

    NSData *bytesData = [NSData dataWithBytes:bytes length:length];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:bytesData];

    id obj = [array objectAtIndex:0];

    if ([obj isKindOfClass:[CLLocation class]]) {
      CLLocation *currentLocation = (CLLocation*)obj;
      City *city = [[City alloc] init];
      [city setLocation:currentLocation];
      [city update];

      dispatch_async(queue, ^{
        while (true) {
          if ([[city temperature] isEqual:@"--"]) {
            usleep(200);
          } else {
            HBLogDebug(@"Temperature callback");
            NSString *_cond = [city naturalLanguageDescriptionWithDescribedCondition:nil];
            NSArray *_condArr = [_cond componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
            _comp([city temperature], (NSString*)[array objectAtIndex:1], [_condArr objectAtIndex:0], city);
            break;
          }
        }
      });
    } else {
      _comp(@"--", @"", @"", nil);
    }

    xpc_connection_cancel(connection);
  });
}

@implementation ToolboxWeatherModule
+(void)load {
  [[ToolboxModule sharedInstance] registerModule:[[ToolboxWeatherModule alloc] init]];
}

-(ToolboxWeatherModule*)init {
  self = [super init];

  if (self) {
    SBApplication *weatherApp = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:@"com.apple.weather"];
    SBApplicationIcon *weatherAppIcon = [[%c(SBApplicationIcon) alloc] initWithApplication:weatherApp];

    SBIconView *app = [[%c(SBIconView) alloc] initWithContentType:1];
    [app setIcon:weatherAppIcon];
    [self setAppIcon:(UIView*)app];
  }

  return self;
}

-(void)layoutSubviews {
  [super layoutSubviews];

  dynamic = [[WUIDynamicWeatherBackground alloc] initWithFrame:self.frame];
  [dynamic retain];
  [self addSubview:dynamic];

  temperature = [[UILabel alloc] initWithFrame:self.frame];
  temperature.textAlignment = NSTextAlignmentCenter;
  UIFont *font = [UIFont systemFontOfSize:43 weight:UIFontWeightUltraLight];
  temperature.font = font;
  temperature.textColor = [UIColor whiteColor];
  [temperature retain];

  city = [[UILabel alloc] initWithFrame:self.frame];
  city.textAlignment = NSTextAlignmentCenter;
  UIFont *_font = [UIFont systemFontOfSize:24 weight:UIFontWeightUltraLight];
  city.font = _font;
  city.textColor = [UIColor whiteColor];
  [city retain];

  cond = [[UILabel alloc] initWithFrame:self.frame];
  cond.textAlignment = NSTextAlignmentCenter;
  UIFont *__font = [UIFont systemFontOfSize:10 weight:UIFontWeightUltraLight];
  cond.font = __font;
  cond.textColor = [UIColor whiteColor];
  [cond retain];

  [dynamic addSubview:temperature];
  [dynamic addSubview:city];
  [dynamic addSubview:cond];

  /*SBIconView *app = (SBIconView*)[self appIcon];
  CGRect _centerApp = app.frame;
  _centerApp.origin.y = [[ToolboxModule sharedInstance] center:_centerApp superview:self.frame type:2];
  _centerApp.origin.x = 10;

  [app setFrame:_centerApp];
  [self addSubview:app];*/
}

-(void)viewUpdateWhenActive {
  dispatch_async(dispatch_get_main_queue(), ^{ 
    [temperature setText:@"--"];
    [city setText:@""];
    [cond setText:@""];
  });

  update_temp(^(NSString *updt, NSString *loc, NSString *condition, City *__city){
    dispatch_async(dispatch_get_main_queue(), ^{ 
      [dynamic setCity:__city animate:YES];
      NSString *_temperature = [NSString stringWithFormat:@"%@%@", updt, @"\u00B0"];
      [temperature setText:_temperature];
      [city setText:loc];
      [cond setText:condition];

      [city sizeToFit];
      [temperature sizeToFit];
      [cond sizeToFit];

      [city setFrame:CGRectMake([[ToolboxModule sharedInstance] center:city.frame superview:self.frame type:1],
        5, city.frame.size.width, city.frame.size.height)];
      [cond setFrame:CGRectMake([[ToolboxModule sharedInstance] center:cond.frame superview:self.frame type:1],
        city.frame.origin.y+city.frame.size.height, cond.frame.size.width, cond.frame.size.height)];
      [temperature setFrame:CGRectMake([[ToolboxModule sharedInstance] center:temperature.frame superview:self.frame type:1],
        cond.frame.origin.y+cond.frame.size.height, temperature.frame.size.width, temperature.frame.size.height)];
    });
  });
}

-(void)dealloc {
  [super dealloc];
  [temperature release];
  [city release];
  [cond release];
  [dynamic release];
}
@end