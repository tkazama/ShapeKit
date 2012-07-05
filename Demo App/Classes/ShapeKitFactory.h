//
//  ShapeKitFactory.h
//  ShapeKit
//
//  Created by Andrea Cremaschi on 05/07/12.
//  Copyright (c) 2012 independent. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShapeKitGeometry;
@interface ShapeKitFactory : NSObject

//Singleton
+ (ShapeKitFactory *)defaultFactory;

// factory methods
- (ShapeKitGeometry *) geometryWithWKB: (NSData *)wkbData;
- (ShapeKitGeometry *) geometryWithWKT: (NSString *)string;

@end
