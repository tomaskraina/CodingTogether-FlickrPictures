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

@interface PhotosViewController() <UITableViewDelegate, UITableViewDataSource>
@end

@implementation PhotosViewController
@synthesize photos = _photos;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData];
    [self.activityIndicator stopAnimating];
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
    
    return cell;
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
