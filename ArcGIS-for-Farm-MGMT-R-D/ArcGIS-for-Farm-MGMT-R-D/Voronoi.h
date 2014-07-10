//
//  Voronoi.h
//  ArcGIS-for-Farm-MGMT-R-D
//
//  Created by Jevin Anderson on 7/9/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AGSMapView;

@interface Voronoi : NSObject

@property (weak, nonatomic) AGSMapView *mapView;
@property (strong, nonatomic) NSArray *features;

-(UIColor *)createRandomColor;
-(void)addVoroniGraphicsToTheMapView;

@end
