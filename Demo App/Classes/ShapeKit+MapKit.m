//
//  ShapeKit+MapKit.m
//  ShapeKit
//
//  Created by Andrea Cremaschi on 27/06/12.
//  Copyright (c) 2012 independent. All rights reserved.
//

#import "ShapeKit+MapKit.h"
#import <MapKit/MapKit.h>

@implementation ShapeKitPoint (MapKit)
- (MKPointAnnotation *)geometry
{
    if (!_geometry) {
        _geometry = [[MKPointAnnotation alloc] init];
        [(MKPointAnnotation *)_geometry setCoordinate: _coords[0]];
    }
    return _geometry;
}
@end

@implementation ShapeKitPolyline (MapKit)
- (MKPolyline *)geometry
{
    if (!_geometry) {
        _geometry = [MKPolyline polylineWithCoordinates:_coords count: numberOfCoords];
    }
    return _geometry;
}

@end

@implementation ShapeKitPolygon (MapKit)
- (MKPolygon *)geometry
{
    if (!_geometry) {
        _geometry = [MKPolygon polygonWithCoordinates:_coords count: numberOfCoords];
    }
    return _geometry;
}

@end
