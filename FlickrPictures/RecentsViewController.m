//
//  RecentsViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 26.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentsViewController.h"
#import "FlickrFetcher.h"

#define PHOTOS_PERSISTENCE_KEY @"RecentsViewController.photos"

@implementation RecentsViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)saveDownloadedPhotos
{
    [[NSUserDefaults standardUserDefaults] setObject:self.photos forKey:PHOTOS_PERSISTENCE_KEY];
}

- (void)loadDownloadedPhotos
{
    self.photos = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOS_PERSISTENCE_KEY];
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
