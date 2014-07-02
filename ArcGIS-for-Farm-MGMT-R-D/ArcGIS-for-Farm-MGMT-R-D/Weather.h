//
//  Weather.h
//  ArcGIS-for-Farm-MGMT-R-D
//
//  Created by Jevin Anderson on 7/2/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WeatherDelegate;

@interface Weather : NSObject

@property (nonatomic, strong) id delegate;

-(void)getHistoricalWeatherForLatitude:(double)latitude andLongitude:(double)longitude;

@end

@protocol WeatherDelegate <NSObject>

@required
-(void)weather:(Weather *)weather didSucceedInGettingHistoricalInfo:(NSDictionary *)historicalInfo;

@optional
-(void)weather:(Weather *)weather failedToGetHistoricalWeatherWithError:(NSError * )error;

@end