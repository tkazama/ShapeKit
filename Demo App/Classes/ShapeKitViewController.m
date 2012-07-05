//
//  ShapeKitViewController.m
//  ShapeKit
//
//  Created by Michael Weisman on 10-08-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ShapeKitViewController.h"
#import "ShapeKit.h"
#import "ShapeKit+MapKit.h"

#import "NSString+HexToData.h"

@implementation ShapeKitViewController
@synthesize theMap;



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (ShapeKitGeometry *)loadWKBGeometryFromFile:(NSString *)file {
    ShapeKitGeometry *geometry = nil;
	NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"plist"];
	NSDictionary *stupidDict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSData *geomData = [stupidDict objectForKey:@"shape"];
	if (geomData && [geomData length]) {
		// poly = [[ShapeKitPolygon alloc] initWithWKB:[geomData bytes] size:[geomData length]];
        geometry = [[ShapeKitFactory defaultFactory] geometryWithWKB: geomData];
	}
	return geometry;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create some geometries and add them to the map view
    ShapeKitPoint *myPoint = [[ShapeKitPoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(49.283592, -123.104997)];
    myPoint.geometry.title = @"0 0";
    myPoint.geometry.subtitle = @"Next to the most awesome place in the world";
    [theMap addAnnotation:myPoint.geometry];
    
    // Create a polygon and run it through the predicates with the point
    //ShapeKitPolygon *polygon = [[ShapeKitPolygon alloc] initWithWKT:@"POLYGON((-1 -1, -1 1, 1 1, 1 -1, -1 -1))"];
    CLLocationCoordinate2D polyCoords[7];
    polyCoords[0] = CLLocationCoordinate2DMake(49.283894529188,-123.102176803645);
    polyCoords[1] = CLLocationCoordinate2DMake(49.282388289451,-123.102213028432);
    polyCoords[2] = CLLocationCoordinate2DMake(49.2824077667387,-123.103291100283);
    polyCoords[3] = CLLocationCoordinate2DMake(49.2838335164225,-123.1034755758);
    polyCoords[4] = CLLocationCoordinate2DMake(49.2838684091301,-123.103369232099);
    polyCoords[5] = CLLocationCoordinate2DMake(49.2838634036584,-123.102745005068);
    polyCoords[6] = CLLocationCoordinate2DMake(49.283894529188,-123.102176803645);
    ShapeKitPolygon *polygon = [[ShapeKitPolygon alloc] initWithCoordinates:polyCoords count:7];

    polygon.geometry.title = @"foo";
    [theMap addOverlay:polygon.geometry];
    
    if ([polygon isDisjointFromGeometry:myPoint]) {
        NSLog(@"Disjoined");
    } else {
        NSLog(@"Not Disjoined");
    }
    
    if ([polygon touchesGeometry:myPoint]) {
        NSLog(@"Touches");
    } else {
        NSLog(@"Does not Touch");
    }
    
    if ([polygon intersectsGeometry:myPoint]) {
        NSLog(@"Intersects");
    } else {
        NSLog(@"No Intersect");
    }
    
    if ([polygon crossesGeometry:myPoint]) {
        NSLog(@"Crosses");
    } else {
        NSLog(@"Does not Cross");
    }
    
    if ([polygon isWithinGeometry:myPoint]) {
        NSLog(@"Within");
    } else {
        NSLog(@"Not Within");
    }
    
    if ([polygon containsGeometry:myPoint]) {
        NSLog(@"Contains");
    } else {
        NSLog(@"Does not Contain");
    }
    
    if ([polygon overlapsGeometry:myPoint]) {
        NSLog(@"Overlaps");
    } else {
        NSLog(@"Does Not Overlap");
    }
    
    if ([polygon isEqualToGeometry:myPoint]) {
        NSLog(@"Equals");
    } else {
        NSLog(@"Does Not Equal");
    }
    
    if ([polygon isRelatedToGeometry:myPoint WithRelatePattern:@"*********"]) {
        NSLog(@"Related with Pattern");
    } else {
        NSLog(@"Not Related with Pattern");
    }
    NSLog(@"Realtionship bewteen point and polygon: %@",[myPoint relationshipWithGeometry:polygon]);
    
    NSLog(@"%@",polygon.geomType);
    
    // Make a Polyline
    CLLocationCoordinate2D coords[5];
    coords[0] = CLLocationCoordinate2DMake(49.283245,-123.105370);
    coords[1] = CLLocationCoordinate2DMake(49.283485,-123.106674);
    coords[2] = CLLocationCoordinate2DMake(49.281200,-123.107620);
    coords[3] = CLLocationCoordinate2DMake(49.278542,-123.107796);
    coords[4] = CLLocationCoordinate2DMake(49.279720,-123.109703);
    ShapeKitPolyline *line = [[ShapeKitPolyline alloc] initWithCoordinates:coords count:5];
	
	// Reproject the line to Google Web Merc
	line.projDefinition = @"+proj=latlong +datum=WGS84";
	[line reprojectTo:@"+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs"];	
	
    [theMap addOverlay:line.geometry];
    
    [theMap addOverlay:[line envelope].geometry];
    [theMap addOverlay:[line bufferWithWidth:0.005].geometry];
    [theMap addOverlay:[line convexHull].geometry];
    [theMap addAnnotation:[line pointOnSurface].geometry];
    [theMap addAnnotation:[line centroid].geometry];

    ShapeKitGeometry *wkbPolygon = [self loadWKBGeometryFromFile: @"PlanID20-82"];
    wkbPolygon.geometry.title = @"82";
	[theMap addOverlay: wkbPolygon.geometry];

    wkbPolygon = [self loadWKBGeometryFromFile: @"PlanID20-83"];
    wkbPolygon.geometry.title = @"83";
	[theMap addOverlay: wkbPolygon.geometry];

    wkbPolygon = [self loadWKBGeometryFromFile: @"PlanID20-84"];
    wkbPolygon.geometry.title = @"84";
	[theMap addOverlay: wkbPolygon.geometry];
	
/*    NSString *pointString = @"01010000A032BF0D001F5DAEA5C3922340F0A9CA21F60247400000000000309240";
    NSData *geomData = [pointString hexToData];
    ShapeKitGeometry *wkbPoint = [[ShapeKitFactory defaultFactory] geometryWithWKB: geomData];
    wkbPoint.geometry.title = @"85";
	[theMap addOverlay: wkbPoint.geometry];*/
    
    NSString *lineString = @"0102000020E61000002300000007E51089AEA52140103C6E37D7BC46402BECAA6F70A62140111E7D9BE5BC464043656D0049A82140D7DF79A20CBD46408076F4A2CBAA21402D0F98FE44BD4640D89ABC8C2BAC21406A28B75A62BD4640428C8DF88DAD2140F5320B8A82BD46409283A90F36AF21401E169089AABD4640374C3329DFB32140D2F1C0BB15BE4640325F0CFABCB62140FB8661B757BE46400AAD81574CB7214034F91BF864BE4640530A762779B82140C437515680BE4640AECA986EBCB92140BC12FCF69BBE46401F10595FD9BA2140D82C40BBB1BE4640A9688E4C9FBC214088A61DB5CBBE4640987E6C61BDBE2140B154DDC6E6BE4640C3B7E1992EC12140BBC1061800BF46409A3D191D64C32140502F4E7619BF4640DE1C6E01C8C52140C239994B37BF4640588EBA02ECC621404C13F93146BF4640F94D134B36C92140CA0E81D760BF4640CE519C255CCA2140821479576DBF46408A72C98782CB21408BFE79EE78BF46406F9E9222D2CD21409D16D9FE8FBF46406797643F24D02140DBC5325BA4BF4640C9B3123F25D22140538BB144B4BF46403541C04EF5D621408E3468F5D7BF4640B7F127306EDE2140721B221909C0464041EF5994D8E02140091AF8C118C046403C62244A44E321401B47D57B29C04640950BEEB4CCE4214057788BCA33C046409FAD260BF6E721403932C99946C04640B40F83511AEA2140F1EECEE653C0464011F8FF2E46F02140945B112B74C0464043089BC1C9F62140C4BDF76596C046407C840FC3EFF8214082C51CAB9DC04640";
    NSData *geomData = [lineString hexToData];
    ShapeKitGeometry *wkbLine = [[ShapeKitFactory defaultFactory] geometryWithWKB: geomData];
    wkbLine.geometry.title = @"A4 Bergamo-Milano";

	[theMap addOverlay: wkbLine.geometry];
    

}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



#pragma mark -
#pragma mark MapView Delegate methods

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [UIColor redColor];
        polylineView.lineWidth = 5.0;

        return polylineView;
        
    } else if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonView *polygonView = [[MKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [UIColor redColor];
        polygonView.lineWidth = 5.0;
        polygonView.fillColor = [UIColor colorWithRed:0 green:0 blue:255 alpha:0.5];
        
        return polygonView;
    }
	
	return nil;
}

@end
