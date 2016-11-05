/**
 * Ti.Geo.SignificantChange
 *
 * Created by Ben Bahrenburg
 * Copyright (c) 2015 bencoding.com, All rights reserved.
 */

#import "TiModule.h"
#import <CoreLocation/CoreLocation.h>
@interface TiGeoSignificantchangeModule : TiModule< CLLocationManagerDelegate >
{
@private
    CLActivityType activityType;
    BOOL pauseLocationUpdateAutomatically;
}

@property(strong, nonatomic) CLLocationManager* locationManager;

@end
