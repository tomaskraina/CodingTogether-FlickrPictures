//
//  TopPlacesViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 26.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopPlacesViewController.h"
#import "FlickrFetcher.h"
#import "DetailPlaceViewController.h"

@interface TopPlacesViewController() <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *places;
@end

@implementation TopPlacesViewController
@synthesize places = _places;

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // download the list of photos from flicker in another thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("top places downloader", NULL);
    dispatch_async(downloadQueue, ^{
        self.places = [FlickrFetcher topPlaces];
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
    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place Table Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *place = [[self.places objectAtIndex:indexPath.row] objectForKey:FLICKR_PLACE_NAME];
    NSUInteger positionOfFirstComma = [place rangeOfString:@","].location;
    cell.textLabel.text = [place substringToIndex:positionOfFirstComma];
    cell.detailTextLabel.text = [place substringFromIndex:positionOfFirstComma+2];
    
    return cell;
}

#pragma mark - UIStoryboardSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show photos at location"]) {
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            DetailPlaceViewController *detailViewController = (DetailPlaceViewController *)segue.destinationViewController;
            detailViewController.locationInfo = [self.places objectAtIndex:[self.tableView indexPathForCell:sender].row];
        }
    }
}

@end
