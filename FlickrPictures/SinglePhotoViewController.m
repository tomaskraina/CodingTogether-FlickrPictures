//
//  PhotoViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 27.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SinglePhotoViewController.h"
#import "FlickrFetcher.h"
#import "FileCache.h"
#define ACTIVITY_INDICATOR_VIEW_TAG 1024

@interface SinglePhotoViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) FileCache *cache;
@end

@implementation SinglePhotoViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photoInfo = _photoInfo;
@synthesize activityIndicator = _activityIndicator;
@synthesize cache = _cache;

- (void)setPhotoInfo:(NSDictionary *)photoInfo
{
    _photoInfo = photoInfo;
    self.title = [photoInfo objectForKey:FLICKR_PHOTO_TITLE];
    if (!self.title.length) {
        self.title = [photoInfo objectForKey:FLICKR_PHOTO_DESCRIPTION];
    }
    if (!self.title.length) {
        self.title = NSLocalizedString(@"Unknown Title", @"Photo Table Cell Unknown Title");
    }

}

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        _activityIndicator.tag = ACTIVITY_INDICATOR_VIEW_TAG;
        _activityIndicator.center = self.scrollView.center;
        [self.scrollView addSubview:_activityIndicator];
    }
    
    return _activityIndicator;
}

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator
{
    _activityIndicator = activityIndicator;
    _activityIndicator.tag = ACTIVITY_INDICATOR_VIEW_TAG;
    _activityIndicator.center = self.scrollView.center;
    [[self.scrollView viewWithTag:ACTIVITY_INDICATOR_VIEW_TAG] removeFromSuperview];
    if (activityIndicator) {
        [self.scrollView addSubview:_activityIndicator];
    }
}

- (FileCache *)cache
{
    if (!_cache) {
        _cache = [[FileCache alloc] init];
        _cache.maxSize = 10;
        _cache.domain = @"photos";
    }
    return  _cache;
}

- (NSString *)description
{
    return self.photoInfo.description;
}


- (UIImage *)loadImageFromCache:(NSDictionary *)imageInfo
{
    NSData *imageData = [self.cache dataForKey:[imageInfo objectForKey:FLICKR_PHOTO_ID]];
    return [UIImage imageWithData:imageData];
}

- (void)saveImageToCache:(UIImage *)image withImageInfo:(NSDictionary *)imageInfo
{
    NSData *imageData = UIImagePNGRepresentation(image);
    [self.cache saveData:imageData forKey:[imageInfo objectForKey:FLICKR_PHOTO_ID]];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)setImageToImageView:(UIImage *)image
{
    self.scrollView.contentSize = image.size;
    self.imageView.image = image;
    [self.imageView sizeToFit];
    [self.scrollView zoomToRect:self.imageView.frame animated:NO];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setImageToImageView:[self loadImageFromCache:self.photoInfo]];
    
    // start downloading the photo
    if (!self.imageView.image) {
        [self.activityIndicator startAnimating];
        dispatch_queue_t downloadQueue = dispatch_queue_create("photo downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSURL *photoUrl = [FlickrFetcher urlForPhoto:self.photoInfo format:FlickrPhotoFormatLarge];
            NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
            UIImage *photo = [UIImage imageWithData:photoData];
            [self saveImageToCache:photo withImageInfo:self.photoInfo];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
                [self setImageToImageView:photo];
            });
        });
    }
}

- (void)viewDidUnload
{
    self.scrollView = nil;
    self.imageView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    
}

@end
