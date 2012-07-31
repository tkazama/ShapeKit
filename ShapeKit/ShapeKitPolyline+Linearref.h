//
//  ShapeKitPolyline+Linearref.h
//  ShapeKit
//
//  Created by Andrea Cremaschi on 31/07/12.
// * This is free software; you can redistribute and/or modify it under
// the terms of the GNU Lesser General Public Licence as published
// by the Free Software Foundation. 
// See the COPYING file for more information.
//

#import "ShapeKitGeometry.h"

@interface ShapeKitPolyline (Linearref)

// Return distance of point projected on line
- (double) distanceFromProjectionOfPoint: (ShapeKitPoint *)point;
- (double) normalizedDistanceFromProjectionOfPoint: (ShapeKitPoint *)point;

// Return closest point to given distance within geometry 
- (ShapeKitPoint *) interpolatePointAtDistance: (double) distance;
- (ShapeKitPoint *) interpolatePointAtNormalizedDistance: (double) fraction;


@end
