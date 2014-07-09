//
//  ThiessenViewController.m
//  ArcGIS-for-Farm-MGMT-R-D
//
//  Created by Jevin Anderson on 7/9/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import "ThiessenViewController.h"
#import "Voronoi.h"
#import <ArcGIS/ArcGIS.h>

@interface ThiessenViewController ()<AGSMapViewLayerDelegate, AGSMapViewTouchDelegate, AGSLayerDelegate, AGSFeatureLayerQueryDelegate>
@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property (weak, nonatomic) AGSFeatureLayer *featureLayer;
@property (strong, nonatomic) Voronoi *voronoi;

@end

@implementation ThiessenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AGSGeometryEngine defaultGeometryEngine];
    
    _voronoi = [Voronoi new];
    _voronoi.mapView = _mapView;
    
    NSURL* url = [NSURL URLWithString:@"http://services.arcgisonline.com/ArcGIS/rest/services/Ocean_Basemap/MapServer"];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [self.mapView addMapLayer:tiledLayer withName:@"Basemap Tiled Layer"];
    _mapView.layerDelegate = self;
    _mapView.touchDelegate = self;
    
    url = [NSURL URLWithString:@"http://services.arcgis.com/V6ZHFr6zdgNZuVG0/ArcGIS/rest/services/U2/FeatureServer/0"];
    AGSFeatureLayer *featureLayer = [[AGSFeatureLayer alloc] initWithURL:url mode:AGSFeatureLayerModeOnDemand];
    [_mapView addMapLayer:featureLayer withName:@"Concert Layer"];
    featureLayer.delegate = self;
    _featureLayer = featureLayer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)layer:(AGSLayer *)layer didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Layer failed to load with error: %@", error.localizedDescription);
}

-(void)layerDidLoad:(AGSLayer *)layer
{
    NSLog(@"Layer loaded: %@", layer);
    if (layer == _featureLayer) {
        NSLog(@"And that's a bingo!");
        AGSQuery *query = [AGSQuery new];
        query.where = @"1=1";
        query.outFields = @[@"*"];
        query.returnGeometry = YES;
        _featureLayer.queryDelegate = self;
        [_featureLayer queryFeatures:query];
    }
}

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation *)op didFailQueryFeaturesWithError:(NSError *)error
{
    NSLog(@"Feature layer failed query: %@", error.localizedDescription);
}

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation *)op didQueryFeaturesWithFeatureSet:(AGSFeatureSet *)featureSet
{
    NSLog(@"Feature layer suceeded with Query");
    _voronoi.features = featureSet.features;
}
- (IBAction)voronoiAction:(id)sender
{
    [_voronoi addVoroniGraphicsToTheMapView];
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
