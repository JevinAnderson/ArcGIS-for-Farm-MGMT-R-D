//
//  Voronoi.m
//  ArcGIS-for-Farm-MGMT-R-D
//
//  Created by Jevin Anderson on 7/9/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import "Voronoi.h"
#import <ArcGIS/ArcGIS.h>

@interface Voronoi ()

@property (strong, nonatomic) AGSEnvelope *visibleArea;
@property (strong, nonatomic) NSMutableArray *colors;
@property (strong, nonatomic) AGSGraphicsLayer *graphicLayer;

@end

@implementation Voronoi

const float screenHeight = ( 568.0f / 2.0f), screenWidth = ( 320.0f / 2.0f );
float height, width;

-(void)addVoroniGraphicsToTheMapView
{
    if (!_mapView || !_features) {
        return;
    }
    
    [self calcluatePixelSize];
    [self assignColorsToPoints];
    [self addGraphicsToMapView];
}

-(void)calcluatePixelSize
{
    _visibleArea = _mapView.visibleArea.envelope;
    
    height = ( _visibleArea.ymax - _visibleArea.ymin ) / screenHeight;
    width = ( _visibleArea.xmax - _visibleArea.xmin ) / screenWidth;
    
    NSLog( @"Height: %f", height );
    NSLog( @"Width: %f", width );
    
}

-(void)assignColorsToPoints
{
    _colors = [NSMutableArray arrayWithCapacity:_features.count];
    for (int i = 0; i < _features.count; i++){
        _colors[i] = [self createRandomColor];
    }
}

-(UIColor *)createRandomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

-(void)addGraphicsToMapView
{
    if (_graphicLayer) {
        [_mapView removeMapLayer:_graphicLayer];
    }
    
    _graphicLayer = [AGSGraphicsLayer graphicsLayer];
    [_mapView addMapLayer:_graphicLayer];
    
    float xmin = _visibleArea.xmin, xmax = _visibleArea.xmax, ymin = _visibleArea.ymin, ymax = _visibleArea.ymax;
    for ( float i = xmin; i < xmax; i+= width ) {
        NSLog(@"Iteration i: %f", i);
        for (float j = ymin; j < ymax; j += height) {
            AGSSpatialReference *spatialReference = _mapView.spatialReference;
            AGSPoint *point = [[AGSPoint alloc] initWithX:i y:j spatialReference:spatialReference];
            UIColor *fillColor = [self findColorForPoint:point];
            AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:i ymin:j xmax:i + width ymax:j + height spatialReference:spatialReference];
            AGSSimpleFillSymbol *fillSymbol = [[AGSSimpleFillSymbol alloc] initWithColor:fillColor outlineColor:nil];
            AGSGraphic *mapgraphic = [[AGSGraphic alloc] initWithGeometry:envelope symbol:fillSymbol attributes:nil];
            [_graphicLayer addGraphic:mapgraphic];
        }
    }
}

-(UIColor *)findColorForPoint:(AGSPoint *)point
{
    int index = 0;
    double distance, shortestDistance = DBL_MAX;
    
    int featureCount = (int)_features.count;
    
    for (int i = 0; i < featureCount; i++) {
        AGSGraphic *graphic = _features[i];
        distance = [[AGSGeometryEngine defaultGeometryEngine] distanceFromGeometry:point toGeometry:graphic.geometry.envelope.center];
        if (distance < shortestDistance) {
            shortestDistance = distance;
            index = i;
        }
    }
    
    return _colors[index];
}

@end
