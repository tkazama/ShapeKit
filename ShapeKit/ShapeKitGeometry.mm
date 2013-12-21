//
//  ShapeKitGeometry.m
//  ShapeKit
//
//  Created by Michael Weisman on 10-08-21.

// * This is free software; you can redistribute and/or modify it under
// the terms of the GNU Lesser General Public Licence as published
// by the Free Software Foundation. 
// See the COPYING file for more information.
//

#import "ShapeKitGeometry.h"
#import <geos_c.h>
#import <proj_api.h>

#import "ShapeKitPrivateInterface.h"
#import "ShapeKitFactory.h"

void notice(const char *fmt,...);
void log_and_exit(const char *fmt,...);

@interface ShapeKitGeometry () {
@protected
    GEOSContextHandle_t _handle;
    GEOSGeometry *_geosGeom;
    NSUInteger _numberOfCoords;
    CLLocationCoordinate2D *_coords;
}


@property (readwrite, copy) NSString *wktGeom;
@property (readwrite, copy) NSString *geomType;

@property (readwrite, copy) NSString *projDefinition;

@property (readwrite) GEOSGeometry *geosGeom;
@property (readwrite) CLLocationCoordinate2D *coords;
@property (readwrite) id geometry;

@end


@interface ShapeKitGeometryCollection ()
@property (strong) NSArray *geometries;
@end


#pragma mark - Simple geometries -

@implementation ShapeKitGeometry

#pragma mark ShapeKitGeometry init and dealloc methods
- (id) init
{
    self = [super init];
    if (self != nil) {
        // initialize GEOS library
        _handle = initGEOS_r(notice, log_and_exit);
        _coords = NULL;
    }
    return self;
}

-(id)initWithWKB:(const unsigned char *) wkb size:(size_t)wkb_size {
    self = [self init];
    if (self) {
        
        GEOSContextHandle_t handle = (GEOSContextHandle_t)self.handle;
        
        GEOSWKBReader *WKBReader = GEOSWKBReader_create_r(handle);
        _geosGeom = GEOSWKBReader_read_r(handle, WKBReader, wkb, wkb_size);
        GEOSWKBReader_destroy_r(handle, WKBReader);
        
        self.geomType = [NSString stringWithUTF8String: GEOSGeomType_r(handle, self.geosGeom)];
        
        GEOSWKTWriter *WKTWriter = GEOSWKTWriter_create_r(handle);
        self.wktGeom = [NSString stringWithUTF8String:GEOSWKTWriter_write_r(handle, WKTWriter, self.geosGeom)];
        GEOSWKTWriter_destroy_r(handle, WKTWriter);
    }
    return self;
}



-(id)initWithWKT:(NSString *) wkt {
    self = [self init];
    if (self)
    {
        GEOSContextHandle_t handle = (GEOSContextHandle_t)_handle;
        
        GEOSWKTReader *WKTReader = GEOSWKTReader_create_r(handle);
        _geosGeom = GEOSWKTReader_read_r(handle, WKTReader, [wkt UTF8String]);
        GEOSWKTReader_destroy_r(handle, WKTReader);
        
        GEOSGeometry *geosGeom = self.geosGeom;
        char *geomTypeStr =GEOSGeomType_r(handle, geosGeom);
        self.geomType = [NSString stringWithUTF8String:geomTypeStr];
        free(geomTypeStr);
        
        GEOSWKTWriter *WKTWriter = GEOSWKTWriter_create_r(handle);
        self.wktGeom = [NSString stringWithUTF8String:GEOSWKTWriter_write_r(handle, WKTWriter, geosGeom)];
        GEOSWKTWriter_destroy_r(handle, WKTWriter);
    }
    
    return self;
}

-(id)initWithGeosGeometry:(void *)geom {
    self = [self init];
    if (self)
    {
        GEOSContextHandle_t handle = (GEOSContextHandle_t)_handle;
        
        _geosGeom = (GEOSGeometry *)geom;
        
        char *geomTypeStr = GEOSGeomType_r(handle, _geosGeom);
        self.geomType = [NSString stringWithUTF8String: geomTypeStr];
        free(geomTypeStr);
        
        GEOSWKTWriter *WKTWriter = GEOSWKTWriter_create_r(handle);
        char *wktGeomStr = GEOSWKTWriter_write_r(handle, WKTWriter, _geosGeom);
        self.wktGeom = [NSString stringWithUTF8String: wktGeomStr];
        free(wktGeomStr);
        
        GEOSWKTWriter_destroy_r(handle, WKTWriter);
    }
    return self;
}

