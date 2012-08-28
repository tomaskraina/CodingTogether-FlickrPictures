//
//  BaseMapViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 28.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseMapViewController.h"
#define MAP_TYPE_CONTROL_PERSISTENT_KEY @"BaseMapViewController.mapTypeControl"

@implementation BaseMapViewController
@synthesize mapView = _mapView;
@synthesize mapTypeControl = _mapTypeControl;

- (IBAction)changeMapType:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;            
        default:
            self.mapView.mapType = MKMapTypeStandard;
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:MAP_TYPE_CONTROL_PERSISTENT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (MKMapRect) mapRectForAnnotations:(NSArray*)annotationsArray
{
    MKMapRect mapRect = MKMapRectNull;
    
    //annotations is an array with all the annotations I want to display on the map
    for (id<MKAnnotation> annotation in annotationsArray) { 
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        
        if (MKMapRectIsNull(mapRect)) 
        {
            mapRect = pointRect;
        } else 
        {
            mapRect = MKMapRectUnion(mapRect, pointRect);
        }
    }
    
    return mapRect;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.mapTypeControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:MAP_TYPE_CONTROL_PERSISTENT_KEY];
    [self changeMapType:self.mapTypeControl];
}

@end
