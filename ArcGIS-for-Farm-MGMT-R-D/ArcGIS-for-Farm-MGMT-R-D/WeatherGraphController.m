//
//  SecondViewController.m
//  ArcGIS-for-Farm-MGMT-R-D
//
//  Created by Jevin Anderson on 7/2/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import "WeatherGraphController.h"
#import "JBBarChartView.h"
#import "Weather.h"
/*
 Taken from JBChart sample app
 */
#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]


@interface WeatherGraphController ()<JBBarChartViewDataSource, JBBarChartViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *barChartContainer;
@property (weak, nonatomic) IBOutlet UIView *statisticDisplayView;
@property (weak, nonatomic) IBOutlet UILabel *inchesLabel;
@property (strong, nonatomic) JBBarChartView *barChartView;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;
@property (weak, nonatomic) Weather *weather;

@end

@implementation WeatherGraphController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _weather = [Weather sharedInstance];
    _statisticDisplayView.hidden = YES;
    
    JBBarChartView *barChartView = [JBBarChartView new];
    barChartView.delegate = self;
    barChartView.dataSource = self;
    [_barChartContainer addSubview:barChartView];
    barChartView.frame = _barChartContainer.bounds;
    [barChartView reloadData];
    _barChartView = barChartView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"MonthlyWeatherStatisticsHaveBeenUpdated" object:nil];
}

-(void)reloadData
{
    _dateRangeLabel.text = ([_weather.startYear isEqualToString:_weather.endYear]) ? _weather.startYear : [NSString stringWithFormat:@"%@ - %@", _weather.startYear, _weather.endYear];
    [_barChartView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return 12;
}

-(CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtAtIndex:(NSUInteger)index
{
    if (_weather.monthlyStatistics) {
        NSString *month = [NSString stringWithFormat:@"%02lu", (unsigned long)index + 1];
        if (_weather.monthlyStatistics[month]) {
            CGFloat numberOfDaysRecorded = [_weather.monthlyStatistics[month][0] floatValue];
            CGFloat totalPrecip = [_weather.monthlyStatistics[month][1] floatValue];
            
            return totalPrecip / numberOfDaysRecorded;
        }else{
            return 0;
        }
    }else{
        if (index % 2 == 0) {
            return 2 * (6 - abs((int)index - 6));
        }else{
            return 6 - abs((int)index - 6);
        }
    }
}

-(UIColor *)barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
{
    return (index % 2 == 0) ? UIColorFromHex(0x08bcef) : UIColorFromHex(0x34b234);
}

- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView
{
    return [UIColor whiteColor];
}

- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    _statisticDisplayView.hidden = NO;
    NSLog(@"Did select bar at index: %02lu", (unsigned long)index);
    NSString *month = [NSString stringWithFormat:@"%02lu", (unsigned long)index + 1];
    if (_weather.monthlyStatistics[month]) {
        CGFloat numberOfDaysRecorded = [_weather.monthlyStatistics[month][0] floatValue];
        CGFloat totalPrecip = [_weather.monthlyStatistics[month][1] floatValue];
        
        _inchesLabel.text = [NSString stringWithFormat:@"%.2f in", totalPrecip / numberOfDaysRecorded];
    }else{
        _inchesLabel.text = [NSString stringWithFormat:@"N/A"];
    }

}

- (void)didUnselectBarChartView:(JBBarChartView *)barChartView
{
    _statisticDisplayView.hidden = YES;
}

@end
