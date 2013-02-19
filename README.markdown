# ShapeKit


ShapeKit is a geometry library for iOS that aims to bridge [GEOS](http://trac.osgeo.org/geos/) with Apple's MapKit.
This fork is based on the original repository by Michael Weisman, with major customizations.
- ShapeKit has been refactored to build in a static library (libShapeKit.a)
- Apple's MapKit specific methods have been refactored in a dedicated category to generalize the code and remove Apple's MapKit dependency.
- GEOS linearref functions (project and interpolate on a line) support was added


## Requirements

ShapeKit depends on [GEOS](http://trac.osgeo.org/geos/) and [PROJ](http://proj.osgeo.org/). There is a build script in lib\_src which will automate downloading and building universal libraries for both ARMv7 and x86 (simulator) and will copy the libraries and headers to the ShapeKit library directory. To use it, simply run the build\_libs.sh script in the lib\_src directory to install the libraries.
Depending on build environment, it may be necessary to change the SDK link version in build_ios configuration script.

## Features

* ShapeKitGeometries are standard cocoa objects

	`ShapeKitPoint *myPoint = [[ShapeKitPoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(0, 0)];`

* ShapeKit has spatial predicates and topology operations

	`ShapeKitPolygon *bufferedPoint = [myPoint bufferWithWidth:0.005]`
	
	`[bufferedPoint containsGeometry:myPoint] \\ Returns YES`

* ShapeKit has support for linear projection and interpolation 

	`ShapeKitPoint *middlePoint = [myLine interpolatePointAtNormalizedDistance: 0.5];`

	`double projectedPosition = [myLine distanceFromOriginToProjectionOfPoint: myPoint];`


## Usage

After following the instructions above to set up GEOS and PROJ copy the ShapeKit Directory into your project directory, 
- drag the ShapeKit project file (ShapeKit.xcodeproj) into your Xcode project. 
- go to the Build Phases tab for your application's target (assuming Xcode 4 here), expand "Target Dependecies" and add ShapeKit. Expand "Link Binary with Libraries" and add libShapeKit.a. This should add the libraries to your project and automatically set the Library and Header Search Paths to enable the linker to find the libraries. 
- go to the Build Settings tab, search the "Other Linker Flags" entry and add "-lstdc++" to link with libc++ as the standard c++ library
- #import "ShapeKit.h" in your .m files

You will also need to add the CoreLocation framework to your project. See the [sample project](https://github.com/andreacremaschi/ShapeKitDemo) for a simple example of a ShapeKit app.

## License

This is free software; you can redistribute and/or modify it under the terms of the GNU Lesser General Public Licence as published by the Free Software Foundation. See the COPYING file for more information.
