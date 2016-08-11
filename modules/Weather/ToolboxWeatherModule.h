/*
* @Author: mustafa
* @Date:   2016-08-08 21:53:20
* @Last Modified by:   mustafa
* @Last Modified time: 2016-08-10 06:21:07
*/

#include "../ToolboxModule.h"
#import <CoreLocation/CoreLocation.h>

@interface WUIDynamicWeatherBackground : UIView
-(void)setCity:(id)arg1 animate:(BOOL)arg2;
@end

@interface City : NSObject
-(void)setLocation:(CLLocation *)arg1;
-(id)init;
-(void)update;
-(void)updateTimeZoneWithCompletionBlock:(/*^block*/id)arg1 ;
-(NSString *)temperature;
-(NSString*)naturalLanguageDescriptionWithDescribedCondition:(out long long*)arg1;
@end

@interface ToolboxWeatherModule : ToolboxModule {
  UILabel *temperature;
  UILabel *city;
  UILabel *cond;
  WUIDynamicWeatherBackground *dynamic;
}
-(ToolboxWeatherModule*)init;
@end