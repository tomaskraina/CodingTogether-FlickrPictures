//
//  DetailPlaceViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 26.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailPlaceViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@interface DetailPlaceViewController()
@property (strong, nonatomic) NSArray *photos;
@end

@implementation DetailPlaceViewController
@synthesize locationInfo = _locationInfo;
@synthesize photos = _photos;

- (void)setLocationInfo:(NSDictionary *)locationInfo
{
    _locationInfo = locationInfo;
    self.title = [locationInfo objectForKey:FLICKR_PLACE_NAME];
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // download photos from selected location
    dispatch_queue_t downloadQueue = dispatch_queue_create("photos at place downloader", NULL);
    dispatch_async(downloadQueue, ^{
        self.photos = [FlickrFetcher photosInPlace:self.locationInfo maxResults:50];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        PhotoViewController *photoViewController = (PhotoViewController *)segue.destinationViewController;
        photoViewController.photoInfo = [self.photos objectAtIndex:[self.tableView indexPathForCell:sender].row];
    }
}

@end
