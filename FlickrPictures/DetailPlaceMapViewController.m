//
//  DetailPlaceMapViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 28.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailPlaceMapViewController.h"
#import "FlickrFetcher.h"
#import "MapAnnotation.h"
#define DEFAULT_CITY_MAP_RADIUS 30000 // in meters

@implementation DetailPlaceMapViewController
@synthesize locationInfo = _locationInfo;

- (void)setLocationInfo:(NSDictionary *)locationInfo
{
    if (![_locationInfo isEqualToDictionary:locationInfo]) {
        _locationInfo = locationInfo;
        self.title = [locationInfo objectForKey:FLICKR_PLACE_NAME];
        [self setNeedsReloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake([[self.locationInfo objectForKey:FLICKR_LATITUDE] doubleValue], [[self.locationInfo objectForKey:FLICKR_LONGITUDE] doubleValue]);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, DEFAULT_CITY_MAP_RADIUS, DEFAULT_CITY_MAP_RADIUS);
    [self.mapView setRegion:region];
}

- (void)startDownloadingPhotos
{
    // download photos from selected location
    dispatch_queue_t downloadQueue = dispatch_queue_create("photos at place downloader", NULL);
    dispatch_async(downloadQueue, ^{
        self.photos = [FlickrFetcher photosInPlace:self.locationInfo maxResults:50];
    });
}

@end
