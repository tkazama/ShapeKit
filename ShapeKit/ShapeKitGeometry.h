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

// Building Blocks : Point, LinearRing
/*
 typedef struct LinearRing   {
 unsigned int  numPoints;
 CLLocationCoordinate2D   points[1];
 } LinearRing;
 
 enum wkbGeometryType {
 wkbPoint = 1,
 wkbLineString = 2,
 wkbPolygon = 3,
 wkbMultiPoint = 4,
 wkbMultiLineString = 5,
 wkbMultiPolygon = 6
 };
 
 enum wkbByteOrder {
 wkbXDR = 0,     // Big Endian
 wkbNDR = 1     // Little Endian
 };
 
 typedef struct WKBPoint {
 unsigned char   byteOrder;
 unsigned int   wkbType;     // 1=wkbPoint
 CLLocationCoordinate2D    point;
 } WKBPoint;
 
 typedef struct WKBLineString {
 unsigned char     byteOrder;
 unsigned int   wkbType;     // 2=wkbLineString
 unsigned int   numPoints;
 CLLocationCoordinate2D    points[1];
 } WKBLineString;
 
 typedef struct WKBPolygon    {
 unsigned char                byteOrder;
 unsigned int        wkbType;     // 3=wkbPolygon
 unsigned int        numRings;
 LinearRing        rings[1];
 } WKBPolygon ;
 
 typedef struct WKBMultiPoint    {
 unsigned char                byteOrder;
 unsigned int            wkbType;     // 4=wkbMultipoint
 unsigned int            num_wkbPoints;
 WKBPoint            WKBPoints[1];
 } WKBMultiPoint;
 
 typedef struct WKBMultiLineString    {
 unsigned char              byteOrder;
 unsigned int            wkbType;     // 5=wkbMultiLineString
 unsigned int            num_wkbLineStrings;
 WKBLineString     WKBLineStrings[1];
 } WKBMultiLineString;
 */

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

- (CLLocationCoordinate2D) coordinateAtIndex: (NSInteger) index;
-(id)initWithWKB:(const unsigned char *) wkb size:(size_t)wkb_size;
-(id)initWithWKT:(NSString *) wkt;
-(id)initWithGeosGeometry:(GEOSGeometry *)geom;
-(void) reprojectTo:(NSString *)newProjectionDefinition;
void notice(const char *fmt,...);
void log_and_exit(const char *fmt,...);

@end

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