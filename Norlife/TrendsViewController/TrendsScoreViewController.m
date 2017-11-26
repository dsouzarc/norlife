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
@property (weak, nonatomic) IBOutlet MKDropdownMenu *dropdownMenu;

@property (weak, nonatomic) IBOutlet UIView *viewForMainGraph;
@property (weak, nonatomic) IBOutlet UILabel *graphTitleLabel;

@property (strong, nonatomic) ScrollableGraphView *mainGraph;
@property (strong, nonatomic) LinePlot *scorePlot;
@property (strong, nonatomic) LinePlot *drivingPlot;
@property (strong, nonatomic) LinePlot *transactionPlot;
@property (strong, nonatomic) LinePlot *foodPlot;
@property (strong, nonatomic) LinePlot *commutePlot;
@property (strong, nonatomic) LinePlot *heartbeatPlot;

@property (strong, nonatomic) NSMutableDictionary *plotsAndIdentifiers;
@property (strong, nonatomic) NSMutableArray *dailyAggregatesData;

@property float plotMinY;
@property float plotMaxY;

@end

@implementation TrendsScoreViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.dailyAggregatesData = [[NSMutableArray alloc] init];
        [self refreshDailyAggregates];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.graphTitleLabel setText:@""];
    [self.dropdownMenu setDropdownShowsBorder:YES];
    [self.dropdownMenu setBackgroundColor:[UIColor lightNordeaBlue]];
    
    [self refreshDailyAggregates];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    
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
        
        self.plotMaxY = INT_MIN;
        self.plotMinY = INT_MAX;
        
        for(BSONDocument *dailyReviewResult in dailyReviewsResults) {
            
            NSDictionary *decodedObject = [BSONDecoder decodeDictionaryWithDocument:dailyReviewResult];
            
            if(![tempDates containsObject:[decodedObject objectForKey:@"date"]]) {
                [dailyReviewsDicts addObject:decodedObject];
                [tempDates addObject:[decodedObject objectForKey:@"date"]];
                
                for(NSString *key in [decodedObject allKeys]) {
                    if([key containsString:@"score"]) {
                        
                        if([[decodedObject objectForKey:key] floatValue] > self.plotMaxY) {
                            self.plotMaxY = [[decodedObject objectForKey:key] floatValue];
                        }
                        
                        if([[decodedObject objectForKey:key] floatValue] < self.plotMinY) {
                            self.plotMinY = [[decodedObject objectForKey:key] floatValue];
                        }
                    }
                }
            }
        }
        
        dailyReviewsDicts = [dailyReviewsDicts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSDate *first = [a objectForKey:@"date"];
            NSDate *second = [b objectForKey:@"date"];
            return [first compare:second];
        }];
        
        self.dailyAggregatesData = [NSMutableArray arrayWithArray:dailyReviewsDicts];
        
        for(NSDictionary *dailyAggregate in self.dailyAggregatesData) {
            NSLog(@"%@", dailyAggregate);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self initializePlots];
            [self showPlotWithIdentifier:@"total_score"];
            [self.graphTitleLabel setText:@"Your Score"];
        });
    });
}

