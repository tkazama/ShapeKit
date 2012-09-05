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

@implementation ShapeKitGeometry
@synthesize wktGeom,geomType, projDefinition ,geosGeom, numberOfCoords;

#pragma mark ShapeKitGeometry init and dealloc methods
- (id) init
{
    self = [super init];
    if (self != nil) {
        // initialize GEOS library
        handle = initGEOS_r(notice, log_and_exit);
        _coords = NULL;
    }
    return self;
}

-(id)initWithWKB:(const unsigned char *) wkb size:(size_t)wkb_size {
    self = [self init];
    if (self) {
        GEOSWKBReader *WKBReader = GEOSWKBReader_create_r(handle);
        self.geosGeom = GEOSWKBReader_read_r(handle, WKBReader, wkb, wkb_size);
        GEOSWKBReader_destroy_r(handle, WKBReader);
        
        self.geomType = [NSString stringWithUTF8String:GEOSGeomType_r(handle, geosGeom)];
        
        GEOSWKTWriter *WKTWriter = GEOSWKTWriter_create_r(handle);
        self.wktGeom = [NSString stringWithUTF8String:GEOSWKTWriter_write_r(handle, WKTWriter,geosGeom)];
        GEOSWKTWriter_destroy_r(handle, WKTWriter);
    }
    return self;
}



-(id)initWithWKT:(NSString *) wkt {
    self = [self init];
    if (self)
    {        
        GEOSWKTReader *WKTReader = GEOSWKTReader_create_r(handle);
        self.geosGeom = GEOSWKTReader_read_r(handle, WKTReader, [wkt UTF8String]);
        GEOSWKTReader_destroy_r(handle, WKTReader);
        
        self.geomType = [NSString stringWithUTF8String:GEOSGeomType_r(handle, geosGeom)];
        
        GEOSWKTWriter *WKTWriter = GEOSWKTWriter_create_r(handle);
        self.wktGeom = [NSString stringWithUTF8String:GEOSWKTWriter_write_r(handle, WKTWriter,geosGeom)];
        GEOSWKTWriter_destroy_r(handle, WKTWriter);
    }
    
    return self;
}

-(id)initWithGeosGeometry:(GEOSGeometry *)geom {
    self = [self init];
    if (self)
    {                
        geosGeom = geom;
        self.geomType = [NSString stringWithUTF8String:GEOSGeomType_r(handle, geosGeom)];
        GEOSWKTWriter *WKTWriter = GEOSWKTWriter_create_r(handle);
        self.wktGeom = [NSString stringWithUTF8String:GEOSWKTWriter_write_r(handle, WKTWriter,geosGeom)];
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
    NSAssert ((index >= 0) && (index < numberOfCoords), @"Error in ShapeKitGeometry class: index must be smaller than numberOfCoords");

    return _coords[index];
}

-(void) reprojectTo:(NSString *)newProjectionDefinition {
    // TODO: Impliment this as an SRID int stored on the geom rather than a proj4 string
	projPJ source, destination;
	source = pj_init_plus([projDefinition UTF8String]);
	destination = pj_init_plus([newProjectionDefinition UTF8String]);
	unsigned int coordCount;
//	if ([geomType isEqualToString:@""]) {
//        <#statements#>
//    }
    GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq_r(handle, geosGeom));
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
    GEOSGeom_destroy_r(handle, geosGeom);
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

-(id)initWithWKT:(NSString *) wkt {
    self = [super initWithWKT:wkt];
    if (self) {
        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq(geosGeom));
        double xCoord;
        GEOSCoordSeq_getX_r(handle, sequence, 0, &xCoord);
        
        double yCoord;
        GEOSCoordSeq_getY_r(handle, sequence, 0, &yCoord);
         
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) );
        *_coords = CLLocationCoordinate2DMake(yCoord, xCoord);
                        
        GEOSCoordSeq_getSize_r(handle, sequence, &numberOfCoords);
        GEOSCoordSeq_destroy_r(handle, sequence);
    }
    return self;
}

