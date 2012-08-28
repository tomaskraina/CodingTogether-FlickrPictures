//
//  UIViewController+ActivityIndicatorAsRightBarButtonItem.h
//  FlickrPictures
//
//  Created by Tom Kraina on 28.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ActivityIndicatorAsRightBarButtonItem)
- (UIActivityIndicatorView *)activityIndicator;
- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator;
@end
