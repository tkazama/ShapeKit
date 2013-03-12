//
//  ShapeKitGeometry.h
//  ShapeKit
//
//  Created by Michael Weisman on 10-08-21.

// * This is free software; you can redistribute and/or modify it under
// the terms of the GNU Lesser General Public Licence as published
// by the Free Software Foundation. 
// See the COPYING file for more information.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface ShapeKitGeometry : NSObject

@property (readonly, copy) NSString *wktGeom;
@property (readonly, copy) NSString *geomType;
@property (readonly, copy) NSString *projDefinition;
@property (readonly) void *handle;
@property (readonly, nonatomic) unsigned int numberOfCoords;

-(CLLocationCoordinate2D) coordinateAtIndex: (NSInteger) index;

-(id)initWithWKB:(const unsigned char *) wkb size:(size_t)wkb_size;
-(id)initWithWKT:(NSString *) wkt;
-(id)initWithGeosGeometry:(void *)geom;
-(void) reprojectTo:(NSString *)newProjectionDefinition;

@end

// Simple objects

@interface ShapeKitPoint : ShapeKitGeometry
@property (readonly) CLLocationCoordinate2D coordinate;
-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
@end

@interface ShapeKitPolyline : ShapeKitGeometry
-(id)initWithCoordinates:(CLLocationCoordinate2D[])coordinates count:(unsigned int)count;
@end

@interface ShapeKitPolygon : ShapeKitGeometry
-(id)initWithCoordinates:(CLLocationCoordinate2D[])coordinates count:(unsigned int)count;
@property (readonly) NSArray *interiors;
@end


// Geometry collections

@interface ShapeKitGeometryCollection : ShapeKitGeometry
- (NSUInteger) numberOfGeometries;
- (ShapeKitGeometry*) geometryAtIndex: (NSInteger) index;
@end

@interface ShapeKitMultiPolyline : ShapeKitGeometryCollection
- (NSUInteger) numberOfPolylines;
- (ShapeKitPolyline*) polylineAtIndex: (NSInteger) index;
@end

@interface ShapeKitMultiPoint : ShapeKitGeometryCollection
- (NSUInteger) numberOfPoints;
- (ShapeKitPoint*) pointAtIndex: (NSInteger) index;
@end

@interface ShapeKitMultiPolygon : ShapeKitGeometryCollection
- (NSUInteger) numberOfPolygons;
- (ShapeKitPolygon*) polygonAtIndex: (NSInteger) index;
@end