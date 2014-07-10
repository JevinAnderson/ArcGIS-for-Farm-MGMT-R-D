//
//  TemperatureGraphViewController.m
//  ArcGIS-for-Farm-MGMT-R-D
//
//  Created by Jevin Anderson on 7/10/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import "TemperatureGraphViewController.h"
#import "JBLineChartView.h"
#import "Voronoi.h"
#import "Weather.h"

/*
 Taken from JBChart sample app
 */
#define JBLineChartLineSolid 0
#define kJBColorLineChartControllerBackground UIColorFromHex(0xb7e3e4)
#define kJBColorLineChartBackground UIColorFromHex(0xb7e3e4)
#define kJBColorLineChartHeader UIColorFromHex(0x1c474e)
#define kJBColorLineChartHeaderSeparatorColor UIColorFromHex(0x8eb6b7)
#define kJBColorLineChartDefaultSolidLineColor [UIColor colorWithWhite:1.0 alpha:0.5]
#define kJBColorLineChartDefaultSolidSelectedLineColor [UIColor colorWithWhite:1.0 alpha:1.0]
#define kJBColorLineChartDefaultDashedLineColor [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
#define kJBColorLineChartDefaultDashedSelectedLineColor [UIColor colorWithWhite:1.0 alpha:1.0]

@interface TemperatureGraphViewController ()<JBLineChartViewDataSource, JBLineChartViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeOfAverageLabel;

@property (strong, nonatomic) Weather *weather;
@property (strong, nonatomic) JBLineChartView *lineChartView;

@end

@implementation TemperatureGraphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _detailView.hidden = YES;
    _weather = [Weather sharedInstance];
    
    _lineChartView = [JBLineChartView new];
    _lineChartView.delegate = self;
    _lineChartView.dataSource = self;
    _lineChartView.frame = _graphView.bounds;
    [_graphView addSubview:_lineChartView];
    [_lineChartView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"MonthlyWeatherStatisticsHaveBeenUpdated" object:nil];
}

-(void)reloadData
{
    [_lineChartView reloadData];
}

-(NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return 2;
}

-(NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return 12;
}

-(CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    if (lineIndex == 0) {
        NSString *month = [NSString stringWithFormat:@"%02lu", (unsigned long)horizontalIndex + 1];
        if (_weather.monthlyStatistics && _weather.monthlyStatistics[month]) {
            CGFloat numberOfDaysRecorded = [_weather.monthlyStatistics[month][0] floatValue];
            CGFloat totalTemp = [_weather.monthlyStatistics[month][2] floatValue];
            
            return totalTemp / numberOfDaysRecorded;
        }else{
            return (arc4random() % 5) + .5f;
        }
    }else{
        return [self averageMonthlyTempForContinUSByMonth:horizontalIndex];
    }
}

-(CGFloat)averageMonthlyTempForContinUSByMonth:(NSInteger)month
{
    CGFloat temp;
    
    switch (month) {
        case 0:
            return 30.81;
            break;
        case 1:
            return 34.65;
            break;
        case 2:
            return 42.56;
            break;
        case 3:
            return 52.02;
            break;
        case 4:
            return 61.04;
            break;
        case 5:
            return 69.25;
            break;
        case 6:
            return 74.29;
            break;
        case 7:
            return 72.77;
            break;
        case 8:
            return 65.42;
            break;
        case 9:
            return 54.77;
            break;
        case 10:
            return 42.51;
            break;
        case 11:
            return 33.38;
            break;
        default:
            break;
    }
    
    return temp;
}

-(CGFloat)lineChartView:(JBLineChartView *)lineChartView dotRadiusForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == 0) ? 0.0 : 8.0;
}

-(CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == 0) ? 6.0 : 2.0;
}

-(UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidLineColor: kJBColorLineChartDefaultDashedLineColor;
}

-(UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidLineColor: kJBColorLineChartDefaultDashedLineColor;
}

-(UIColor *)verticalSelectionColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor whiteColor];
}

-(UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidSelectedLineColor: kJBColorLineChartDefaultDashedSelectedLineColor;
}

-(UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSolid) ? kJBColorLineChartDefaultSolidSelectedLineColor: kJBColorLineChartDefaultDashedSelectedLineColor;
}

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSolid) ? JBLineChartViewLineStyleSolid : JBLineChartViewLineStyleDashed;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == JBLineChartViewLineStyleDashed;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == JBLineChartViewLineStyleSolid;
}

-(void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    _detailView.hidden = NO;
    
    if (lineIndex == 0) {
        _typeOfAverageLabel.text = @"Feature Average";
        NSString *month = [NSString stringWithFormat:@"%02lu", (unsigned long)horizontalIndex + 1];
        if (_weather.monthlyStatistics[month]) {
            CGFloat numberOfDaysRecorded = [_weather.monthlyStatistics[month][0] floatValue];
            CGFloat totalTemp = [_weather.monthlyStatistics[month][2] floatValue];
            
            _temperatureLabel.text = [NSString stringWithFormat:@"%.1f°F", totalTemp / numberOfDaysRecorded];
        }else{
            _temperatureLabel.text = [NSString stringWithFormat:@"N/A"];
        }
    }else{
        _typeOfAverageLabel.text = @"National Average";
        _temperatureLabel.text = [NSString stringWithFormat:@"%.1f°F", [self averageMonthlyTempForContinUSByMonth:horizontalIndex]];
    }
}

-(void)didUnselectLineInLineChartView:(JBLineChartView *)lineChartView
{
    _detailView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
