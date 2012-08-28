//
//  RecentsMapViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 28.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentsMapViewController.h"
#import "FlickrFetcher.h"

#define PHOTOS_PERSISTENCE_KEY @"RecentsViewController.photos"

@implementation RecentsMapViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    self.photos = nil;
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

@end
