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
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;

@property (strong, nonatomic) UIImage *chosenImage;
@property NSInteger lastChosenMenuItem;

@end

@implementation DailyScoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mainDropdownMenu setDropdownShowsBorder:YES];
    [self.mainDropdownMenu setBackgroundColor:[UIColor colorWithRed:0.29 green:0.37 blue:1.00 alpha:1.0]];

    [self.mainCollectionView registerNib:[UINib nibWithNibName:@"DailyScoreView" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"DailyScoreViewIdentifier"];
    
    //[self updateMongoFood];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DailyScoreView *scoreView = [collectionView dequeueReusableCellWithReuseIdentifier:@"DailyScoreViewIdentifier"
                                                                          forIndexPath:indexPath];
    [scoreView setupViewWithYesterdayScore:indexPath.section todayScore:90.7];
    return scoreView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.frame), 400.0);
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
