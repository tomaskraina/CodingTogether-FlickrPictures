//
//  ActivityIndicatorTableViewController.m
//  FlickrPictures
//
//  Created by Tom Kraina on 27.08.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActivityIndicatorTableViewController.h"
#define ACTIVITY_INDICATOR_VIEW_TAG 1024

@implementation ActivityIndicatorTableViewController
@synthesize activityIndicator = _activityIndicator;

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        _activityIndicator.tag = ACTIVITY_INDICATOR_VIEW_TAG;
        UIBarButtonItem *activityBarItem = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];
        self.navigationItem.rightBarButtonItem = activityBarItem;
    }
    
    return _activityIndicator;
}

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator
{
    _activityIndicator = activityIndicator;
    if (activityIndicator) {
        _activityIndicator.tag = ACTIVITY_INDICATOR_VIEW_TAG;
        UIBarButtonItem *activityBarItem = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];
        self.navigationItem.rightBarButtonItem = activityBarItem;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

@end
