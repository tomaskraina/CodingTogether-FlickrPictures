//
//  PhotoViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 27.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"

@interface PhotoViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation PhotoViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photoInfo = _photoInfo;

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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    // start downloading the photo
    if (!self.imageView.image) {
        dispatch_queue_t downloadQueue = dispatch_queue_create("photo downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSURL *photoUrl = [FlickrFetcher urlForPhoto:self.photoInfo format:FlickrPhotoFormatLarge];
            NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
            UIImage *photo = [UIImage imageWithData:photoData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.scrollView.contentSize = photo.size;
                self.imageView.image = photo;
                [self.imageView sizeToFit];
                [self.scrollView zoomToRect:self.imageView.frame animated:NO];

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
