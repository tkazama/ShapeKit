//
//  ShapeKitGeometry+Topology.h
//  ShapeKit
//
//  Created by Michael Weisman on 10-08-26.
// * This is free software; you can redistribute and/or modify it under
// the terms of the GNU Lesser General Public Licence as published
// by the Free Software Foundation. 
// See the COPYING file for more information.
//

#import <Foundation/Foundation.h>
#import "ShapeKitGeometry.h"


@interface ShapeKitGeometry (Topology)

-(ShapeKitPolygon *)envelope;
-(ShapeKitPolygon *)bufferWithWidth:(double)width;
-(ShapeKitPolygon *)convexHull;
-(NSString *)relationshipWithGeometry:(ShapeKitGeometry *)geometry;
-(ShapeKitPoint *)centroid;
-(ShapeKitPoint *)pointOnSurface;

-(ShapeKitGeometry *)intersectionWithGeometry:(ShapeKitGeometry *)geometry;
-(ShapeKitGeometry *)differenceWithGeometry:(ShapeKitGeometry *)geometry;
-(ShapeKitGeometry *)boundary;
-(ShapeKitGeometry *)unionWithGeometry:(ShapeKitGeometry *)geometry;
-(ShapeKitGeometry *)cascadedUnion;



@end
