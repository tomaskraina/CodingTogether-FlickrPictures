//
//  TopPlacesMapViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 28.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopPlacesMapViewController.h"
#import "FlickrFetcher.h"
#import "MapAnnotation.h"
#import "DetailPlaceMapViewController.h"

@interface TopPlacesMapViewController()
@property (strong, nonatomic) NSArray *places;
@end

@implementation TopPlacesMapViewController
@synthesize places = _places;

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    
    NSMutableArray *annotations = [NSMutableArray array];
    
    for (NSDictionary *placeInfo in places) {
        NSString *place = [placeInfo objectForKey:FLICKR_PLACE_NAME];
        NSUInteger positionOfFirstComma = [place rangeOfString:@","].location;
        NSString *title = [place substringToIndex:positionOfFirstComma];
        NSString *subtitle = [place substringFromIndex:positionOfFirstComma+2];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[placeInfo objectForKey:FLICKR_LATITUDE] doubleValue], [[placeInfo objectForKey:FLICKR_LONGITUDE] doubleValue]);
        
        MapAnnotation *annotation = [[MapAnnotation alloc] initWithTitle:title subtitle:subtitle coordinate:coordinate info:placeInfo];
        
//        if (![self.mapView.annotations containsObject:annotation]) {
            [annotations addObject:annotation];
//        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // reload data
        // remove unless annotations
        NSMutableArray *annotationsToRemove = [NSMutableArray arrayWithArray:self.mapView.annotations];
        [annotationsToRemove removeObjectsInArray:annotations];
        [self.mapView removeAnnotations:annotationsToRemove];

        // add only new annotations annotations
        [annotations removeObjectsInArray:self.mapView.annotations];
        [self.mapView addAnnotations:[annotations copy]];
        
        [self.mapView setVisibleMapRect:[self mapRectForAnnotations:self.mapView.annotations] animated:YES];
        
        [self.activityIndicator stopAnimating];
    });
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    self.places = nil;
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // download the list of photos from flicker in another thread
    [self.activityIndicator startAnimating];
    dispatch_queue_t downloadQueue = dispatch_queue_create("top places downloader", NULL);
    dispatch_async(downloadQueue, ^{
        self.places = [FlickrFetcher topPlaces];
    });
}


- (void)viewDidUnload
{
    self.mapView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *Identifier = @"Place Annotation";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:Identifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.canShowCallout = YES;
//        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] init];
    }
    else {
//        ((UIImageView *)annotationView.leftCalloutAccessoryView).image = nil;
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // fire segue
    [self performSegueWithIdentifier:@"Show photos at location" sender:view];

}

#pragma mark - UIStoryboardSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show photos at location"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MapAnnotation *annotation = [(MKAnnotationView *)sender annotation];
            DetailPlaceMapViewController *detailViewController = (DetailPlaceMapViewController *)segue.destinationViewController;
            detailViewController.locationInfo = annotation.infoDictionary;
        }
    }
}


@end
