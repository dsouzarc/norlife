//
//  DailyScoreViewController.m
//  Norlife
//
//  Created by Ryan D'souza on 11/25/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "DailyScoreViewController.h"

@interface DailyScoreViewController ()

@property (weak, nonatomic) IBOutlet MKDropdownMenu *mainDropdownMenu;
@property (weak, nonatomic) IBOutlet WMGaugeView *scoreGaugeView;

@property (weak, nonatomic) IBOutlet UILabel *currentScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentChangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueChangeLabel;

@property (strong, nonatomic) UIImage *chosenImage;
@property NSInteger lastChosenMenuItem;

@end

@implementation DailyScoreViewController

- (void) setupScoreLabels
{
    double todayScore = 89.5;
    double yesterdayScore = 80.5;
    double valueChange = todayScore - yesterdayScore;
    double percentChange = (valueChange / yesterdayScore) * 100.0;
    
    [self.currentScoreLabel setText:[NSString stringWithFormat:@"%.2f", todayScore]];

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
                                       @(todayScore * 0.5),
                                       todayScore * 1.3 < 100.0 ? @(todayScore * 1.3 ) : @(99.9),
                                       @(todayScore * 0.8),
                                       @(todayScore), nil];
    [self recursiveScoreAnimationForScore:todayScore randomIntervals:randomIntervals];
}

- (void) recursiveScoreAnimationForScore:(double)score randomIntervals:(NSMutableArray*)randomIntervals
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        sleep(1.1);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if([randomIntervals count] == 0) {
                [self.scoreGaugeView setValue:score animated:YES];
                return;
            }
            [self.scoreGaugeView setValue: [[randomIntervals objectAtIndex:0] doubleValue] animated:YES];
            [randomIntervals removeObjectAtIndex:0];
            [self recursiveScoreAnimationForScore:score randomIntervals:randomIntervals];
        });
    });
}

- (void) setupGaugeView
{
    [self.scoreGaugeView setBackgroundColor:[UIColor colorFromHexCode:@"#D6E4F0"]];
    self.scoreGaugeView.layer.cornerRadius = 50;
    self.scoreGaugeView.layer.masksToBounds = true;
    
    self.scoreGaugeView.style = [WMGaugeViewStyleFlatThin new];
    self.scoreGaugeView.maxValue = 100.0;
    self.scoreGaugeView.scaleDivisions = 10;
    self.scoreGaugeView.scaleSubdivisions = 5;
    self.scoreGaugeView.scaleStartAngle = 30;
    self.scoreGaugeView.scaleEndAngle = 330;
    self.scoreGaugeView.showScaleShadow = NO;
    self.scoreGaugeView.scaleFont = [UIFont fontWithName:@"AvenirNext-UltraLight" size:0.065];
    self.scoreGaugeView.scalesubdivisionsAligment = WMGaugeViewSubdivisionsAlignmentCenter;
    self.scoreGaugeView.scaleSubdivisionsWidth = 0.002;
    self.scoreGaugeView.scaleSubdivisionsLength = 0.04;
    self.scoreGaugeView.scaleDivisionsWidth = 0.007;
    self.scoreGaugeView.scaleDivisionsLength = 0.07;
    
    self.scoreGaugeView.rangeValues = @[@20, @40, @60, @80, @100];
    self.scoreGaugeView.rangeLabels = @[@"Very risky", @"Risky", @"Average", @"Good", @"Great"];
    self.scoreGaugeView.showRangeLabels = YES;
    self.scoreGaugeView.rangeColors = @[[UIColor colorFromHexCode:@"#E46161"],
                                        [UIColor colorFromHexCode:@"#EF7E56"],
                                        [UIColor colorFromHexCode:@"#F8F398"],
                                        [UIColor colorFromHexCode:@"#C7E78B"],
                                        [UIColor colorFromHexCode:@"#81AE64"]];
    self.scoreGaugeView.rangeLabelsFontColor = [UIColor blackColor];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mainDropdownMenu setDropdownShowsBorder:YES];
    [self.mainDropdownMenu setBackgroundColor:[UIColor colorWithRed:0.29 green:0.37 blue:1.00 alpha:1.0]];
    
    [self setupGaugeView];
    [self setupScoreLabels];
    
    //[self updateMongoFood];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
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
    return 2;
}

- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(row == 0) {
        return @"Upload picture of receipt";
    } else if(row == 1) {
        return @"Upload picture of food";
    }
    return @"";
}

