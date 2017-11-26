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

@property (weak, nonatomic) IBOutlet UIView *viewForMainGraph;

@property (strong, nonatomic) ScrollableGraphView *mainGraph;

@property (strong, nonatomic) NSMutableArray *dailyAggregates;

@end

@implementation TrendsScoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dailyAggregates = [[NSMutableArray alloc] init];
    [self refreshDailyAggregates];
}

- (void) refreshDailyAggregates
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        
        NSError *error;
        MongoConnection *mongoConnection = [MongoConnection connectionForServer:MONGO_DB_CONNECTION_STRING error:&error];
        MongoDBCollection *dailyReviews = [mongoConnection collectionWithName:MONGO_DB_DAILY_REVIEWS_COLLECTION_NAME];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
        NSDate *startDate = [dateFormatter dateFromString:@"01/11/2017 00:00:00"];
        
        MongoKeyedPredicate *startLimitPredicate = [MongoKeyedPredicate predicate];
        [startLimitPredicate keyPath:@"date" isGreaterThan:startDate];
        
        NSArray *dailyReviewsResults = [dailyReviews findWithPredicate:startLimitPredicate error:&error];
        if(error) {
            NSLog(@"ERROR GETTING DAILY REVIEWS: %@", [error description]);
        }
        
        NSMutableArray *dailyReviewsDicts = [[NSMutableArray alloc] init];
        NSMutableSet *tempDates = [[NSMutableSet alloc] init];
        
        for(BSONDocument *dailyReviewResult in dailyReviewsResults) {
            NSDictionary *decodedObject = [BSONDecoder decodeDictionaryWithDocument:dailyReviewResult];
            if(![tempDates containsObject:[decodedObject objectForKey:@"date"]]) {
                [dailyReviewsDicts addObject:decodedObject];
                [tempDates addObject:[decodedObject objectForKey:@"date"]];
            }
        }
        
        dailyReviewsDicts = [dailyReviewsDicts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSDate *first = [a objectForKey:@"date"];
            NSDate *second = [b objectForKey:@"date"];
            return [first compare:second];
        }];
        
        self.dailyAggregates = [NSMutableArray arrayWithArray:dailyReviewsDicts];
        
        for(NSDictionary *dailyAggregate in self.dailyAggregates) {
            NSLog(@"%@", dailyAggregate);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self showMainGraph];
        });
    });
}

- (void) showMainGraph
{
    if(self.mainGraph) {
        [self.mainGraph removeFromSuperview];
    }
    
    self.mainGraph = [[ScrollableGraphView alloc] initWithFrame:self.viewForMainGraph.frame dataSource:self];
    
    LinePlot *linePlot = [[LinePlot alloc] initWithIdentifier:@"darkLine"];
    linePlot.lineWidth = 1;
    linePlot.lineColor = [UIColor colorFromHexCode:@"#777777"];
    linePlot.lineStyle = ScrollableGraphViewLineStyleSmooth;
    
    linePlot.shouldFill = YES;
    linePlot.fillType = ScrollableGraphViewFillTypeGradient;
    linePlot.fillGradientType = ScrollableGraphViewGradientTypeLinear;
    linePlot.fillGradientStartColor = [UIColor colorFromHexCode:@"#555555"];
    linePlot.fillGradientEndColor = [UIColor colorFromHexCode:@"#444444"];
    
    linePlot.adaptAnimationType = ScrollableGraphViewAnimationTypeElastic;
    
    DotPlot *dotPlot = [[DotPlot alloc] initWithIdentifier:@"darkLineDot"];
    dotPlot.dataPointSize = 2;
    dotPlot.dataPointFillColor = [UIColor whiteColor];
    
    dotPlot.adaptAnimationType = ScrollableGraphViewAnimationTypeElastic;
    
    
    ReferenceLines *referenceLines = [[ReferenceLines alloc] init];
    
    referenceLines.referenceLineLabelFont = [UIFont boldSystemFontOfSize:8];
    referenceLines.referenceLineColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    referenceLines.referenceLineLabelColor = [UIColor whiteColor];
    
    referenceLines.positionType = ReferenceLinePositioningTypeAbsolute;
    referenceLines.absolutePositions = @[@(10), @(20), @(25), @(30)];
    referenceLines.includeMinMax = NO;
    
    referenceLines.dataPointLabelColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    
    self.mainGraph.backgroundFillColor = [UIColor colorFromHexCode:@"#333333"];
    self.mainGraph.dataPointSpacing = 80;
    
    self.mainGraph.shouldAnimateOnStartup = YES;
    self.mainGraph.shouldAdaptRange = YES;
    self.mainGraph.shouldRangeAlwaysStartAtZero = YES;
    
    self.mainGraph.rangeMax = 50;
    
    // Add everything to the graph.
    [self.mainGraph addReferenceLinesWithReferenceLines:referenceLines];
    [self.mainGraph addPlotWithPlot:linePlot];
    [self.mainGraph addPlotWithPlot:dotPlot];
    
    [self.view addSubview:self.mainGraph];
    NSLog(@"SHOULD HAVE ADDED");
}

// Implement ScrollableGraphViewDataSource
- (double)valueForPlot:(Plot * _Nonnull)plot atIndex:(NSInteger)pointIndex {
    //double value = [self.data[pointIndex] doubleValue];
    //return value;
    NSDictionary *dailyAggregate = [self.dailyAggregates objectAtIndex:pointIndex];
    return [[dailyAggregate objectForKey:@"transaction_score"] doubleValue];
}

- (NSString * _Nonnull)labelAtIndex:(NSInteger)pointIndex {
    return @"label";
}

- (NSInteger)numberOfPoints
{
    return [self.dailyAggregates count];
}


@end
