//
//  FoodViewController.h
//  Norlife
//
//  Created by Ryan D'souza on 11/26/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Norlife-Swift.h"
#import "Constants.h"

@interface FoodViewController : UIViewController<ScrollableGraphViewDataSource, MKDropdownMenuDelegate, MKDropdownMenuDataSource, UITableViewDelegate, UITableViewDataSource>

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil foodScores:(NSMutableArray*)foodScores;

@end