-(id)initWithGeosGeometry:(GEOSGeometry *)geom {
    self = [super initWithGeosGeometry:geom];
    if (self) {
        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq_r(handle, geosGeom));
        double xCoord;
        GEOSCoordSeq_getX_r(handle, sequence, 0, &xCoord);
        
        double yCoord;
        GEOSCoordSeq_getY_r(handle, sequence, 0, &yCoord);

        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) );
        *_coords = CLLocationCoordinate2DMake(yCoord, xCoord);

        GEOSCoordSeq_getSize_r(handle, sequence, &numberOfCoords);
        GEOSCoordSeq_destroy_r(handle, sequence);
    }
    return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [self init];
    if (self) {
                
        GEOSCoordSequence *seq = GEOSCoordSeq_create_r(handle, 1,2);
        GEOSCoordSeq_setX_r(handle, seq, 0, coordinate.longitude);
        GEOSCoordSeq_setY_r(handle, seq, 0, coordinate.latitude);
        GEOSGeometry *newGeosGeom = GEOSGeom_createPoint_r(handle, seq);
        NSAssert (newGeosGeom != NULL, @"Error creating ShapeKitPoint");
        geosGeom=newGeosGeom;
        
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
        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq_r(handle, geosGeom));
        GEOSCoordSeq_getSize_r(handle, sequence, &numberOfCoords);
        CLLocationCoordinate2D coords[numberOfCoords];
        
        for (int coord = 0; coord < numberOfCoords; coord++) {
            double xCoord = NULL;
            GEOSCoordSeq_getX_r(handle, sequence, coord, &xCoord);
            
            double yCoord = NULL;
            GEOSCoordSeq_getY_r(handle, sequence, coord, &yCoord);
            coords[coord] = CLLocationCoordinate2DMake(yCoord, xCoord);
        }
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * numberOfCoords );
        memcpy(_coords, coords, sizeof(CLLocationCoordinate2D) * numberOfCoords );
        
        GEOSCoordSeq_destroy_r(handle, sequence);
    }
    return self;
}

-(id)initWithWKT:(NSString *) wkt {
    self = [super initWithWKT:wkt];
    if (self) {
        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq_r(handle, geosGeom));
        GEOSCoordSeq_getSize_r(handle, sequence, &numberOfCoords);
        CLLocationCoordinate2D coords[numberOfCoords];
        
        for (int coord = 0; coord < numberOfCoords; coord++) {
            double xCoord = NULL;
            GEOSCoordSeq_getX_r(handle, sequence, coord, &xCoord);
            
            double yCoord = NULL;
            GEOSCoordSeq_getY_r(handle, sequence, coord, &yCoord);
            coords[coord] = CLLocationCoordinate2DMake(yCoord, xCoord);
        }
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * numberOfCoords );
        memcpy(_coords, coords, sizeof(CLLocationCoordinate2D) * numberOfCoords );
        
        GEOSCoordSeq_destroy_r(handle, sequence);
    }
    
    return self;
}

-(id)initWithGeosGeometry:(GEOSGeometry *)geom {
    self = [super initWithGeosGeometry:geom];
    if (self) {
        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq_r(handle, geosGeom));
        GEOSCoordSeq_getSize_r(handle, sequence, &numberOfCoords);
        CLLocationCoordinate2D coords[numberOfCoords];
        
        for (int coord = 0; coord < numberOfCoords; coord++) {
            double xCoord = NULL;
            GEOSCoordSeq_getX_r(handle, sequence, coord, &xCoord);
            
            double yCoord = NULL;
            GEOSCoordSeq_getY_r(handle, sequence, coord, &yCoord);
            coords[coord] = CLLocationCoordinate2DMake(yCoord, xCoord);
        }
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * numberOfCoords );
        memcpy(_coords, coords, sizeof(CLLocationCoordinate2D) * numberOfCoords );

        GEOSCoordSeq_destroy_r(handle, sequence);
    }
    return self;
    
}

-(id)initWithCoordinates:(CLLocationCoordinate2D[])coordinates count:(unsigned int)count {
    self = [self init];
    if (self) {
        GEOSCoordSequence *seq = GEOSCoordSeq_create_r(handle, count,2);
        
        for (int i = 0; i < count; i++) {
            GEOSCoordSeq_setX_r(handle, seq, i, coordinates[i].longitude);
            GEOSCoordSeq_setY_r(handle, seq, i, coordinates[i].latitude);
        }
        self.geosGeom = GEOSGeom_createLineString_r(handle, seq);
        
        // TODO: Move the destroy into the dealloc method
        // GEOSCoordSeq_destroy(seq);
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * numberOfCoords );
        memcpy(_coords, coordinates, sizeof(CLLocationCoordinate2D) * numberOfCoords );
        
        GEOSWKTWriter *WKTWriter = GEOSWKTWriter_create_r(handle);
        self.wktGeom = [NSString stringWithUTF8String:GEOSWKTWriter_write_r(handle, WKTWriter,geosGeom)];
        GEOSWKTWriter_destroy_r(handle, WKTWriter);
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
        GEOSCoordSeq_getSize_r(handle, sequence, &numberOfCoords);
        CLLocationCoordinate2D coordsExt[numberOfCoords];
        for (int coord = 0; coord < numberOfCoords; coord++) {
            double xCoord = NULL;
            GEOSCoordSeq_getX_r(handle, sequence, coord, &xCoord);
            
            double yCoord = NULL;
            GEOSCoordSeq_getY_r(handle, sequence, coord, &yCoord);
            coordsExt[coord] = CLLocationCoordinate2DMake(yCoord, xCoord);
        }
        if ([interiors count])
            _interiors = [interiors copy];
        
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * numberOfCoords );
        memcpy(_coords, coordsExt, sizeof(CLLocationCoordinate2D) * numberOfCoords );

        
        GEOSCoordSeq_destroy_r(handle, sequence);
        }
    return self;
}

