//
//  FirstViewController.m
//  ArcGIS-for-Farm-MGMT-R-D
//
//  Created by Jevin Anderson on 7/2/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import "MapViewController.h"
#import <ArcGIS/ArcGIS.h>
#import "Weather.h"

@interface MapViewController ()<AGSCalloutDelegate, AGSWebMapDelegate, WeatherDelegate>
@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property (strong, nonatomic) AGSWebMap *webMap;
@property (strong, nonatomic) AGSGraphicsLayer *graphicsLayer;
@property (weak, nonatomic) AGSGraphic *currentGraphic;
@property unsigned long currentFeatureId;
@property double latitude, longitude;

@property (strong, nonatomic) Weather *weather;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_mapView enableWrapAround];
    _mapView.callout.delegate = self;
    
    _webMap = [[AGSWebMap alloc] initWithItemId:@"0ab0004e243641568713ba968d1c424a" credential:nil];
    _webMap.delegate = self;
    
    _weather = [Weather sharedInstance];
    _weather.delegate = self;
}

- (void) webMapDidLoad:(AGSWebMap*) webMap
{
    [webMap openIntoMapView:_mapView];
}

- (void) webMap:(AGSWebMap *)webMap didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Error while loading webmap: %@",[error localizedDescription]);
}

-(void)didOpenWebMap:(AGSWebMap*)webMap intoMapView:(AGSMapView*)mapView
{
   	_graphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [_mapView addMapLayer:_graphicsLayer withName:@"State graphics layer"];

}

-(BOOL)callout:(AGSCallout *)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable> *)layer mapPoint:(AGSPoint *)mapPoint
{
    AGSGeometry *geometry = feature.geometry;
    AGSSimpleFillSymbol *fillSymbol = [[AGSSimpleFillSymbol alloc] initWithColor:[UIColor grayColor] outlineColor:[UIColor purpleColor]];
    AGSGraphic *mapgraphic = [[AGSGraphic alloc] initWithGeometry:geometry symbol:fillSymbol attributes:nil];
    if(_currentGraphic){
        [_graphicsLayer removeGraphic:_currentGraphic];
    }
    [_graphicsLayer addGraphic:mapgraphic];
    _currentGraphic = mapgraphic;
    
    AGSSpatialReference *webRef = [[AGSSpatialReference alloc] initWithWKID:WKID_WGS84];
    AGSPoint *newPoint = (AGSPoint *)[[AGSGeometryEngine defaultGeometryEngine] projectGeometry:geometry.envelope.center toSpatialReference:webRef];
    _currentFeatureId = (unsigned long)[feature featureId];
    _latitude = newPoint.y;
    _longitude = newPoint.x;
    NSLog(@"Lat: <%lf> - Lon: <%lf>", _latitude, _longitude);
    
    
    [self startDataFetchingCycle];
    
    return NO;
}

-(void)startDataFetchingCycle
{
    static BOOL alreadyStartedFetching = NO;
    if (!alreadyStartedFetching) {
        alreadyStartedFetching = YES;
        [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(fetchWeather:) userInfo:nil repeats:YES];
    }
}

-(void)fetchWeather:(NSTimer *)timer
{
    [_weather getHistoricalWeatherForFeature:[NSString stringWithFormat:@"%lu", _currentFeatureId]
                                    latitude:_latitude
                                andLongitude:_longitude];
}

-(void)weather:(Weather *)weather failedToGetHistoricalWeatherWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve historical data with error: %@", error);
}

-(void)weather:(Weather *)weather didSucceedInGettingHistoricalInfo:(NSDictionary *)historicalInfo
{
    
    static BOOL wascalled = false;
    if (!wascalled) {
        wascalled = true;
        //NSLog(@"Historical Information: %@", historicalInfo);
        NSLog(@"%@", historicalInfo[@"history"][@"dailysummary"][0][@"precipi"]);
    }
}

-(void)didClickAccessoryButtonForCallout:(AGSCallout *)callout
{
    NSLog(@"didclickaccessoryButtonforcallout");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
