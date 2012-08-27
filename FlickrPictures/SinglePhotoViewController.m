//
//  PhotoViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 27.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SinglePhotoViewController.h"
#import "FlickrFetcher.h"
#define ACTIVITY_INDICATOR_VIEW_TAG 1024

@interface SinglePhotoViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation SinglePhotoViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photoInfo = _photoInfo;
@synthesize activityIndicator = _activityIndicator;

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

- (NSString *)description
{
    return self.photoInfo.description;
}

#pragma mark - Cache

- (NSURL *)photosCacheDirURL
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *cacheDirURL = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *photosCacheDirURL = [cacheDirURL URLByAppendingPathComponent:@"photos" isDirectory:YES];
    
    if (![fileManager fileExistsAtPath:photosCacheDirURL.path]) {
        [fileManager createDirectoryAtURL:photosCacheDirURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return photosCacheDirURL;
}

- (NSUInteger)sizeOfDirectoryURL:(NSURL *)url
{
    NSUInteger filesize = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directoryString = url.path;
    NSArray *filenames = [fileManager contentsOfDirectoryAtPath:directoryString error:nil];
    for (NSString *filename in filenames) {
        NSError *error;
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[directoryString stringByAppendingPathComponent:filename] error:&error];
        filesize += [fileAttributes fileSize];
    }
    
    return filesize;
}

- (void)cleanUpCacheToFitMaxSize:(NSUInteger)megabytes
{
    if ([self sizeOfDirectoryURL:[self photosCacheDirURL]] < megabytes*1024*1024) {
        return;
    }
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directoryString = [self photosCacheDirURL].path;
    NSArray *filenames = [fileManager contentsOfDirectoryAtPath:directoryString error:nil];

    // remove the oldest files
    // sorted by created datetime desc (oldest first)
    NSArray *filenamesByCreation = [filenames sortedArrayUsingComparator: ^(id a, id b){
        NSDictionary *fileAttributes1 = [fileManager attributesOfItemAtPath:[directoryString stringByAppendingPathComponent:a] error:nil];
        NSDictionary *fileAttributes2 = [fileManager attributesOfItemAtPath:[directoryString stringByAppendingPathComponent:b] error:nil];
        return [[fileAttributes1 fileCreationDate] compare:[fileAttributes2 fileCreationDate]];
    }];
    
    for (NSString *filename in filenamesByCreation) {
        [fileManager removeItemAtPath:[directoryString stringByAppendingPathComponent:filename] error:nil];

        NSUInteger dirSize = [self sizeOfDirectoryURL:[self photosCacheDirURL]];
        if (dirSize < megabytes*1024*1024) break;
    }
}

- (UIImage *)loadImageFromCache:(NSDictionary *)imageInfo
{
    NSURL *filename = [[self photosCacheDirURL] URLByAppendingPathComponent:[imageInfo objectForKey:FLICKR_PHOTO_ID]];
    NSData *imageData = [NSData dataWithContentsOfURL:filename];
    return [UIImage imageWithData:imageData];
}

- (void)saveImageToCache:(UIImage *)image withImageInfo:(NSDictionary *)imageInfo
{
    [self cleanUpCacheToFitMaxSize:2];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSURL *filename = [[self photosCacheDirURL] URLByAppendingPathComponent:[imageInfo objectForKey:FLICKR_PHOTO_ID]];
    [imageData writeToURL:filename atomically:YES];
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
