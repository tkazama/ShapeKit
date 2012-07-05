//
//  ShapeKit+MapKit.h
//  ShapeKit
//
//  Created by Andrea Cremaschi on 27/06/12.
//
// * This is free software; you can redistribute and/or modify it under
// the terms of the GNU Lesser General Public Licence as published
// by the Free Software Foundation. 
// See the COPYING file for more information.
//
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ShapeKitGeometry.h"

@interface ShapeKitGeometry (MapKit)
@property (readonly) MKShape *geometry;

@end

@interface ShapeKitPoint (MapKit)
@property (readonly) MKPointAnnotation *geometry;

@end

@interface ShapeKitPolyline (MapKit)
@property (readonly) MKPolyline *geometry;
@end

@interface ShapeKitPolygon (MapKit)
@property (readonly) MKPolygon *geometry;
@end