-(id)initWithWKT:(NSString *) wkt {
    self = [super initWithWKT:wkt];
    if (self) {
        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq_r(handle, GEOSGetExteriorRing(geosGeom)));
        GEOSCoordSeq_getSize_r(handle, sequence, &numberOfCoords);
        CLLocationCoordinate2D coords[numberOfCoords];
        
        for (int coord = 0; coord < numberOfCoords; coord++) {
            double xCoord = NULL;
            GEOSCoordSeq_getX_r(handle, sequence, coord, &xCoord);
            
            double yCoord = NULL;
            GEOSCoordSeq_getY_r(handle, sequence, coord, &yCoord);
            coords[coord] = CLLocationCoordinate2DMake(yCoord, xCoord);
        }
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * numberOfCoords );
        memcpy(_coords, coords, sizeof(CLLocationCoordinate2D) * numberOfCoords );
        
        GEOSCoordSeq_destroy_r(handle, sequence);
    }
    return self;
}

-(id)initWithGeosGeometry:(GEOSGeometry *)geom {
    self = [super initWithGeosGeometry:geom];
    if (self) {
        GEOSCoordSequence *sequence = GEOSCoordSeq_clone_r(handle, GEOSGeom_getCoordSeq_r(handle, GEOSGetExteriorRing_r(handle, geosGeom)));
        GEOSCoordSeq_getSize_r(handle, sequence, &numberOfCoords);
        CLLocationCoordinate2D coords[numberOfCoords];
        
        for (int coord = 0; coord < numberOfCoords; coord++) {
            double xCoord = NULL;
            GEOSCoordSeq_getX_r(handle, sequence, coord, &xCoord);
            
            double yCoord = NULL;
            GEOSCoordSeq_getY_r(handle, sequence, coord, &yCoord);
            coords[coord] = CLLocationCoordinate2DMake(yCoord, xCoord);
        }
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * numberOfCoords );
        memcpy(_coords, coords, sizeof(CLLocationCoordinate2D) * numberOfCoords );
        
        GEOSCoordSeq_destroy_r(handle, sequence);
    }
    return self;
}

-(id)initWithCoordinates:(CLLocationCoordinate2D[])coordinates count:(unsigned int)count {
    self = [self init];
    if (self) {
        GEOSCoordSequence *seq = GEOSCoordSeq_create_r(handle, count,2);
        
        for (int i = 0; i < count; i++) {
            GEOSCoordSeq_setX_r(handle, seq, i, coordinates[i].longitude);
            GEOSCoordSeq_setY_r(handle, seq, i, coordinates[i].latitude);
        }
        GEOSGeometry *ring = GEOSGeom_createLinearRing_r(handle, seq);
        self.geosGeom = GEOSGeom_createPolygon_r(handle, ring, NULL, 0);
        
        // TODO: Move the destroy into the dealloc method
        // GEOSCoordSeq_destroy(seq);
        _coords = (CLLocationCoordinate2D *) malloc( sizeof(CLLocationCoordinate2D) * numberOfCoords );
        memcpy(_coords, coordinates, sizeof(CLLocationCoordinate2D) * numberOfCoords );
        
        GEOSWKTWriter *WKTWriter = GEOSWKTWriter_create_r(handle);
        self.wktGeom = [NSString stringWithUTF8String:GEOSWKTWriter_write_r(handle, WKTWriter,geosGeom)];
        GEOSWKTWriter_destroy_r(handle, WKTWriter);
    }    
    return self;
    
}


@end