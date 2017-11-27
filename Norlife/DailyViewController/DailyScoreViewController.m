//
//  DailyScoreViewController.m
//  Norlife
//
//  Created by Ryan D'souza on 11/25/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "DailyScoreViewController.h"

static NSString *dailyScoreIdentifier = @"DailyScoreViewIdentifier";
static NSString *dailyFeedbackIdentifier = @"DailyFeedbackCellIdentifier";
static NSString *separatorViewKindIdentifier = @"SeparatorViewKind";

@interface DailyScoreViewController ()

@property (weak, nonatomic) IBOutlet MKDropdownMenu *mainDropdownMenu;
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;

@property (strong, nonatomic) UIImage *chosenImage;
@property NSInteger lastChosenMenuItem;

@property (strong, nonatomic) NSMutableArray<NSDictionary*> *feedbackArray;

@property (strong, nonatomic) FoodClassifierHandler *foodClassifierHandler;
@property (strong, nonatomic) FoodViewController *foodViewController;

@end

@implementation DailyScoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mainDropdownMenu setDropdownShowsBorder:YES];
    [self.mainDropdownMenu setBackgroundColor:[UIColor lightNordeaBlue]];
    
    [self.mainCollectionView registerNib:[UINib nibWithNibName:@"DailyScoreView"
                                                        bundle:[NSBundle mainBundle]]
              forCellWithReuseIdentifier:dailyScoreIdentifier];
    
    [self.mainCollectionView registerNib:[UINib nibWithNibName:@"DailyFeedbackCollectionViewCell"
                                                        bundle:[NSBundle mainBundle]]
              forCellWithReuseIdentifier:dailyFeedbackIdentifier];
    
    [self.mainCollectionView registerClass:[UICollectionReusableView class]
                forSupplementaryViewOfKind:separatorViewKindIdentifier
                       withReuseIdentifier:@"Separator"];
    
    UICollectionViewFlowLayout *mainLayout = (UICollectionViewFlowLayout*) [self.mainCollectionView collectionViewLayout];
    [mainLayout setEstimatedItemSize:CGSizeMake(1, 1)];
    
    self.feedbackArray = [[NSMutableArray alloc] init];
    [self refreshFeedbackTable];
}

- (void) refreshFeedbackTable
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
        [urlRequest setURL:[NSURL URLWithString:TODAYS_FEEDBACK_URL]];
        [urlRequest setHTTPMethod:@"GET"];
        
        NSData *dataResponse = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:dataResponse options:NSJSONReadingMutableLeaves error:nil];
        if(responseDictionary) {
            self.feedbackArray = [[NSMutableArray alloc] init];
            
            double highestScore = INT_MIN;
            NSString *highestKey = @"";
            double lowestScore = INT_MAX;
            NSString *lowestKey = @"";
            
            NSArray *scoresToCheck = @[@"driving_score", @"food_score", @"transaction_score"];
            for(NSString *scoreToCheck in scoresToCheck) {
                if([[responseDictionary objectForKey:scoreToCheck] doubleValue] < lowestScore) {
                    lowestScore = [[responseDictionary objectForKey:scoreToCheck] doubleValue];
                    lowestKey = scoreToCheck;
                }
                if([[responseDictionary objectForKey:scoreToCheck] doubleValue] > highestScore) {
                    highestScore = [[responseDictionary objectForKey:scoreToCheck] doubleValue];
                    highestKey = scoreToCheck;
                }
            }
            
            NSString *negativeFeedback = @"";
            NSString *positiveFeedback = @"";
            
            if([lowestKey isEqualToString:@"driving_score"]) {
                negativeFeedback = @"Your driving score impacted you negatively today - try to slow down and accelerate less sharply. Driving accidents are one of the leading causes of death amongst adolescents.";
            } else if([lowestKey isEqualToString:@"food_score"]) {
                negativeFeedback = @"Your food choices impacted you negatively today - try to eat healthier in the future. A well-balanced and nutritious diet is essential to having a long and happy life.";
            } else if([lowestKey isEqualToString:@"transaction_score"]) {
                negativeFeedback = @"Your purchase choices impacted you negatively today - try to cut back on un-necessary spending. Cheat days are okay, but only when they're occasional.";
            }
            
            if([highestKey isEqualToString:@"driving_score"]) {
                positiveFeedback = @"Great job on the road today! We've taken notice of your excellent driving abilities and will keep it in mind in the future.";
            } else if([highestKey isEqualToString:@"food_score"]) {
                positiveFeedback = @"You've made some great culinary decisions today - keep up the good work!";
            } else if([highestKey isEqualToString:@"transaction_score"]) {
                positiveFeedback = @"Nice money management! That takes real strength and discipline. Keep it up and you'll feel the rewards soon enough :)";
            }
    
            NSDictionary *positiveFeedbackItem = @{@"feedback": @"positive", @"text": positiveFeedback};
            NSDictionary *negativeFeedbackItem = @{@"feedback": @"negative", @"text": negativeFeedback};
            
            [self.feedbackArray addObject:positiveFeedbackItem];
            [self.feedbackArray addObject:negativeFeedbackItem];
        }
    });
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}