-(NSString *)description
{
    NSMutableString *pointsList = [[NSMutableString alloc] init];
    CLLocationCoordinate2D* curCoords=NULL;
    for (int i=0;i<self.numberOfCoords;i++)
    {
        curCoords = _coords+i;
        [pointsList appendFormat:@"[%.4f, %.4f] ", curCoords->latitude,curCoords->longitude]; 
    }
    return [[super description] stringByAppendingFormat: @"%@", pointsList];
}

- (CLLocationCoordinate2D) coordinateAtIndex: (NSInteger) index
{
    NSAssert ((index >= 0) && (index < self.numberOfCoords), @"Error in ShapeKitGeometry class: index must be smaller than numberOfCoords");

    return _coords[index];
}

-(void) reprojectTo:(NSString *)newProjectionDefinition {
    // TODO: Impliment this as an SRID int stored on the geom rather than a proj4 string
	projPJ source, destination;
	source = pj_init_plus([self.projDefinition UTF8String]);
	destination = pj_init_plus([newProjectionDefinition UTF8String]);
	unsigned int coordCount;
//	if ([geomType isEqualToString:@""]) {
//        <#statements#>
//    }
    GEOSContextHandle_t handle = (GEOSContextHandle_t)_handle;

    GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq_r(handle, _geosGeom));
	GEOSCoordSeq_getSize_r(handle, sequence, &coordCount);
	double x[coordCount];
	double y[coordCount];
    
	
    for (int coord = 0; coord < coordCount; coord++) {
        double xCoord = NULL;
        GEOSCoordSeq_getX_r(handle, sequence, coord, &xCoord);
        
        double yCoord = NULL;
        GEOSCoordSeq_getY_r(handle, sequence, coord, &yCoord);
		xCoord *= DEG_TO_RAD;
		yCoord *= DEG_TO_RAD;
		y[coord] = yCoord;
		x[coord] = xCoord;
    }
	
    GEOSCoordSeq_destroy_r(handle, sequence);
	
	
	
	int proj = pj_transform(source, destination, coordCount, 1, x, y, NULL );
	for (int i = 0; i < coordCount; i++) {
		printf("x:\t%.2f\n",x[i]);
	}
    
    // TODO: move the message from a log to an NSError
    if (proj != 0) {
        NSLog(@"%@",[NSString stringWithUTF8String:pj_strerrno(proj)]);
    }
	pj_free(source);
	pj_free(destination);
}

- (void) dealloc
{
    if (_coords)
        free (_coords);

    GEOSContextHandle_t handle = (GEOSContextHandle_t)_handle;

    GEOSGeom_destroy_r(handle, _geosGeom);
    finishGEOS_r(handle);
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

#pragma mark -

@implementation ShapeKitPoint
-(id)init
{
    self = [super init];
    if (self)
    {
        _numberOfCoords = 1;
    }
    return self;
}

-(id)initWithWKT:(NSString *) wkt {
    self = [super initWithWKT:wkt];
    if (self) {

        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(_handle, GEOSGeom_getCoordSeq(_geosGeom));
        double xCoord;
        GEOSCoordSeq_getX_r(_handle, sequence, 0, &xCoord);
        
        double yCoord;
        GEOSCoordSeq_getY_r(_handle, sequence, 0, &yCoord);
         
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) );
        *_coords = CLLocationCoordinate2DMake(yCoord, xCoord);
                        
        GEOSCoordSeq_getSize_r(_handle, sequence, &_numberOfCoords);
        GEOSCoordSeq_destroy_r(_handle, sequence);
    }
    return self;
}

-(id)initWithGeosGeometry:(void *)geom {
    self = [super initWithGeosGeometry:geom];
    if (self) {
        GEOSContextHandle_t handle = (GEOSContextHandle_t)_handle;

        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq_r(_handle, _geosGeom));
        double xCoord;
        GEOSCoordSeq_getX_r(handle, sequence, 0, &xCoord);
        
        double yCoord;
        GEOSCoordSeq_getY_r(handle, sequence, 0, &yCoord);

        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) );
        *_coords = CLLocationCoordinate2DMake(yCoord, xCoord);

        GEOSCoordSeq_getSize_r(handle, sequence, &_numberOfCoords);
        GEOSCoordSeq_destroy_r(handle, sequence);
    }
    return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [self init];
    if (self) {
        
        GEOSContextHandle_t handle = (GEOSContextHandle_t)_handle;

        GEOSCoordSequence *seq = GEOSCoordSeq_create_r(handle, 1,2);
        GEOSCoordSeq_setX_r(handle, seq, 0, coordinate.longitude);
        GEOSCoordSeq_setY_r(handle, seq, 0, coordinate.latitude);
        GEOSGeometry *newGeosGeom = GEOSGeom_createPoint_r(handle, seq);
        NSAssert (newGeosGeom != NULL, @"Error creating ShapeKitPoint");
        _geosGeom=newGeosGeom;
        
        // TODO: Move the destroy into the dealloc method
        // GEOSCoordSeq_destroy(seq);
        
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) );
        *_coords = coordinate;
        
        GEOSWKTWriter *WKTWriter = GEOSWKTWriter_create_r(handle);
        char *wktString = GEOSWKTWriter_write_r(handle, WKTWriter, newGeosGeom);
        self.wktGeom = [NSString stringWithUTF8String: wktString];
        GEOSWKTWriter_destroy_r(handle, WKTWriter);        
        
    }    
    return self;
}

