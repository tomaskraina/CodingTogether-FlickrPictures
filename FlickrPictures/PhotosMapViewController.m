//
//  PhotosMapViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 28.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosMapViewController.h"
#import "FlickrFetcher.h"
#import "MapAnnotation.h"
#import "FileCache.h"
#import "SinglePhotoViewController.h"

@interface PhotosMapViewController()
@property (strong, nonatomic) FileCache *cache;
@property (nonatomic) BOOL needsReloadData;
@end

@implementation PhotosMapViewController
@synthesize photos = _photos;
@synthesize cache = _cache;
@synthesize needsReloadData = _needsReloadData;

- (void)setNeedsReloadData
{
    self.needsReloadData = YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    self.photos = nil;
    self.cache = nil;
}

- (FileCache *)cache
{
    if (!_cache) {
        _cache = [[FileCache alloc] init];
        _cache.maxSize = 10;
        _cache.domain = @"thumbnails";
    }
    return  _cache;
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    NSMutableArray *annotations = [NSMutableArray array];
    
    for (NSDictionary *photoInfo in photos) {
        NSString *title = [photoInfo objectForKey:FLICKR_PHOTO_TITLE];
        NSString *subtitle = [photoInfo objectForKey:FLICKR_PHOTO_DESCRIPTION];
        
        if (!title.length) {
            title = subtitle;
            subtitle = nil;
        }
        if (!title.length) {
            title = NSLocalizedString(@"Unknown Title", @"Photo Annotation Unknown Title");
        }
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[photoInfo objectForKey:FLICKR_LATITUDE] doubleValue], [[photoInfo objectForKey:FLICKR_LONGITUDE] doubleValue]);
        
        MapAnnotation *annotation = [[MapAnnotation alloc] initWithTitle:title subtitle:subtitle coordinate:coordinate info:photoInfo];
        [annotations addObject:annotation];
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

- (void)startDownloadingPhotos
{
    
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    if (self.needsReloadData) {
        [self.activityIndicator startAnimating];
        [self startDownloadingPhotos];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
    [self startDownloadingPhotos];
    self.needsReloadData = NO;
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    self.mapView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *Identifier = @"Photo Annotation";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:Identifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.canShowCallout = YES;
        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    }
    else {
        ((UIImageView *)annotationView.leftCalloutAccessoryView).image = nil;
    }
    
    return annotationView;
}

#define ACTIVITY_INDICATOR_VIEW_TAG 1024
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.tag = ACTIVITY_INDICATOR_VIEW_TAG;
    activityIndicator.contentMode = UIViewContentModeCenter;
    activityIndicator.frame = view.leftCalloutAccessoryView.bounds;
    [activityIndicator startAnimating];
    [view.leftCalloutAccessoryView addSubview:activityIndicator];
    
    dispatch_queue_t loadThumbnailQueue = dispatch_queue_create("thumbnail loader", NULL);
    dispatch_async(loadThumbnailQueue, ^{    
        NSDictionary *photoInfo = [(MapAnnotation *)view.annotation infoDictionary];
        NSData *photoData = [self.cache dataForKey:[photoInfo objectForKey:FLICKR_PHOTO_ID]];
        
        if (!photoData) {
            NSURL *photoURL = [FlickrFetcher urlForPhoto:photoInfo format:FlickrPhotoFormatSquare];
            photoData = [NSData dataWithContentsOfURL:photoURL];
            [self.cache saveData:photoData forKey:[photoInfo objectForKey:FLICKR_PHOTO_ID]];
        }
        
        UIImage *image = [UIImage imageWithData:photoData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[view.leftCalloutAccessoryView viewWithTag:ACTIVITY_INDICATOR_VIEW_TAG] removeFromSuperview];
            [(UIImageView *)view.leftCalloutAccessoryView setImage:image];
        });
    });
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // fire segue
    [self performSegueWithIdentifier:@"Show photo" sender:view];
    
}


#pragma mark - UIStoryboardSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show photo"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MapAnnotation *annotation = [(MKAnnotationView *)sender annotation];
            SinglePhotoViewController *photoViewController = (SinglePhotoViewController *)segue.destinationViewController;
            photoViewController.photoInfo = annotation.infoDictionary;
        }
    }
}

@end
