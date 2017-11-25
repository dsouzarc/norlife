//
//  DailyScoreView.h
//  Norlife
//
//  Created by Ryan D'souza on 11/25/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Constants.h"

@interface DailyScoreView : UICollectionViewCell

@property (weak, nonatomic) IBOutlet WMGaugeView *scoreChangeGauge;


@property (weak, nonatomic) IBOutlet UILabel *currentScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentChangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueChangeLabel;

- (instancetype) initWithFrame:(CGRect)frame yesterdayScore:(float)yesterdayScore todayScore:(float)todayScore;

- (void) setupViewWithYesterdayScore:(float)yesterdayScore todayScore:(float)todayScore;

- (void) setupScoreLabels;
- (void) setupGaugeView;

@end
