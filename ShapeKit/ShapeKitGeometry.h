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
#import <geos_c.h>
#import <proj_api.h>


@interface ShapeKitGeometry : NSObject {
    NSString *wktGeom;
    NSString *geomType;
	NSString *projDefinition;
    GEOSGeometry *geosGeom;
    GEOSContextHandle_t handle;
	unsigned int numberOfCoords;
    CLLocationCoordinate2D *_coords;
    id _geometry;
}

@property (nonatomic) NSString *wktGeom;
@property (nonatomic) NSString *geomType;
@property (nonatomic) NSString *projDefinition;
@property (nonatomic) GEOSGeometry *geosGeom;
@property (nonatomic) unsigned int numberOfCoords;

-(id)initWithWKT:(NSString *) wkt;
-(id)initWithGeosGeometry:(GEOSGeometry *)geom;
-(void) reprojectTo:(NSString *)newProjectionDefinition;
void notice(const char *fmt,...);
void log_and_exit(const char *fmt,...);

@end

@interface ShapeKitPoint : ShapeKitGeometry
-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
@end

@interface ShapeKitPolyline : ShapeKitGeometry
-(id)initWithCoordinates:(CLLocationCoordinate2D[])coordinates count:(unsigned int)count;
@end

@interface ShapeKitPolygon : ShapeKitGeometry
-(id)initWithCoordinates:(CLLocationCoordinate2D[])coordinates count:(unsigned int)count;
@end