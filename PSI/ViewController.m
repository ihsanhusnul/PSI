//
//  ViewController.m
//  PSI
//
//  Created by ihsan husnul on 7/27/17.
//  Copyright © 2017 ihsan.husnul@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "DetailViewController.h"

@interface ViewController () <MKMapViewDelegate> {
    __weak IBOutlet MKMapView *myMapView;
    __weak IBOutlet UIDatePicker *datePicker;
    __weak IBOutlet UIActivityIndicatorView *hudIndicator;
    
    NSDictionary *jsonData;
}

#define PSIGovDataUrl @"https://api.data.gov.sg/v1/environment/psi"

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    datePicker.date = [NSDate date];
    
    [self requestPSI];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToDetail"]) {
        DetailViewController *vc = segue.destinationViewController;
        vc.region = sender[@"region"];
        vc.readings = sender[@"readings"];
        vc.api_info = jsonData[@"api_info"];
    }
}

- (IBAction)didTapRefreshBtn:(id)sender {
    [self requestPSI];
}

- (void)requestPSI {
    [hudIndicator startAnimating];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:datePicker.date];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?date=%@", PSIGovDataUrl, dateString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"uWMhqwnJJvul39UWGOGh9VS6arST3bFK" forHTTPHeaderField:@"api-key"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hudIndicator stopAnimating];
        });
        
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        }
        else {
            jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [self setMapView];
        }
    }];
    [task resume];
}

- (void)setMapView {
    NSMutableArray *mutable = [NSMutableArray new];
    
    for (NSDictionary *dict in jsonData[@"region_metadata"]) {
        NSDictionary *loc = dict[@"label_location"];
        float latitude = [loc[@"latitude"] floatValue];
        float longitude = [loc[@"longitude"] floatValue];
        if (loc && latitude > 0. && longitude > 0) {
            MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
            ann.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            ann.title = [dict[@"name"] capitalizedString];
            ann.subtitle = @"tap for detail";
            [mutable addObject:ann];
        }
    }
    
    [myMapView showAnnotations:mutable animated:YES];
}

#pragma mark - MapView Delegate
- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"didSelect: %@", view);
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(nonnull MKAnnotationView *)view calloutAccessoryControlTapped:(nonnull UIControl *)control {
    NSString *region = view.annotation.title.lowercaseString;
    
    NSMutableArray *dataArray = [NSMutableArray new];
    for (NSDictionary *item in jsonData[@"items"]) {
        
        NSDictionary *readings = item[@"readings"];
        NSMutableDictionary *mutable = [NSMutableDictionary new];
        for (NSString *key in [readings allKeys]) {
            [mutable setObject:readings[key][region] forKey:key];
        }
        
        [dataArray addObject:@{@"update_timestamp": item[@"update_timestamp"], @"timestamp": item[@"timestamp"], @"readings": mutable}];
    }
    
    [self performSegueWithIdentifier:@"segueToDetail" sender:@{@"region": region, @"readings": dataArray}];
}

@end
