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

@interface WeatherGraphController ()<JBBarChartViewDataSource, JBBarChartViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *barChartContainer;
@property (strong, nonatomic) JBBarChartView *barChartView;
@property (weak, nonatomic) Weather *weather;

@end

@implementation WeatherGraphController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _weather = [Weather sharedInstance];
    
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
    return [UIColor blueColor];
}

- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView
{
    return [UIColor greenColor];
}

- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    
}

- (void)didUnselectBarChartView:(JBBarChartView *)barChartView
{
    NSLog(@"Unselected bar chart view");
}

@end
