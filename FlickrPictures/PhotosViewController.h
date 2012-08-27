//
//  PhotosViewController.h
//  FlickrPictures
//
//  Created by Tom Kraina on 27.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityIndicatorTableViewController.h"

@interface PhotosViewController : ActivityIndicatorTableViewController
@property (strong, nonatomic) NSArray *photos;
// implement this method in your subclass
// activity indicator animation is automatically started before this method is called
// you must set photos by its property to stop the animation
- (void)startDownloadingPhotos;
@end
