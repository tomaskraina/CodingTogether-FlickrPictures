//
//  BaseMapViewController.h
//  FlickrPictures
//
//  Created by Tom Kraina on 28.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UIViewController+ActivityIndicatorAsRightBarButtonItem.h"

@interface BaseMapViewController : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
- (MKMapRect) mapRectForAnnotations:(NSArray*)annotationsArray;
@end
