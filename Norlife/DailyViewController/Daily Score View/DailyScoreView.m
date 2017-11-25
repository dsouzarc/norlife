//
//  DailyScoreView.m
//  Norlife
//
//  Created by Ryan D'souza on 11/25/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "DailyScoreView.h"

@interface DailyScoreView()

@property float yesterdayScore;
@property float todayScore;

@end

@implementation DailyScoreView

- (instancetype) initWithFrame:(CGRect)frame yesterdayScore:(float)yesterdayScore todayScore:(float)todayScore
{
    self = [super initWithFrame:frame];
    
    self.yesterdayScore = yesterdayScore;
    self.todayScore = todayScore;
    
    return self;
}

- (void) setupViewWithYesterdayScore:(float)yesterdayScore todayScore:(float)todayScore
{
    self.yesterdayScore = yesterdayScore;
    self.todayScore = todayScore;
    [self setupScoreLabels];
    [self setupGaugeView];
}
    
- (void) setupScoreLabels
{
    double valueChange = self.todayScore - self.yesterdayScore;
    double percentChange = (valueChange / self.yesterdayScore) * 100.0;
    NSLog(@"PERCENT CHANGE: %.2f\t%.2f", valueChange, self.yesterdayScore);
    
    [self.currentScoreLabel setText:[NSString stringWithFormat:@"%.2f", self.todayScore]];
    
    UIColor *changeColor = [UIColor blackColor];
    if(valueChange < 0.0) {
        changeColor = [UIColor redColor];
    } else if(valueChange > 0.0) {
        changeColor = [UIColor greenColor];
    }
    
    NSString *valueChangeString;
    NSString *percentChangeString;
    
    if(valueChange > 0.0) {
        valueChangeString = [NSString stringWithFormat:@"+ %.2f", valueChange];
        percentChangeString = [NSString stringWithFormat:@"+ (%.2f%%)", percentChange];
    } else {
        valueChangeString = [NSString stringWithFormat:@"%.2f", valueChange];
        percentChangeString = [NSString stringWithFormat:@"(%.2f%%)", percentChange];
    }
    
    [self.valueChangeLabel setAttributedText:[Constants string:valueChangeString color:changeColor]];
    [self.percentChangeLabel setAttributedText:[Constants string:percentChangeString color:changeColor]];
    
    NSMutableArray *randomIntervals = [NSMutableArray arrayWithObjects:@(100.0),
                                       @(self.todayScore * 0.5),
                                       self.todayScore * 1.3 < 100.0 ? @(self.todayScore * 1.3 ) : @(99.9),
                                       @(self.todayScore * 0.8),
                                       @(self.todayScore), nil];
    [self recursiveScoreAnimationForScore:self.todayScore randomIntervals:randomIntervals];
}

- (void) recursiveScoreAnimationForScore:(double)score randomIntervals:(NSMutableArray*)randomIntervals
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        sleep(1.1);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if([randomIntervals count] == 0) {
                [self.scoreChangeGauge setValue:score animated:YES];
                return;
            }
            [self.scoreChangeGauge setValue: [[randomIntervals objectAtIndex:0] doubleValue] animated:YES];
            [randomIntervals removeObjectAtIndex:0];
            [self recursiveScoreAnimationForScore:score randomIntervals:randomIntervals];
        });
    });
}

- (void) setupGaugeView
{
    [self.scoreChangeGauge setBackgroundColor:[UIColor colorFromHexCode:@"#D6E4F0"]];
    self.scoreChangeGauge.layer.cornerRadius = 50;
    self.scoreChangeGauge.layer.masksToBounds = true;
    
    self.scoreChangeGauge.style = [WMGaugeViewStyleFlatThin new];
    self.scoreChangeGauge.maxValue = 100.0;
    self.scoreChangeGauge.scaleDivisions = 10;
    self.scoreChangeGauge.scaleSubdivisions = 5;
    self.scoreChangeGauge.scaleStartAngle = 30;
    self.scoreChangeGauge.scaleEndAngle = 330;
    self.scoreChangeGauge.showScaleShadow = NO;
    self.scoreChangeGauge.scaleFont = [UIFont fontWithName:@"AvenirNext-UltraLight" size:0.065];
    self.scoreChangeGauge.scalesubdivisionsAligment = WMGaugeViewSubdivisionsAlignmentCenter;
    self.scoreChangeGauge.scaleSubdivisionsWidth = 0.002;
    self.scoreChangeGauge.scaleSubdivisionsLength = 0.04;
    self.scoreChangeGauge.scaleDivisionsWidth = 0.007;
    self.scoreChangeGauge.scaleDivisionsLength = 0.07;
    
    self.scoreChangeGauge.rangeValues = @[@20, @40, @60, @80, @100];
    self.scoreChangeGauge.rangeLabels = @[@"Very risky", @"Risky", @"Average", @"Good", @"Great"];
    self.scoreChangeGauge.showRangeLabels = YES;
    self.scoreChangeGauge.rangeColors = @[[UIColor colorFromHexCode:@"#E46161"],
                                        [UIColor colorFromHexCode:@"#EF7E56"],
                                        [UIColor colorFromHexCode:@"#F8F398"],
                                        [UIColor colorFromHexCode:@"#C7E78B"],
                                        [UIColor colorFromHexCode:@"#81AE64"]];
    self.scoreChangeGauge.rangeLabelsFontColor = [UIColor blackColor];
    
}

@end
