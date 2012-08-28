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
@property (strong, nonatomic) NSDictionary *placesByCountries;
@property (strong, nonatomic) NSOrderedSet *countries;
@end

@implementation TopPlacesViewController
@synthesize places = _places;
@synthesize placesByCountries = _placesByCountries;
@synthesize countries = _countries;

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    
    NSMutableOrderedSet *countries = [NSMutableOrderedSet orderedSet];
    NSMutableDictionary *placesByCountry = [NSMutableDictionary dictionary];
    for (NSDictionary *place in places) {
        NSString *placeName = [place objectForKey:FLICKR_PLACE_NAME];
        NSUInteger positionOfLastComma = [placeName rangeOfString:@"," options:NSBackwardsSearch].location;
        NSString *country = [placeName substringFromIndex:positionOfLastComma+1];
        [countries addObject:country];
        
        NSMutableArray *arrayForCountry = [placesByCountry objectForKey:country];
        if (!arrayForCountry) arrayForCountry = [NSMutableArray array];
        [arrayForCountry addObject:place];
        [placesByCountry setObject:arrayForCountry forKey:country];
    }
    self.countries = countries;
    self.placesByCountries = placesByCountry;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.activityIndicator stopAnimating];
    });
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
    [self.activityIndicator startAnimating];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.countries.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *country = [self.countries objectAtIndex:section];
    return [[self.placesByCountries objectForKey:country] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.countries objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place Table Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *country = [self.countries objectAtIndex:indexPath.section];
    NSArray *placesForCountry = [self.placesByCountries objectForKey:country];
    NSString *place = [[placesForCountry objectAtIndex:indexPath.row] objectForKey:FLICKR_PLACE_NAME];
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
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            NSString *country = [self.countries objectAtIndex:indexPath.section];
            NSArray *placesForCountry = [self.placesByCountries objectForKey:country];
            DetailPlaceViewController *detailViewController = (DetailPlaceViewController *)segue.destinationViewController;
            detailViewController.locationInfo = [placesForCountry objectAtIndex:indexPath.row];
        }
    }
}

@end
