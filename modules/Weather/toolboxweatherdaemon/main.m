#include <xpc/xpc.h>
#import <CoreLocation/CoreLocation.h>

@interface CLPlacemark (Daemon) //WTH DO I NEED THIS????
-(NSString *)locality;
@end

@interface ToolboxWeatherDaemonObj : NSObject<CLLocationManagerDelegate> {
  xpc_object_t _obj;
}
-(ToolboxWeatherDaemonObj*)initWithXpcObj:(xpc_object_t)obj;
@end

@implementation ToolboxWeatherDaemonObj
-(ToolboxWeatherDaemonObj*)initWithXpcObj:(xpc_object_t)obj {
  self = [super init];
  if (self) {
    _obj = obj;
    [_obj retain];
    CLLocationManager *locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    [locationManager startUpdatingLocation];
    HBLogDebug(@"Update");
  }
  return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  CLLocation *currentLocation = [locations objectAtIndex:0];
  [manager stopUpdatingLocation];

  xpc_object_t reply = xpc_dictionary_create_reply(_obj);
  if (reply) {
    HBLogDebug(@"Send CL");

    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
      NSString *locString = @"";

      if (placemarks.count > 0) {
        CLPlacemark *pl = [placemarks objectAtIndex:0];
        locString = [pl locality];
      }

      NSArray *_temp_data = @[currentLocation, locString];
      NSData *_data = [NSKeyedArchiver archivedDataWithRootObject:_temp_data];

      xpc_dictionary_set_data(reply, "message", [_data bytes], [_data length]);
      xpc_connection_send_message(xpc_dictionary_get_remote_connection(_obj), reply);
    }];
  }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError*)error {
  xpc_object_t reply = xpc_dictionary_create_reply(_obj);
  if (reply) {
    NSArray *_temp_data = @[@"ErrLocationServicesNotEnabled"];
    NSData *_data = [NSKeyedArchiver archivedDataWithRootObject:_temp_data];

    xpc_dictionary_set_data(reply, "message", [_data bytes], [_data length]);
    xpc_connection_send_message(xpc_dictionary_get_remote_connection(_obj), reply);
  }
}

-(void)dealloc {
  [super dealloc];
  [_obj release];
}

@end

int main(int argc, char **argv, char **envp) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  xpc_connection_t connection = xpc_connection_create_mach_service("no.gezen.toolboxweatherdaemon", NULL, XPC_CONNECTION_MACH_SERVICE_LISTENER);
  if (!connection) {
    HBLogDebug(@"Failed to create XPC server. Exiting.");
    [pool release];
    return 0;
  }

  xpc_connection_set_event_handler(connection, ^(xpc_object_t object) {
    xpc_type_t type = xpc_get_type(object);
    if (type == XPC_TYPE_CONNECTION) {
      HBLogDebug(@"XPC server received incoming connection: %s", xpc_copy_description(object));

      xpc_connection_set_event_handler(object, ^(xpc_object_t some_object) {
          HBLogDebug(@"XPC connection received object: %s", xpc_copy_description(some_object));
          dispatch_async(dispatch_get_main_queue(), ^{
            [[ToolboxWeatherDaemonObj alloc] initWithXpcObj:some_object];
        });
      });
        xpc_connection_resume(object);
    } else if (type == XPC_TYPE_ERROR) {
      HBLogDebug(@"XPC server error: %s", xpc_dictionary_get_string(object, XPC_ERROR_KEY_DESCRIPTION));
    } else {
      HBLogDebug(@"XPC server received unknown object: %s", xpc_copy_description(object));
    }
  });

  xpc_connection_resume(connection);

  [[NSRunLoop currentRunLoop] run];

  [pool release];

  return 0;
}
