//
//  CitiesTableViewController.m
//  cidades
//
//  Created by SBTUR Principal on 8/31/15.
//  Copyright (c) 2015 Ariane. All rights reserved.
//

#import "CitiesTableViewController.h"
#import "DetailViewController.h"
#import "RequestJSon.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <UIImageView+AFNetworking.h>
#import <Foursquare-API-v2/Foursquare2.h>

@interface CitiesTableViewController ()
@property (strong, nonatomic) NSArray * data;
@property (strong, nonatomic) RequestJSon * requestJS;
@property (strong, nonatomic) GMSMapView * mapView;
@property (strong, nonatomic) UIButton * fbLoginButton;
@property (strong, nonatomic) CLLocationManager * locationManager;
@property (strong, nonatomic) GMSMarker * marker;
@property (strong, nonatomic) CLLocation * currentLocation;

@property (nonatomic)SEL getData;

@end

@implementation CitiesTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Cidades";
    [self facebookLogin];
   
    
    self.requestJS = [[RequestJSon alloc]init];
    [self.requestJS setData:@selector(getData:) onViewControler:self withURL:@"http://alfa.nativoo.com/cities/api/cities/?lang=pt"];
    
    [self addMaps];
    
}

-(void)setFoursquareFor: (NSString *) queryLiked
{
    [ Foursquare2 venueSearchNearByLatitude:@(self.currentLocation.coordinate.latitude) longitude:@(self.currentLocation.coordinate.longitude) query:queryLiked limit:nil intent:intentBrowse radius:@(10000) categoryId:nil callback:^(BOOL success, id result) {
        if(success)
        {
            if(result[@"response"])
               {
                   [self showPlacesOnFoursquare:result[@"response"][@"venues"]];
               }
            
           
        }
    }];
    
}


-(void)showPlacesOnFoursquare:(NSArray *) places
{
    GMSCameraPosition * cameraPositionOfLikes = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude zoom:13];
    [self.mapView animateToCameraPosition:cameraPositionOfLikes];
    
    
    GMSMarker * likeMarker = [[GMSMarker alloc] init];
    
    double lat = [places[0][@"location"][@"lat"] doubleValue] ;
    double lon = [places[0][@"location"][@"lng"] doubleValue];
    likeMarker.position = CLLocationCoordinate2DMake(lat, lon) ;
    likeMarker.title =  places[0][@"name"];
    likeMarker.snippet = places[0][@"location"][@"address"];
    likeMarker.icon = [UIImage imageNamed:@"likePin"];
    likeMarker.map = self.mapView;

}


-(void)facebookLogin
{
    self.fbLoginButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.fbLoginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.fbLoginButton.frame = CGRectMake(0, 0, self.view.frame.size.width/5, 20);
    [self.fbLoginButton setTitle:@"LogIn" forState:UIControlStateNormal];
    [self.fbLoginButton addTarget:self action:@selector(fbLoginAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem * rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView: self.fbLoginButton];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;

}

-(void)fbLoginAction
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends", @"user_likes"]
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             [self.fbLoginButton setTitle:@"logOut" forState:UIControlStateNormal];
             
             if ([FBSDKAccessToken currentAccessToken]) {
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                      if (!error) {
                            self.title = ((NSDictionary*)result)[@"name"];
                          
                          [self getLikes];
                      }
                  }];
             }
             
             
         }
     }];
}


-(void)getLikes
{
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/likes" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                [self findUserLikes: result[@"data"]];
             }
         }];
    }
}


-(void)findUserLikes: (NSArray *)data
{
    NSLog(@" likes on fb: %@", data);
    
    if(self.currentLocation)
    {
        for ( NSDictionary * likedItem in data)
        {
            [self setFoursquareFor:likedItem[@"name"]];
        }
    }
}


-(void)addMaps
{
    GMSCameraPosition * cameraPosition = [GMSCameraPosition cameraWithLatitude:37.59 longitude:-48.54 zoom:1];
    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height/ 3) camera:cameraPosition];
    self.tableView.tableHeaderView = self.mapView;
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.currentLocation  = (CLLocation *) [locations lastObject];
     GMSCameraPosition * cameraPosition = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude zoom:10];
    
    
    [self.mapView animateToCameraPosition:cameraPosition];
    
    
    
    //making markers
    self.marker= [[GMSMarker alloc] init];
    self.marker.position = self.currentLocation.coordinate ;
    self.marker.title =   self.mapView.myLocation.accessibilityLabel;
    self.marker.snippet = self.mapView.myLocation.accessibilityHint;
    self.marker.map = self.mapView;
    
    
    
    [self.locationManager stopUpdatingLocation];
    
    
}


-(void)getData: (NSDictionary *) data
{
    self.data = data[@"results"];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.data count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * identifier = @"cities";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
   
    NSString * imageURL = [NSString stringWithFormat:@"http://nativoostatic.s3.amazonaws.com/media/mobile/cityphotos/%@/thumbnails/256_256/photo_%@.jpeg", self.data[indexPath.row][@"id"], self.data[indexPath.row][@"image"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageURL]];
    
    cell.textLabel.text = self.data[indexPath.row][@"name"];
    cell.detailTextLabel.text= self.data[indexPath.row][@"country"][@"name"];
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.marker.position = CLLocationCoordinate2DMake([self.data[indexPath.row][@"latitude"] doubleValue],[self.data[indexPath.row][@"longitude"] doubleValue]);
     [ self.mapView animateToLocation: self.marker.position];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"Show City Details"])
    {
        DetailViewController * dc = [segue destinationViewController];
        UITableViewCell * tbSender = (UITableViewCell *)sender;
        dc.cityID = [self.data[[self.tableView indexPathForCell:tbSender].row][@"id"] stringValue] ;
     
        
    }
                     
}
                     
                     
@end
