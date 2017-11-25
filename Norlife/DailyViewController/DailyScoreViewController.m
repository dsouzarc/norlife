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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mainDropdownMenu setDropdownShowsBorder:YES];
    [self.mainDropdownMenu setBackgroundColor:[UIColor colorWithRed:0.29 green:0.37 blue:1.00 alpha:1.0]];
    
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        [[[FoodClassifierHandler alloc]
          initWithImageURL:@"https://az616578.vo.msecnd.net/files/2016/03/11/635933105470950505-1562028560_Breakfast-Food-Idea-A1.jpg"
          forDate:[NSDate date]] classifyImage];
    }); */
    
    [self.scoreGaugeView setBackgroundColor:[UIColor whiteColor]];
    
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
    
    [self setupScoreLabels];
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

@end
