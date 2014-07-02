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
    
    _weather = [Weather new];
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

-(void)webMap:(AGSWebMap*)wm didLoadLayer:(AGSLayer*)layer
{
    
}

-(void)webMap:(AGSWebMap*)wm didFailToLoadLayer:(NSString*)layerTitle url:(NSURL*)url baseLayer:(BOOL)baseLayer federated:(BOOL)federated withError:(NSError*)error
{
    NSLog(@"Error while loading layer: %@",[error localizedDescription]);
    
    //you can skip loading this layer
    //[self.webMap continueOpenAndSkipCurrentLayer];
    
    //or you can try loading it with proper credentials if the error was security related
    //[self.webMap continueOpenWithCredential:credential];
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
    double latitude = newPoint.y;
    double longitude = newPoint.x;
    NSLog(@"Lat: <%lf> - Lon: <%lf>", latitude, longitude);
    
    [_weather getHistoricalWeatherForLatitude:latitude andLongitude:longitude];
    return NO;
}

-(void)weather:(Weather *)weather failedToGetHistoricalWeatherWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve historical data with error: %@", error);
}

-(void)weather:(Weather *)weather didSucceedInGettingHistoricalInfo:(NSDictionary *)historicalInfo
{
    NSLog(@"Historical Information: %@", historicalInfo);
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
