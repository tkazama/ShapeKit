//
//  ShapeKitGeometry+Topology.m
//  ShapeKit
//
//  Created by Michael Weisman on 10-08-26.
// * This is free software; you can redistribute and/or modify it under
// the terms of the GNU Lesser General Public Licence as published
// by the Free Software Foundation. 
// See the COPYING file for more information.
//
#import "ShapeKitGeometry+Topology.h"
#import "ShapeKitPrivateInterface.h"

@implementation ShapeKitGeometry (Topology)

-(ShapeKitPolygon *)envelope {
//    return [[[ShapeKitPolygon alloc] initWithGeosGeometry:GEOSEnvelope_r(handle, geosGeom) GEOSContextHandle:ghandle] autorelease];
    return [[ShapeKitPolygon alloc] initWithGeosGeometry:GEOSEnvelope_r(self.handle, self.geosGeom)];
}

-(ShapeKitPolygon *)bufferWithWidth:(double)width {
    return [[ShapeKitPolygon alloc] initWithGeosGeometry:GEOSBuffer_r(self.handle, self.geosGeom, width, 0)];
}

-(ShapeKitPolygon *)convexHull {
    return [[ShapeKitPolygon alloc] initWithGeosGeometry:GEOSConvexHull_r(self.handle, self.geosGeom)];
}

-(NSString *)relationshipWithGeometry:(ShapeKitGeometry *)geometry {
    return [NSString stringWithUTF8String:GEOSRelate_r(self.handle, self.geosGeom, geometry.geosGeom)];
}

-(ShapeKitPoint *)centroid {
    return [[ShapeKitPoint alloc] initWithGeosGeometry:GEOSGetCentroid_r(self.handle, self.geosGeom)];
}

-(ShapeKitPoint *)pointOnSurface {
    return [[ShapeKitPoint alloc] initWithGeosGeometry:GEOSPointOnSurface_r(self.handle, self.geosGeom)];
}

@end