-(CLLocationCoordinate2D)coordinate
{
    return [self coordinateAtIndex: 0];    
}

@end

#pragma mark -

@implementation ShapeKitPolyline

-(id)initWithWKB:(const unsigned char *) wkb size:(size_t)wkb_size{
    self = [super initWithWKB:wkb size:wkb_size];
    if (self) {

        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(_handle, GEOSGeom_getCoordSeq_r(_handle, _geosGeom));
        GEOSCoordSeq_getSize_r(_handle, sequence, &_numberOfCoords);
        CLLocationCoordinate2D coords[_numberOfCoords];
        
        for (int coord = 0; coord < _numberOfCoords; coord++) {
            double xCoord = NULL;
            GEOSCoordSeq_getX_r(_handle, sequence, coord, &xCoord);
            
            double yCoord = NULL;
            GEOSCoordSeq_getY_r(_handle, sequence, coord, &yCoord);
            coords[coord] = CLLocationCoordinate2DMake(yCoord, xCoord);
        }
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        memcpy(_coords, coords, sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        
        GEOSCoordSeq_destroy_r(_handle, sequence);
    }
    return self;
}

-(id)initWithWKT:(NSString *) wkt {
    self = [super initWithWKT:wkt];
    if (self) {
        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(_handle, GEOSGeom_getCoordSeq_r(_handle, _geosGeom));
        GEOSCoordSeq_getSize_r(_handle, sequence, &_numberOfCoords);
        CLLocationCoordinate2D coords[_numberOfCoords];
        
        for (int coord = 0; coord < _numberOfCoords; coord++) {
            double xCoord = NULL;
            GEOSCoordSeq_getX_r(_handle, sequence, coord, &xCoord);
            
            double yCoord = NULL;
            GEOSCoordSeq_getY_r(_handle, sequence, coord, &yCoord);
            coords[coord] = CLLocationCoordinate2DMake(yCoord, xCoord);
        }
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        memcpy(_coords, coords, sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        
        GEOSCoordSeq_destroy_r(_handle, sequence);
    }
    
    return self;
}

-(id)initWithGeosGeometry:(void *)geom {
    self = [super initWithGeosGeometry:geom];
    if (self) {
        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(_handle, GEOSGeom_getCoordSeq_r(_handle, _geosGeom));
        GEOSCoordSeq_getSize_r(_handle, sequence, &_numberOfCoords);
        CLLocationCoordinate2D coords[_numberOfCoords];
        
        for (int coord = 0; coord < _numberOfCoords; coord++) {
            double xCoord = NULL;
            GEOSCoordSeq_getX_r(_handle, sequence, coord, &xCoord);
            
                double yCoord = NULL;
            GEOSCoordSeq_getY_r(_handle, sequence, coord, &yCoord);
            coords[coord] = CLLocationCoordinate2DMake(yCoord, xCoord);
        }
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        memcpy(_coords, coords, sizeof(CLLocationCoordinate2D) * _numberOfCoords );

        GEOSCoordSeq_destroy_r(_handle, sequence);
    }
    return self;
    
}

-(id)initWithCoordinates:(CLLocationCoordinate2D[])coordinates count:(unsigned int)count {
    self = [self init];
    if (self) {
        GEOSCoordSequence *seq = GEOSCoordSeq_create_r(_handle, count,2);
        
        for (int i = 0; i < count; i++) {
            GEOSCoordSeq_setX_r(_handle, seq, i, coordinates[i].longitude);
            GEOSCoordSeq_setY_r(_handle, seq, i, coordinates[i].latitude);
        }
        _geosGeom = GEOSGeom_createLineString_r(_handle, seq);
        
        // TODO: Move the destroy into the dealloc method
        // GEOSCoordSeq_destroy(seq);
        _numberOfCoords = count;
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        memcpy(_coords, coordinates, sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        
        GEOSWKTWriter *WKTWriter = GEOSWKTWriter_create_r(_handle);
        self.wktGeom = [NSString stringWithUTF8String:GEOSWKTWriter_write_r(_handle, WKTWriter, _geosGeom)];
        GEOSWKTWriter_destroy_r(_handle, WKTWriter);
    }
    return self;
}


@end

#pragma mark -

@implementation ShapeKitPolygon
@synthesize interiors = _interiors;

-(id)initWithWKB:(const unsigned char *) wkb size:(size_t)wkb_size {
	
    size_t length = wkb_size;
    
    self = [super initWithWKB:wkb size:length];
    if (self) {

        GEOSCoordSequence *sequence = nil;
        GEOSContextHandle_t handle = _handle;
        GEOSGeometry *geosGeom = _geosGeom;
        
        int numInteriorRings = GEOSGetNumInteriorRings_r(handle, geosGeom);
        NSMutableArray *interiors = [[NSMutableArray alloc] init];
        int interiorIndex = 0;
        for (interiorIndex = 0; interiorIndex< numInteriorRings; interiorIndex++) {
            const GEOSGeometry *interior = GEOSGetInteriorRingN_r(handle, geosGeom, interiorIndex);
            sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq_r(handle, interior));
            unsigned int numCoordsInt = 0;
            GEOSCoordSeq_getSize_r(handle, sequence, &numCoordsInt); 
            CLLocationCoordinate2D coordsInt[numCoordsInt];
            for (int coord = 0; coord < numCoordsInt; coord++) {
                double xCoord = NULL;
                
                GEOSCoordSeq_getX_r(handle, sequence, coord, &xCoord);
                
                double yCoord = NULL;
                GEOSCoordSeq_getY_r(handle, sequence, coord, &yCoord);
                coordsInt[coord] = CLLocationCoordinate2DMake(yCoord, xCoord);
            }
            ShapeKitPolygon *curInterior = [[ShapeKitPolygon alloc] initWithCoordinates: coordsInt
                                                                               count: numCoordsInt];
            [interiors addObject: curInterior];
            GEOSCoordSeq_destroy_r(handle, sequence);		
        }
        const GEOSGeometry *exterior = GEOSGetExteriorRing_r(handle, geosGeom);
        sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq_r(handle, exterior));
        GEOSCoordSeq_getSize_r(handle, sequence, &_numberOfCoords);
        CLLocationCoordinate2D coordsExt[_numberOfCoords];
        for (int coord = 0; coord < _numberOfCoords; coord++) {
            double xCoord = NULL;
            GEOSCoordSeq_getX_r(handle, sequence, coord, &xCoord);
            
            double yCoord = NULL;
            GEOSCoordSeq_getY_r(handle, sequence, coord, &yCoord);
            coordsExt[coord] = CLLocationCoordinate2DMake(yCoord, xCoord);
        }
        if ([interiors count])
            _interiors = [interiors copy];
        
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        memcpy(_coords, coordsExt, sizeof(CLLocationCoordinate2D) * _numberOfCoords );

        
        GEOSCoordSeq_destroy_r(handle, sequence);
        }
    return self;
}

-(id)initWithWKT:(NSString *) wkt {
    self = [super initWithWKT:wkt];
    if (self) {
        
        GEOSContextHandle_t handle = _handle;
        GEOSGeometry *geosGeom = _geosGeom;

        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq_r(handle, GEOSGetExteriorRing(geosGeom)));
        GEOSCoordSeq_getSize_r(handle, sequence, &_numberOfCoords);
        CLLocationCoordinate2D coords[_numberOfCoords];
        
        for (int coord = 0; coord < _numberOfCoords; coord++) {
            double xCoord = NULL;
            GEOSCoordSeq_getX_r(handle, sequence, coord, &xCoord);
            
            double yCoord = NULL;
            GEOSCoordSeq_getY_r(handle, sequence, coord, &yCoord);
            coords[coord] = CLLocationCoordinate2DMake(yCoord, xCoord);
        }
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        memcpy(_coords, coords, sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        
        GEOSCoordSeq_destroy_r(handle, sequence);
    }
    return self;
}

-(id)initWithGeosGeometry:(void *)geom {
    self = [super initWithGeosGeometry: geom];
    if (self) {
        
        GEOSContextHandle_t handle = _handle;

        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq_r(handle, GEOSGetExteriorRing_r(handle, _geosGeom)));
        GEOSCoordSeq_getSize_r(handle, sequence, &_numberOfCoords);
        CLLocationCoordinate2D coords[_numberOfCoords];
        
        for (int coord = 0; coord < _numberOfCoords; coord++) {
            double xCoord = NULL;
            GEOSCoordSeq_getX_r(handle, sequence, coord, &xCoord);
            
            double yCoord = NULL;
            GEOSCoordSeq_getY_r(handle, sequence, coord, &yCoord);
            coords[coord] = CLLocationCoordinate2DMake(yCoord, xCoord);
        }
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        memcpy(_coords, coords, sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        
        GEOSCoordSeq_destroy_r(handle, sequence);
    }
    return self;
}

-(id)initWithCoordinates:(CLLocationCoordinate2D[])coordinates count:(unsigned int)count {
    self = [self init];
    if (self) {
        GEOSContextHandle_t handle = _handle;

        GEOSCoordSequence *seq = GEOSCoordSeq_create_r(handle, count,2);
        
        for (int i = 0; i < count; i++) {
            GEOSCoordSeq_setX_r(handle, seq, i, coordinates[i].longitude);
            GEOSCoordSeq_setY_r(handle, seq, i, coordinates[i].latitude);
        }
        GEOSGeometry *ring = GEOSGeom_createLinearRing_r(handle, seq);
        _geosGeom = GEOSGeom_createPolygon_r(handle, ring, NULL, 0);
        
        // TODO: Move the destroy into the dealloc method
        // GEOSCoordSeq_destroy(seq);
        _numberOfCoords = count;
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        memcpy(_coords, coordinates, sizeof(CLLocationCoordinate2D) * _numberOfCoords );
        
        GEOSWKTWriter *WKTWriter = GEOSWKTWriter_create_r(handle);
        self.wktGeom = [NSString stringWithUTF8String:GEOSWKTWriter_write_r(handle, WKTWriter, _geosGeom)];
        GEOSWKTWriter_destroy_r(handle, WKTWriter);
    }    
    return self;
    
}

@end

#pragma mark - Geometry collections -


@implementation ShapeKitGeometryCollection
-(id)init
{
    self = [super init];
    if (self)
    {
        _geometries = [NSArray array];
    }
    return self;
}

-(void)dealloc
{
    _geometries = nil;
}

-(id)initWithGeosGeometry:(void *)geom {
    self = [super initWithGeosGeometry: geom];
    if (self) {
        
        GEOSContextHandle_t handle = _handle;
        GEOSGeometry *GEOSGeom = (GEOSGeometry *)geom;
        
        // create an array of copy of original geometries
        // (double memory footprint, but faster access to data
        int numGeometries = GEOSGetNumGeometries_r(handle, GEOSGeom);
        NSMutableArray *mArray = [NSMutableArray array];
        for (int i=0; i<numGeometries; i++)
        {
            const GEOSGeometry *curGeom = GEOSGetGeometryN_r(handle, GEOSGeom, i);
            GEOSGeometry *geomCopy = GEOSGeom_clone_r(handle, curGeom);
            
            ShapeKitGeometry *geomObj = [[ShapeKitFactory defaultFactory] geometryWithGEOSGeometry: geomCopy];
            [mArray addObject: geomObj];
        }
        _geometries = [mArray copy];
        
    }
    return self;
}

- (NSUInteger) numberOfGeometries
{
    return self.geometries.count;
}

- (ShapeKitGeometry*) geometryAtIndex: (NSInteger) index
{
    return [self.geometries objectAtIndex:index];
}

-(NSString *)description
{
    NSMutableString *geomsList = [[NSMutableString alloc] init];
    
    int i=0;
    for (ShapeKitGeometry*geom in self.geometries)
        [geomsList appendFormat:@"\n     Geometry %i: %@", ++i, [geom description]];
    return [[super description] stringByAppendingFormat: @"%@", geomsList];
}

@end

#pragma mark MultiLineString
@implementation ShapeKitMultiPolyline
- (NSUInteger) numberOfPolylines        { return [super numberOfGeometries]; }
- (ShapeKitPolyline*) polylineAtIndex: (NSInteger) index     { return (ShapeKitPolyline *) [super geometryAtIndex: index]; }
@end

#pragma mark MultiPoint
@implementation ShapeKitMultiPoint
- (NSUInteger) numberOfPoints   { return [super numberOfGeometries]; }
- (ShapeKitPoint*) pointAtIndex: (NSInteger) index     { return  (ShapeKitPoint *)[super geometryAtIndex: index]; }
@end

#pragma mark MultiPolygon
@implementation ShapeKitMultiPolygon
- (NSUInteger) numberOfPolygons { return [super numberOfGeometries]; }
- (ShapeKitPolygon*) polygonAtIndex: (NSInteger) index       { return  (ShapeKitPolygon *)[super geometryAtIndex: index]; }
@end