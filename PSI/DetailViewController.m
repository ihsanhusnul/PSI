//
//  DetailViewController.m
//  PSI
//
//  Created by ihsan husnul on 7/28/17.
//  Copyright © 2017 ihsan.husnul@gmail.com. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <ChartViewDelegate> {
    
    __weak IBOutlet UILabel *dateLbl;
}

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _region;
    
    NSString *firstDateString = [_readings firstObject][@"timestamp"];
    NSString *lastDateString = [_readings lastObject][@"timestamp"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sZ"];
    
    NSDate *firstDate = [formatter dateFromString:firstDateString];
    NSDate *lastDate = [formatter dateFromString:lastDateString];
    
    [formatter setDateFormat:@"d,MMM yy HH:mma"];
    
    NSString *betweenString = [NSString stringWithFormat:@"RANGE: %@ until %@", [formatter stringFromDate:firstDate], [formatter stringFromDate:lastDate]];
    
    [dateLbl setText:betweenString];
    
    float maxX = _readings.count;
    float maxY = 60;
    
    [self setDataCount:maxX range:maxY];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setDataCount:(int)count range:(double)range
{
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    NSLog(@"AppSubIndexKeys.count: %lu", (unsigned long)AppSubIndexKeys.count);
    
    for (int z = 0; z < AppSubIndexKeys.count; z++)
    {
        NSMutableArray *values = [[NSMutableArray alloc] init];
        NSString *keyString = AppSubIndexKeys[z];
        for (int i = 0; i < count; i++)
        {
            NSDictionary *readings = _readings[i];
            NSNumber *valueY = [readings[@"readings"] objectForKey:keyString];
            [values addObject:[[ChartDataEntry alloc] initWithX:i y:valueY.floatValue]];
        }
        
        LineChartDataSet *d = [[LineChartDataSet alloc] initWithValues:values label:keyString];
        d.lineWidth = 2.5;
        d.circleRadius = 4.0;
        d.circleHoleRadius = 2.0;
        
        UIColor *color = AppColorRegions[z];
        [d setColor:color];
        [d setCircleColor:color];
        [dataSets addObject:d];
    }
    
    LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:7.f]];
    _chartView.data = data;
}

@end
