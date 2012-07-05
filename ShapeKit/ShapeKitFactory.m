//
//  ShapeKitFactory.m
//  ShapeKit
//
//  Created by Andrea Cremaschi on 05/07/12.
//  Copyright (c) 2012 independent. All rights reserved.
//

#import "ShapeKitFactory.h"
#import "ShapeKit.h"

@interface ShapeKitFactory () {
    GEOSContextHandle_t handle;

}

@end

@implementation ShapeKitFactory

#pragma mark - Constructor
+ (ShapeKitFactory *)defaultFactory
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

#pragma mark ShapeKitFactory init and dealloc methods
- (id) init
{
    self = [super init];
    if (self != nil) {
        // initialize GEOS library
        handle = initGEOS_r(notice, log_and_exit);
    }
    return self;
}

- (void) dealloc
{
    finishGEOS_r(handle);
}

#pragma mark -Convenience methods
- (Class )classForGeometry: (GEOSGeometry *)geosGeom
{
    int geomTypeID = GEOSGeomTypeId_r(handle, geosGeom);
    Class geomClass = nil;
    switch (geomTypeID)
    {
        case GEOS_POINT:
            geomClass = [ShapeKitPoint class];
            break;
        case GEOS_LINESTRING:
            geomClass = [ShapeKitPolyline class];
            break;
        case GEOS_LINEARRING:
            break;
        case GEOS_POLYGON:
            geomClass = [ShapeKitPolygon class];
            break;
        case GEOS_MULTIPOINT:
            break;
        case GEOS_MULTILINESTRING:
            break;
        case GEOS_MULTIPOLYGON:
            break;
        case GEOS_GEOMETRYCOLLECTION:
            break;
    }

    return geomClass;
}
                             
#pragma mark - Factory methods
- (ShapeKitGeometry *) geometryWithWKB: (NSData *)wkbData
{
    GEOSWKBReader *WKBReader = GEOSWKBReader_create_r(handle);
    GEOSGeometry *geosGeom = GEOSWKBReader_read_r(handle, WKBReader, wkbData.bytes, wkbData.length);
    GEOSWKBReader_destroy_r(handle, WKBReader);

    Class geomClass = [self classForGeometry: geosGeom];
    if (!geomClass)
    {
        NSLog(@"Shapekit error: geometry type '%@' not supported.", [NSString stringWithUTF8String: GEOSGeomType_r(handle, geosGeom)]);
        return nil;
    }

    return [[geomClass alloc] initWithGeosGeometry: geosGeom];
}

-(ShapeKitGeometry *)geometryWithWKT:(NSString *)wkt
{
    GEOSWKTReader *WKTReader = GEOSWKTReader_create_r(handle);
    GEOSGeometry *geosGeom = GEOSWKTReader_read_r(handle, WKTReader, wkt.UTF8String);
    GEOSWKTReader_destroy_r(handle, WKTReader);
    
    Class geomClass = [self classForGeometry: geosGeom];
    if (!geomClass)
    {
        NSLog(@"Shapekit error: geometry type '%@' not supported.", [NSString stringWithUTF8String: GEOSGeomType_r(handle, geosGeom)]);
        return nil;
    }
    
    return [[geomClass alloc] initWithGeosGeometry: geosGeom];
}

#pragma mark GEOS init functions
void notice(const char *fmt,...) {
	va_list ap;
    
    fprintf( stdout, "NOTICE: ");
    
	va_start (ap, fmt);
    vfprintf( stdout, fmt, ap);
    va_end(ap);
    fprintf( stdout, "\n" );
}

void log_and_exit(const char *fmt,...) {
	va_list ap;
    
    fprintf( stdout, "ERROR: ");
    
	va_start (ap, fmt);
    vfprintf( stdout, fmt, ap);
    va_end(ap);
    fprintf( stdout, "\n" );
    //	exit(1);
}


@end
