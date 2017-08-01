//
//  DetailViewController.h
//  PSI
//
//  Created by ihsan husnul on 7/28/17.
//  Copyright © 2017 ihsan.husnul@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import <Charts/Charts-Swift.h>

@interface DetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet LineChartView *chartView;

@property (nonatomic) NSString *region;
@property (nonatomic) NSArray *readings;
@property (nonatomic) NSString *api_info;

@end
