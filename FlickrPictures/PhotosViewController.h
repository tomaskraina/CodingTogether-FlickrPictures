//
//  PhotosViewController.h
//  FlickrPictures
//
//  Created by Tom Kraina on 27.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosViewController : UITableViewController
@property (strong, nonatomic) NSArray *photos;
// implement this method in your subclass
- (void)startDownloadingPhotos;
@end
