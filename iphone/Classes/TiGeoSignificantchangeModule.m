/**
 * Ti.Geo.SignificantChange
 *
 * Created by Ben Bahrenburg
 * Copyright (c) 2015 bencoding.com, All rights reserved.
 */

#import "TiGeoSignificantchangeModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"
#import "BXBGeoSignChangeHelpers.h"

@implementation TiGeoSignificantchangeModule

@synthesize locationManager;

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"fd3b83d5-396b-4a7e-80a0-4554ca6987b0";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.geo.significantchange";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

    // activity Type by default
    activityType = CLActivityTypeOther;
    
    // pauseLocationupdateAutomatically by default NO
    pauseLocationUpdateAutomatically  = NO;
}

-(void)shutdown:(id)sender
{
    [self shutdownLocationManager];

	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup


#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}


-(NSNumber*)isSupported:(id)args
{
    BOOL isSupported = NO;
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        isSupported = YES;
    }
    //This can call this to let them know if this feature is supported
    return NUMBOOL(isSupported);
}
-(NSNumber*)wasLaunchedByGeo:(id)args
{
    BOOL hasGeoLauchedOption = NO;
    if ([[[TiApp app] launchOptions] objectForKey:UIApplicationLaunchOptionsLocationKey])
    {
        hasGeoLauchedOption=YES;
    }
    
    return NUMBOOL(hasGeoLauchedOption);
}

-(void)initLocationManager
{
    if (locationManager==nil)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        if([TiUtils isIOS9OrGreater]){
#if IS_XCODE_7
            locationManager.allowsBackgroundLocationUpdates = YES;
#endif
        }
        
        [locationManager setPausesLocationUpdatesAutomatically:pauseLocationUpdateAutomatically];
        [locationManager setActivityType:CLActivityTypeOther];
    }
    
}

- (void) startSignificantChange:(id)args
{
    //We need to be on the UI thread, or the Change event wont fire
    ENSURE_UI_THREAD(startSignificantChange,args);
    
    if(![CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"Signicant Location Monitoring Not Available",@"error",
                                  NUMBOOL(NO),@"success",nil];
        
        if ([self _hasListeners:@"error"])
        {
            [self fireEvent:@"error" withObject:errEvent];
        }
        return;
    }
    
    
    BXBGeoSignChangeHelpers * helpers = [[BXBGeoSignChangeHelpers alloc] init];
    
    if ([CLLocationManager locationServicesEnabled]== NO)
    {
        [helpers disabledLocationServiceMessage];
        return;
    }
    
    //If we need to startup location manager we do it here
    if (locationManager==nil)
    {
        [self initLocationManager];
    }
    
    [locationManager startMonitoringSignificantLocationChanges];
    
    NSDictionary *startEvent = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(YES),@"success",nil];
    
    if ([self _hasListeners:@"start"])
    {
        [self fireEvent:@"start" withObject:startEvent];
    }
    
}

- (void) stopSignificantChange:(id)args
{
    if (locationManager !=nil)
    {
        [locationManager stopMonitoringSignificantLocationChanges];
    }
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                           NUMBOOL(YES),@"success",nil];
    
    if ([self _hasListeners:@"stop"])
    {
        [self fireEvent:@"stop" withObject:event];
    }
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    @try
    {
        if ([self _hasListeners:@"change"]){
            
            BXBGeoSignChangeHelpers * helpers = [[BXBGeoSignChangeHelpers alloc] init];
            //Determine of the data is stale
            NSDate* eventDate = newLocation.timestamp;
            NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
            float staleLimit = [TiUtils floatValue:[self valueForUndefinedKey:@"staleLimit"]def:15.0];
            
            NSDictionary *todict = [helpers locationDictionary:newLocation];
            
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                                   todict,@"coords",
                                   NUMBOOL(YES),@"success",
                                   NUMBOOL((fabs(howRecent) < staleLimit)),@"stale",
                                   nil];
            
            
            [self fireEvent:@"change" withObject:event];
        }
    }
    @catch (NSException* ex)
    {
        NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:ex.reason,@"error",
                                  ex.name, @"code",
                                  NUMBOOL(NO),@"success",nil];
        
        if ([self _hasListeners:@"error"])
        {
            [self fireEvent:@"error" withObject:errEvent];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    
    @try
    {
        if ([self _hasListeners:@"change"]){
            
            CLLocation *location = [locations lastObject];
            
            BXBGeoSignChangeHelpers * helpers = [[BXBGeoSignChangeHelpers alloc] init];
            //Determine of the data is stale
            NSDate* eventDate = location.timestamp;
            NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
            float staleLimit = [TiUtils floatValue:[self valueForUndefinedKey:@"staleLimit"]def:15.0];
            
            NSDictionary *todict = [helpers locationDictionary:location];
            
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                                   todict,@"coords",
                                   NUMBOOL(YES),@"success",
                                   NUMBOOL((fabs(howRecent) < staleLimit)),@"stale",
                                   nil];
            
            
            [self fireEvent:@"change" withObject:event];
        }
    }
    @catch (NSException* ex)
    {
        NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:ex.reason,@"error",
                                  ex.name, @"code",
                                  NUMBOOL(NO),@"success",nil];
        
        if ([self _hasListeners:@"error"])
        {
            [self fireEvent:@"error" withObject:errEvent];
        }
    }
}

-(NSNumber*)pauseLocationUpdateAutomatically
{
    return NUMBOOL(pauseLocationUpdateAutomatically);
}

-(void)setPauseLocationUpdateAutomatically:(id)value
{
    if ([TiUtils isIOS6OrGreater]) {
        pauseLocationUpdateAutomatically = [TiUtils boolValue:value];
        TiThreadPerformOnMainThread(^{[locationManager setPausesLocationUpdatesAutomatically:pauseLocationUpdateAutomatically];}, NO);
    }
}

-(NSNumber*)activityType
{
    return NUMINT(activityType);
}

-(void)setActivityType:(NSNumber *)value
{
    if ([TiUtils isIOS6OrGreater]) {
        activityType = [TiUtils intValue:value];
        TiThreadPerformOnMainThread(^{[locationManager setActivityType:activityType];}, NO);
    }
    
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription],@"error",
                              NUMINT((int)[error code]), @"code",
                              NUMBOOL(NO),@"success",nil];
    
    if ([self _hasListeners:@"error"])
    {
        [self fireEvent:@"error" withObject:errEvent];
    }
}

//Force the calibration header to turn off
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return NO;
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    if ([self _hasListeners:@"locationupdatepaused"])
    {
        [self fireEvent:@"locationupdatepaused" withObject:nil];
    }
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    if ([self _hasListeners:@"locationupdateresumed"])
    {
        [self fireEvent:@"locationupdateresumed" withObject:nil];
    }
}

-(void)shutdownLocationManager
{
    
    if (locationManager == nil) {
        return;
    }
    
    [locationManager stopMonitoringSignificantLocationChanges];
    locationManager.delegate = nil;
    
}

@end
