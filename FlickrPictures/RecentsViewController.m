//
//  RecentsViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 26.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentsViewController.h"
#import "FlickrFetcher.h"
#import "RecentsMapViewController.h"

#define PHOTOS_PERSISTENCE_KEY @"RecentsViewController.photos"

@implementation RecentsViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)saveDownloadedPhotos
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.photos forKey:PHOTOS_PERSISTENCE_KEY];
    [defaults synchronize];
    
}

- (void)loadDownloadedPhotos
{
    self.photos = [[NSUserDefaults standardUserDefaults] arrayForKey:PHOTOS_PERSISTENCE_KEY];
}

- (void)startDownloadingPhotos
{
    // download 20 the most recently viewed photos
    dispatch_queue_t downloadQueue = dispatch_queue_create("recent photos downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher recentGeoreferencedPhotos];
        self.photos = [photos subarrayWithRange:NSMakeRange(0, 20)];
        [self saveDownloadedPhotos];
    });
}

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadDownloadedPhotos];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"Show photo on the map"]) {
        RecentsMapViewController *mapViewController = (RecentsMapViewController *)segue.destinationViewController;
        mapViewController.photos = self.photos;
        mapViewController.selectedPhoto = [self.photos objectAtIndex:[self.tableView indexPathForCell:sender].row];
    }
}

@end
