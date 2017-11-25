//
//  TrendsScoreViewController.m
//  Norlife
//
//  Created by Ryan D'souza on 11/25/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "TrendsScoreViewController.h"

#import "Norlife-Swift.h"

@interface TrendsScoreViewController ()

@property (strong, nonatomic) NSArray* data;
@property NSInteger numberOfDataItems;

@end

@implementation TrendsScoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numberOfDataItems = 30;
    
    self.data = [Random generateRandomData:self.numberOfDataItems max:100 shouldIncludeOutliers:false];
    
    ScrollableGraphView* graphView = [[ScrollableGraphView alloc] initWithFrame: self.view.frame dataSource: self];
    LinePlot* plot = [[LinePlot alloc] initWithIdentifier:@"linePlot"];
    ReferenceLines* referenceLines = [[ReferenceLines alloc] init];
    
    [graphView addPlotWithPlot:plot];
    [graphView addReferenceLinesWithReferenceLines:referenceLines];
    
    [self.view addSubview: graphView];
}

// Implement ScrollableGraphViewDataSource
- (double)valueForPlot:(Plot * _Nonnull)plot atIndex:(NSInteger)pointIndex {
    double value = [self.data[pointIndex] doubleValue];
    return value;
}

- (NSString * _Nonnull)labelAtIndex:(NSInteger)pointIndex {
    return @"label";
}

- (NSInteger)numberOfPoints {
    return self.numberOfDataItems;
}


@end
