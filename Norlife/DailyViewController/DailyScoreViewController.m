//
//  DailyScoreViewController.m
//  Norlife
//
//  Created by Ryan D'souza on 11/25/17.
//  Copyright © 2017 Ryan D'souza. All rights reserved.
//

#import "DailyScoreViewController.h"

@interface DailyScoreViewController ()

@property (strong, nonatomic) IBOutlet UINavigationBar *mainNavigationBar;
@property (strong, nonatomic) UIImage *chosenImage;

@end

@implementation DailyScoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction) pressedComposeButton:(id)sender
{
    TGCameraNavigationController *navigationController = [TGCameraNavigationController newWithCameraDelegate:self];
    [TGCamera setOption:kTGCameraOptionHiddenFilterButton value:@(YES)];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void) cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) cameraDidTakePhoto:(UIImage *)image
{
    self.chosenImage = image;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        NSDictionary *foodAttributes = [[[FoodClassifierHandler alloc] initWithImage:self.chosenImage] classifyImage];
        NSLog(@"%@", foodAttributes);
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image
{
    self.chosenImage = image;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        NSDictionary *foodAttributes = [[[FoodClassifierHandler alloc] initWithImage:self.chosenImage] classifyImage];
        NSLog(@"%@", foodAttributes);
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