/****************************************************************
 *
 *              UICollectionView Delegate + DataSource
 *
 *****************************************************************/

# pragma mark - UICollectionView Delegate + DataSource

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(section == 0) {
        return 1;
    } else if(section == 1) {
        return [self.feedbackArray count];
    }
    return 0;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //Section 1: Daily activity. Section 2: Feedback
    return 2;
}

- (UICollectionReusableView *)collectionView:(UICollectionView*)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *separator = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                             withReuseIdentifier:separatorViewKindIdentifier forIndexPath:indexPath];
    
    if ([kind isEqualToString:separatorViewKindIdentifier]) {
        separator.backgroundColor = [UIColor clearColor];
        
        if (!separator.subviews.count) {
            
        }
    }
    
    return separator;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        DailyScoreView *scoreView = [collectionView dequeueReusableCellWithReuseIdentifier:dailyScoreIdentifier
                                                                              forIndexPath:indexPath];
        [scoreView setupViewWithYesterdayScore:[Constants yesterdayScore] todayScore:[Constants todayScore]];
        return scoreView;
    }
    
    else if([indexPath section] == 1) {
        DailyFeedbackCollectionViewCell *feedbackCell = [collectionView dequeueReusableCellWithReuseIdentifier:dailyFeedbackIdentifier forIndexPath:indexPath];
        
        NSDictionary *feedbackItem = [self.feedbackArray objectAtIndex:[indexPath row]];
        [feedbackCell.feedbackLabel setText:[feedbackItem objectForKey:@"text"]];
        
        if([[feedbackItem objectForKey:@"feedback"] isEqualToString:@"positive"]) {
            feedbackCell.feedbackImageIcon.image = [UIImage imageNamed:@"checkmark_icon.png"];
        } else if([[feedbackItem objectForKey:@"feedback"] isEqualToString:@"negative"]) {
            feedbackCell.feedbackImageIcon.image = [UIImage imageNamed:@"cross_mark_icon.png"];
        }
        
        return feedbackCell;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        return CGSizeMake(CGRectGetWidth(collectionView.frame), 400.0);
    }
    
    else if([indexPath section] == 1) {
        NSDictionary *feedbackItem = [self.feedbackArray objectAtIndex:[indexPath row]];
        NSString *feedback = [feedbackItem objectForKey:@"text"];
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:300.0]};
        return CGSizeMake(CGRectGetWidth(collectionView.frame), [feedback sizeWithAttributes:attributes].height);
    }
    
    return CGSizeZero;
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
    return 3;
}

- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(row == 0) {
        return @"Upload picture of receipt";
    } else if(row == 1) {
        return @"Upload picture of food";
    } else if(row == 2) {
        return @"Messages + Investment Advice";
    }
    return @"";
}

- (void) dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.lastChosenMenuItem = row;
    [dropdownMenu closeAllComponentsAnimated:YES];
    
    if(row == 0 || row == 1) {
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

static MBProgressHUD *hud;

- (void) cameraDidTakePhoto:(UIImage *)image
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"Processing photo";
    
    self.chosenImage = image;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
    
        self.foodClassifierHandler = [[FoodClassifierHandler alloc] initWithImage:self.chosenImage forDate:[NSDate date]];
        self.foodClassifierHandler.delegate = self;
        [self.foodClassifierHandler classifyImage];
        
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"Processing photo";
    
    self.chosenImage = image;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        if(self.lastChosenMenuItem == 1) {
            
            self.foodClassifierHandler = [[FoodClassifierHandler alloc] initWithImage:self.chosenImage forDate:[NSDate date]];
            self.foodClassifierHandler.delegate = self;
            [self.foodClassifierHandler classifyImage];
        }
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) finishedWithFoodScores:(NSMutableArray *)foodScores
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        if(hud) {
            [hud hideAnimated:YES];
            hud = nil;
        }
        
        self.foodViewController = [[FoodViewController alloc] initWithNibName:@"FoodViewController"
                                                                       bundle:[NSBundle mainBundle] foodScores:foodScores];
        [self presentViewController:self.foodViewController animated:YES completion:nil];
    });
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
