//
//  RequestJSon.m
//  cidades
//
//  Created by SBTUR Principal on 8/31/15.
//  Copyright (c) 2015 Ariane. All rights reserved.
//

#import "RequestJSon.h"
#import <AFNetworking/AFNetworking.h>
#import "RequestJSon.h"


@implementation RequestJSon



- (instancetype)init
{
    self = [super init];
    if (self) {
      

    }
    return self;
}

-(void)setData:(SEL)setData onViewControler:(UIViewController *)vc withURL:(NSString *) url
{
    //call the data into another queue
    //creating a new queue
    dispatch_queue_t loadJson = dispatch_queue_create("loadJson", NULL);
    
    
    dispatch_async(loadJson, ^{ //code
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if(setData != nil)
                 {
                     [vc performSelector:setData withObject:responseObject[@"data"]];
                     
                 }
             });
             
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
         }];
        
    });
    
}




@end
