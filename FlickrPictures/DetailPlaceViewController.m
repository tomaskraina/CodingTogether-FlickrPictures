//
//  DetailPlaceViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 26.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailPlaceViewController.h"
#import "FlickrFetcher.h"
#import "SinglePhotoViewController.h"
#import "DetailPlaceMapViewController.h"

@implementation DetailPlaceViewController
@synthesize locationInfo = _locationInfo;

- (void)setLocationInfo:(NSDictionary *)locationInfo
{
    _locationInfo = locationInfo;
    self.title = [locationInfo objectForKey:FLICKR_PLACE_NAME];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)startDownloadingPhotos
{
    // download photos from selected location
    dispatch_queue_t downloadQueue = dispatch_queue_create("photos at place downloader", NULL);
    dispatch_async(downloadQueue, ^{
        self.photos = [FlickrFetcher photosInPlace:self.locationInfo maxResults:50];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"Show photo on the map"]) {
        DetailPlaceMapViewController *detailViewController = (DetailPlaceMapViewController *)segue.destinationViewController;
        detailViewController.locationInfo = self.locationInfo;
        detailViewController.photos = self.photos;
        detailViewController.selectedPhoto = [self.photos objectAtIndex:[self.tableView indexPathForCell:sender].row];
    }
}

@end
