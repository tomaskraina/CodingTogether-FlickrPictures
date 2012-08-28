//
//  UIViewController+ActivityIndicatorAsRightBarButtonItem.m
//  FlickrPictures
//
//  Created by Tom Kraina on 28.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+ActivityIndicatorAsRightBarButtonItem.h"
#define ACTIVITY_INDICATOR_VIEW_TAG 1024

@implementation UIViewController (ActivityIndicatorAsRightBarButtonItem)

- (UIActivityIndicatorView *)activityIndicator
{
    UIView *activityIndicator = self.navigationItem.rightBarButtonItem.customView;
    if (!activityIndicator || ![activityIndicator isKindOfClass:[UIActivityIndicatorView class]]) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        activityIndicator.tag = ACTIVITY_INDICATOR_VIEW_TAG;
        UIBarButtonItem *activityBarItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        self.navigationItem.rightBarButtonItem = activityBarItem;
    }
    
    return (UIActivityIndicatorView *)activityIndicator;
}

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator
{
    if (activityIndicator) {
        activityIndicator.tag = ACTIVITY_INDICATOR_VIEW_TAG;
        UIBarButtonItem *activityBarItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        self.navigationItem.rightBarButtonItem = activityBarItem;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

@end
