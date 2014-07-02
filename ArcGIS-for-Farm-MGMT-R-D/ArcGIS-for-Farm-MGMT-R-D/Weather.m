//
//  Weather.m
//  ArcGIS-for-Farm-MGMT-R-D
//
//  Created by Jevin Anderson on 7/2/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import "Weather.h"

@interface Weather ()

@end

@implementation Weather

-(void)getHistoricalWeatherForLatitude:(double)latitude andLongitude:(double)longitude
{
    NSURL *url = [self createHistoricalWeatherUrlFromLatitude:latitude andLongitude:longitude];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        if (connectionError) {
//            if ([_delegate respondsToSelector:@selector(weather:failedToGetHistoricalWeatherWithError:)]) {
//                [_delegate weather:self failedToGetHistoricalWeatherWithError:nil];
//            }else{
//                NSLog(@"Weather collection error: %@", connectionError);
//            }
//        }else{
//            NSDictionary *historicalInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
//            [_delegate weather:self didSucceedInGettingHistoricalInfo:historicalInfo];
//        }
//    }];
}

-(NSURL *)createHistoricalWeatherUrlFromLatitude:(double)latitude andLongitude:(double)longitude
{
    NSString *baseUrlStr = @"http://api.wunderground.com/api/";
    NSString *apiKey = @"778edd5449d7cab9";
    NSString *optionsStr = @"/history_20060405/q/";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%lf,%lf.json", baseUrlStr, apiKey, optionsStr, latitude, longitude];
    
    NSLog(@"WEATHER LOOKUP: %@", urlString);
    
    return [NSURL URLWithString:urlString];
}

@end
