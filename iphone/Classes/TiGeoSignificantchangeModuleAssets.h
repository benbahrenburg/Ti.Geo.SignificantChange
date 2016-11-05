/**
 * Ti.Geo.SignificantChange
 *
 * Created by Ben Bahrenburg
 * Copyright (c) 2015 bencoding.com, All rights reserved.
 */

@interface TiGeoSignificantchangeModuleAssets : NSObject
{
}
- (NSData*) moduleAsset;
- (NSData*) resolveModuleAsset:(NSString*)path;

@end
