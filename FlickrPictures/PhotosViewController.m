//
//  PhotosViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 27.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosViewController.h"
#import "FlickrFetcher.h"
#import "SinglePhotoViewController.h"
#import "DetailPlaceMapViewController.h"
#import "FileCache.h"

@interface PhotosViewController() <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) FileCache *cache;
@end

@implementation PhotosViewController
@synthesize photos = _photos;
@synthesize cache = _cache;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.activityIndicator stopAnimating];
    });
}

- (void)startDownloadingPhotos
{
    
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.activityIndicator startAnimating];
    [self startDownloadingPhotos];
}


#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photos.count;
}

#define ACTIVITY_INDICATOR_VIEW_TAG 1024

- (void)addActivityIndicatorToView:(UIView *)view
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.tag = ACTIVITY_INDICATOR_VIEW_TAG;
    activityIndicator.contentMode = UIViewContentModeCenter;
    activityIndicator.frame = view.bounds;
    [activityIndicator startAnimating];
    [view addSubview:activityIndicator];
}

- (void)removeActivityIndicatorFromView:(UIView *)view
{
    [[view viewWithTag:ACTIVITY_INDICATOR_VIEW_TAG] removeFromSuperview];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo Table Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *photoInfo = [self.photos objectAtIndex:indexPath.row];
    cell.textLabel.text = [photoInfo objectForKey:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [photoInfo objectForKey:FLICKR_PHOTO_DESCRIPTION];
    
    if (!cell.textLabel.text.length) {
        cell.textLabel.text = cell.detailTextLabel.text;
        cell.detailTextLabel.text = nil;
    }
    if (!cell.textLabel.text.length) {
        cell.textLabel.text = NSLocalizedString(@"Unknown Title", @"Photo Table Cell Unknown Title");
    }
    
    // Activity indicator & image
    cell.imageView.image = [UIImage imageNamed:@"placeholder"];
    [self addActivityIndicatorToView:cell.imageView];

    dispatch_queue_t loadThumbnailQueue = dispatch_queue_create("thumbnail loader", NULL);
    dispatch_async(loadThumbnailQueue, ^{
        NSData *photoData = [self.cache dataForKey:[photoInfo objectForKey:FLICKR_PHOTO_ID]];
        
        if (!photoData) {
            NSURL *photoURL = [FlickrFetcher urlForPhoto:photoInfo format:FlickrPhotoFormatSquare];
            photoData = [NSData dataWithContentsOfURL:photoURL];
            [self.cache saveData:photoData forKey:[photoInfo objectForKey:FLICKR_PHOTO_ID]];
        }
        
        UIImage *image = [UIImage imageWithData:photoData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeActivityIndicatorFromView:cell.imageView];
            [cell.imageView setImage:image];
        });
    });
    
    return cell;
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    

}

#pragma mark - UIStoryboardSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show photo"]) {
        SinglePhotoViewController *photoViewController = (SinglePhotoViewController *)segue.destinationViewController;
        photoViewController.photoInfo = [self.photos objectAtIndex:[self.tableView indexPathForCell:sender].row];
    }
}

@end