- (void) dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.lastChosenMenuItem = row;
    
    if(row == 1) {
        [dropdownMenu closeAllComponentsAnimated:YES];
        [self pressedComposeButton:nil];
    }
}

- (NSAttributedString*) dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayOfTheWeek = [dateFormatter stringFromDate:[NSDate date]];
    
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSString *restOfDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *entireTitle = [NSString stringWithFormat:@"%@, %@", dayOfTheWeek, restOfDate];
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:entireTitle];
    [attributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]
                            range:NSMakeRange(0, [entireTitle length])];
    
    return attributedTitle;
}


/****************************************************************
 *
 *              TGCameraDelegate
 *
 *****************************************************************/

# pragma mark - TGCameraDelegate

- (void) cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) cameraDidTakePhoto:(UIImage *)image
{
    self.chosenImage = image;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        [[[FoodClassifierHandler alloc] initWithImage:self.chosenImage forDate:[NSDate date]] classifyImage];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image
{
    self.chosenImage = image;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        if(self.lastChosenMenuItem == 1) {
            [[[FoodClassifierHandler alloc] initWithImage:self.chosenImage forDate:[NSDate date]] classifyImage];
        }
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) pressedComposeButton:(id)sender
{
    TGCameraNavigationController *navigationController = [TGCameraNavigationController newWithCameraDelegate:self];
    [TGCamera setOption:kTGCameraOptionHiddenFilterButton value:@(YES)];
    [self presentViewController:navigationController animated:YES completion:nil];
}


/****************************************************************
 *
 *              Miscellaneous
 *
 *****************************************************************/

# pragma mark - Miscellaneous

- (void) updateMongoFood
{
    NSArray *foodImageURLs = @[@"https://i.pinimg.com/originals/7d/42/04/7d4204b53d7d34ff4a59691ea686b832.jpg",
                               @"https://d29vij1s2h2tll.cloudfront.net/~/media/images/taco-bell/products/default/23732_combos_quesarito_combo_300x300.jpg?w=300&h=300",
                               @"http://www.inspiredtaste.net/wp-content/uploads/2016/06/Brownies-Recipe-2-1200.jpg",
                               @"https://images.fastcompany.net/image/upload/w_596,c_limit,q_auto:best,f_auto,fl_lossy/wp-cms/uploads/2017/06/i-1-sonic-burger.jpg",
                               @"https://i1.wp.com/www.thekitchenwhisperer.net/wp-content/uploads/2014/04/BelgianWaffles7.jpg",
                               @"http://www.seriouseats.com/recipes/assets_c/2012/06/20120613-rocky-road-primary-thumb-625xauto-248989.jpg",
                               @"https://upload.wikimedia.org/wikipedia/commons/8/88/Bright_red_tomato_and_cross_section02.jpg",
                               @"https://img.purch.com/h/1000/aHR0cDovL3d3dy5saXZlc2NpZW5jZS5jb20vaW1hZ2VzL2kvMDAwLzA2NS8xNDkvb3JpZ2luYWwvYmFuYW5hcy5qcGc=",
                               @"https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Orange-Whole-%26-Split.jpg/1200px-Orange-Whole-%26-Split.jpg",
                               @"https://draxe.com/wp-content/uploads/2015/04/bigstock-Fresh-green-celery-isolated-on-52080031.jpg",
                               @"http://del.h-cdn.co/assets/15/46/1600x800/landscape-1447112761-delish-thanksgiving-best-ranch-turkey-recipe.jpg",
                               @"http://wdy.h-cdn.co/assets/16/43/980x1470/gallery-1477420459-1450112056-christmas-ham.jpg",
                               @"http://images.scrippsnetworks.com/up/tp/Scripps_-_Food_Category_Prod/6/915/0156087_630x355.jpg",
                               @"http://img.taste.com.au/x9xlREwb/taste/2016/11/cheesy-meatballs-with-spaghetti-23057-1.jpeg"];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        
        NSDate *dateIterator = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        
        for(NSString *foodImageURL in foodImageURLs) {
            [[[FoodClassifierHandler alloc] initWithImageURL:foodImageURL forDate:dateIterator] classifyImage];
            
            dateIterator = [calendar dateByAddingUnit:NSCalendarUnitHour
                                                value:-13
                                               toDate:dateIterator
                                              options:0];
            sleep(5);
        }
        
    });
}

@end