- (void) showPlotWithIdentifier:(NSString*)identifier
{
    if(self.mainGraph) {
        [self.mainGraph removeFromSuperview];
    }
    
    self.mainGraph = [[ScrollableGraphView alloc] initWithFrame:self.viewForMainGraph.frame dataSource:self];
    
    LinePlot *linePlot = [self.plotsAndIdentifiers objectForKey:identifier];
    linePlot.lineWidth = 1;
    linePlot.lineColor = [UIColor lightNordeaBlue]; // colorFromHexCode:@"#777777"];
    linePlot.lineStyle = ScrollableGraphViewLineStyleSmooth;
    linePlot.shouldFill = YES;
    linePlot.fillType = ScrollableGraphViewFillTypeGradient;
    linePlot.fillGradientType = ScrollableGraphViewGradientTypeLinear;
    linePlot.fillGradientStartColor = [UIColor lightNordeaBlue]; //colorFromHexCode: @"#555555"];
    linePlot.fillGradientEndColor = [UIColor lightNordeaBlue]; // colorFromHexCode:@"#444444"];
    linePlot.adaptAnimationType = ScrollableGraphViewAnimationTypeElastic;
    
    DotPlot *dotPlot = [[DotPlot alloc] initWithIdentifier:[NSString stringWithFormat:@"%@Plot", [linePlot identifier]]];
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
    
    self.mainGraph.backgroundFillColor = [UIColor whiteColor]; //colorFromHexCode:@"#333333"];
    self.mainGraph.dataPointSpacing = self.viewForMainGraph.frame.size.width / (int)[self.dailyAggregatesData count];
    self.mainGraph.shouldAnimateOnStartup = YES;
    //self.mainGraph.shouldAdaptRange = YES;
    self.mainGraph.shouldRangeAlwaysStartAtZero = YES;
    
    self.mainGraph.rangeMin = (self.plotMinY * 0.1) + self.plotMinY;
    self.mainGraph.rangeMax = (self.plotMaxY * 0.1) + self.plotMaxY;
    
    //[self.mainGraph addReferenceLinesWithReferenceLines:referenceLines];
    [self.mainGraph addPlotWithPlot:dotPlot];
    [self.mainGraph addPlotWithPlot:linePlot];
    
    [self.mainGraph setTopMargin:0.02];
    [self.mainGraph setZoomScale:0.9];
    
    [self.view addSubview:self.mainGraph];
}

- (void) initializePlots
{
    self.drivingPlot = [[LinePlot alloc] initWithIdentifier:@"driving_score"];
    self.transactionPlot = [[LinePlot alloc] initWithIdentifier:@"transaction_score"];
    self.scorePlot = [[LinePlot alloc] initWithIdentifier:@"total_score"];
    self.foodPlot = [[LinePlot alloc] initWithIdentifier:@"food_score"];
    self.commutePlot = [[LinePlot alloc] initWithIdentifier:@"commute_score"];
    self.heartbeatPlot = [[LinePlot alloc] initWithIdentifier:@"heartbeat_score"];
    
    self.plotsAndIdentifiers = [[NSMutableDictionary alloc] init];
    [self.plotsAndIdentifiers setObject:self.drivingPlot forKey:[self.drivingPlot identifier]];
    [self.plotsAndIdentifiers setObject:self.transactionPlot forKey:[self.transactionPlot identifier]];
    [self.plotsAndIdentifiers setObject:self.scorePlot forKey:[self.scorePlot identifier]];
    [self.plotsAndIdentifiers setObject:self.foodPlot forKey:[self.foodPlot identifier]];
    [self.plotsAndIdentifiers setObject:self.commutePlot forKey:[self.commutePlot identifier]];
    [self.plotsAndIdentifiers setObject:self.heartbeatPlot forKey:[self.heartbeatPlot identifier]];
}

- (double) valueForPlot:(Plot * _Nonnull)plot atIndex:(NSInteger)pointIndex
{
    NSDictionary *dailyAggregate = [self.dailyAggregatesData objectAtIndex:pointIndex];
    return [[dailyAggregate objectForKey:[plot identifier]] doubleValue];
}

- (NSString * _Nonnull) labelAtIndex:(NSInteger)pointIndex
{
    NSDate *date = [[self.dailyAggregatesData objectAtIndex:pointIndex] objectForKey:@"date"];
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd";
    }
    return [dateFormatter stringFromDate:date];
}

- (NSInteger)numberOfPoints
{
    return [self.dailyAggregatesData count];
}


/****************************************************************
 *
 *              MKDropdownMenu Delegate + Data Source
 *
 *****************************************************************/

# pragma mark - MKDropdownMeny Delegate + Data Source

- (NSInteger) numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu
{
    return 1;
}

- (NSInteger) dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component
{
    return 1;
}

- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return @"Yo";
}

- (void) dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}

- (NSAttributedString*) dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component
{
    NSString *entireTitle = @"Trends for November";
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:entireTitle];
    [attributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]
                            range:NSMakeRange(0, [entireTitle length])];
    
    return attributedTitle;
}


@end

/**
 OLD CODE
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
 //[self.mainGraph addReferenceLinesWithReferenceLines:referenceLines];
 [self.mainGraph addPlotWithPlot:linePlot];
 [self.mainGraph addPlotWithPlot:dotPlot];
 
 [self.mainGraph setZoomScale:0.05];
 
 [self.view addSubview:self.mainGraph];
 NSLog(@"SHOULD HAVE ADDED");
*/
