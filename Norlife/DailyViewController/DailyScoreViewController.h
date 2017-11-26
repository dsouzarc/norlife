//
//  DailyScoreViewController.h
//  Norlife
//
//  Created by Ryan D'souza on 11/25/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FoodClassifierHandler.h"
#import "Constants.h"

@interface DailyScoreViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource,
                                                            TGCameraDelegate, MKDropdownMenuDelegate, MKDropdownMenuDataSource,
                                                            FoodClassifierHandlerDelegate>

@end
