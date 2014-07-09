//
//  Weather.m
//  ArcGIS-for-Farm-MGMT-R-D
//
//  Created by Jevin Anderson on 7/2/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import "Weather.h"
#import <CoreData/CoreData.h>

@interface Weather ()

@property (nonatomic, strong) NSString *featureID;

@end

@implementation Weather

+(instancetype)sharedInstance
{
    static Weather *weather;
    
    if (!weather) {
        weather = [[Weather alloc] initPrivate];
    }
    
    return weather;
}

-(instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *weatherDictionary = [userDefaults dictionaryForKey:@"PersonalWeatherInformation"];
        if (weatherDictionary) {
            _weatherDictionary = [[NSMutableDictionary alloc] initWithDictionary:weatherDictionary];
        }else{
            _weatherDictionary = [NSMutableDictionary new];
        }
    }
    
    return self;
}

-(instancetype)init
{
    @throw [NSException exceptionWithName:@"Bad init of a singleton class"
                                   reason:@"Use +[Weather sharedInstance]"
                                 userInfo:nil];
    return nil;
}

-(void)getHistoricalWeatherForFeature:(NSString *)featureId latitude:(double)latitude andLongitude:(double)longitude
{
    _lastFeatureSearchedFor = featureId;
    
    if (!_weatherDictionary[featureId]) {
        _weatherDictionary[featureId] = [NSMutableArray new];
    }
    
    NSURL *url = [self createHistoricalWeatherUrlForFeature:featureId withLatitude:latitude andLongitude:longitude];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            if ([_delegate respondsToSelector:@selector(weather:failedToGetHistoricalWeatherWithError:)]) {
                [_delegate weather:self failedToGetHistoricalWeatherWithError:nil];
            }else{
                NSLog(@"Weather collection error: %@", connectionError);
            }
        }else{
            NSDictionary *historicalInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
            [(NSMutableArray *)_weatherDictionary[featureId] addObject:historicalInfo];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:_weatherDictionary forKey:@"PersonalWeatherInformation"];
            [userDefaults synchronize];
            [_delegate weather:self didSucceedInGettingHistoricalInfo:historicalInfo];
        }
    }];
}

-(NSURL *)createHistoricalWeatherUrlForFeature:(NSString *)featureId withLatitude:(double)latitude andLongitude:(double)longitude
{
    NSString *baseUrlStr = @"http://api.wunderground.com/api/";
    NSString *apiKey = @"778edd5449d7cab9";
    NSString *optionsStr = [self createOptionsStrForFeature:featureId];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%lf,%lf.json", baseUrlStr, apiKey, optionsStr, latitude, longitude];
    
    NSLog(@"WEATHER LOOKUP: %@", urlString);
    
    return [NSURL URLWithString:urlString];
}

-(NSString *)createOptionsStrForFeature:(NSString *)featureId
{
    NSDictionary *lastWeather = [(NSMutableArray *)_weatherDictionary[featureId] lastObject];
    NSString *optionsStr;
    NSDateComponents *components;
    NSDate *date;
    
    if (lastWeather) {
        components = [NSDateComponents new];
        [components setDay:[(NSString *)lastWeather[@"history"][@"date"][@"mday"] integerValue]];
        [components setMonth:[(NSString *)lastWeather[@"history"][@"date"][@"mon"] integerValue]];
        [components setYear:[(NSString *)lastWeather[@"history"][@"date"][@"year"] integerValue]];
        date = [[NSCalendar currentCalendar] dateFromComponents:components];
        date = [date dateByAddingTimeInterval:-24*60*60];
    }else{
        date = [NSDate date];
    }
    
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
    optionsStr = [NSString stringWithFormat:@"/history_%ld%02ld%02ld/q/", (long)components.year, (long)components.month, (long)components.day];
    
    NSLog(@"Options String: %@", optionsStr);
    
    return optionsStr;
}

-(void)calculateStaticsForFeatureId:(NSString *)featureId
{
    _monthlyStatistics = [NSMutableDictionary new];
    
    NSMutableArray *historicalInformationArray = _weatherDictionary[featureId];
    for (NSDictionary *historicalInfo in historicalInformationArray) {
        NSString *month = historicalInfo[@"history"][@"dailysummary"][0][@"date"][@"mon"];
        NSString *precip = historicalInfo[@"history"][@"dailysummary"][0][@"precipi"];
        if ([precip isEqualToString:@"T"]) {
            continue;
        }
        
        if (!_monthlyStatistics[month]) {
            _monthlyStatistics[month] = [NSMutableArray arrayWithArray:@[@1, [NSNumber numberWithFloat:[precip floatValue]]]];
        }else{
            _monthlyStatistics[month][0] = [NSNumber numberWithInt:([(NSNumber *)_monthlyStatistics[month][0] intValue] + 1)];
            _monthlyStatistics[month][1] = [NSNumber numberWithFloat:([(NSNumber *)_monthlyStatistics[month][1] floatValue] + [precip floatValue])];
        }
    }
    _startYear = [historicalInformationArray lastObject][@"history"][@"dailysummary"][0][@"date"][@"year"];
    _endYear = [historicalInformationArray firstObject][@"history"][@"dailysummary"][0][@"date"][@"year"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MonthlyWeatherStatisticsHaveBeenUpdated" object:self];
}

@end
