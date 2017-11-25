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

@property (strong, nonatomic) UIImage *chosenImage;
@property NSInteger lastChosenMenuItem;

@end

@implementation DailyScoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mainDropdownMenu setDropdownShowsBorder:YES];
    [self.mainDropdownMenu setBackgroundColor:[UIColor colorWithRed:0.29 green:0.37 blue:1.00 alpha:1.0]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        [[[FoodClassifierHandler alloc] initWithImageURL:@"https://az616578.vo.msecnd.net/files/2016/03/11/635933105470950505-1562028560_Breakfast-Food-Idea-A1.jpg"] classifyImage];
    });
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
        [[[FoodClassifierHandler alloc] initWithImage:self.chosenImage] classifyImage];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image
{
    self.chosenImage = image;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        if(self.lastChosenMenuItem == 1) {
            [[[FoodClassifierHandler alloc] initWithImage:self.chosenImage] classifyImage];
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
