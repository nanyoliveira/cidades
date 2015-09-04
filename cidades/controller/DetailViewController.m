//
//  DetailViewController.m
//  cidades
//
//  Created by SBTUR Principal on 8/31/15.
//  Copyright (c) 2015 Ariane. All rights reserved.
//

#import "DetailViewController.h"
#import "RequestJSon.h"
#import  <Foundation/Foundation.h>

@interface DetailViewController ()
@property (strong, nonatomic)RequestJSon * requestJS;
@property (strong, nonatomic) NSDictionary * cityData;

@property (weak, nonatomic) IBOutlet UIImageView *cityPhoto;
@property (weak, nonatomic) IBOutlet UILabel *cityCountry;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;
@end

@implementation DetailViewController

-(void) setCityID:(NSString *)cityID
{
    if(!_cityID )
    {
        _cityID = cityID;
    }
    NSLog(@"id :: %@", self.cityID);
    self.requestJS = [[RequestJSon alloc]init];
    NSString * url = [NSString stringWithFormat: @"http://alfa.nativoo.com/cities/api/cities/%@/?lang=pt", self.cityID ];
    [self.requestJS setData:@selector(getCityData:) onViewControler:self withURL:url];
}


- (void)viewDidLoad {
    [super viewDidLoad];
  
    
  
}


-(void) getCityData:(NSDictionary *)data;
{
    self.cityData = data;
    
    [self fillData];
}


-(void)fillData
{
    self.title = self.cityData[@"name"];
    self.descriptionText.text = [NSString stringWithFormat:@"\n%@", self.cityData[@"description"]];
    self.cityCountry.text =  self.cityData[@"country"][@"name"];
    NSString * photoImageId = [self.cityData[@"image"] stringValue]  ;
    NSString * firstPhotoURL = [NSString stringWithFormat:@"http://nativoostatic.s3.amazonaws.com/media/mobile/cityphotos/%@/thumbnails/256_256/photo_%@.jpeg", self.cityID, photoImageId];
    
    
    
   
    [self downloadImage:firstPhotoURL ];
}


-(void)downloadImage: (NSString *) photoURL
{
    NSURLRequest * urlRequest = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:photoURL]];
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDownloadTask * downloadTask = [session downloadTaskWithRequest:urlRequest completionHandler:^(NSURL* localfile, NSURLResponse *response, NSError *error) {
        if(!error)
        {
            NSData * imageData = [NSData dataWithContentsOfURL:localfile];
            UIImage * image = [UIImage imageWithData: imageData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.cityPhoto.image = image;
                
                //set bg
                UIImageView * bg = [[UIImageView alloc]initWithFrame:self.view.frame];
                bg.image = image;
                bg.contentMode = UIViewContentModeScaleAspectFill;
                bg.alpha = 0.1;
                [self.view addSubview:bg];
                
                
                
                
            });
        }
    }];
    [downloadTask resume];
    

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

@end
