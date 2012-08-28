//
//  PhotosMapViewController.h
//  FlickrPictures
//
//  Created by Tom Kraina on 28.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseMapViewController.h"

@interface PhotosMapViewController : BaseMapViewController
@property (strong, nonatomic) NSArray *photos;
// implement this method in your subclass
// activity indicator animation is automatically started before this method is called
// you must set photos by its property to stop the animation
- (void)startDownloadingPhotos;
- (void)setNeedsReloadData;
@end
