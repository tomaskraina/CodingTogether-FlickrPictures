//
//  DetailPlaceViewController.h
//  FlickrPictures
//
//  Created by Tom Kraina on 26.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotosViewController.h"

@interface DetailPlaceViewController : PhotosViewController
@property (copy, nonatomic) NSDictionary *locationInfo;
@end
