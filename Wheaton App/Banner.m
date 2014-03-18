//
//  Banner.m
//  Wheaton App
//
//  Created by Chris Anderson on 2/20/14.
//
//

#import "Banner.h"
#import "Course.h"
#import "CourseRequirement.h"

@implementation Banner

+ (void)setUser:(NSDictionary *)user success:(void (^)(NSDictionary *skips))success failure:(void (^)(NSError *err))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *url = [NSString stringWithFormat:@"%@/set", c_Banner];
    
    [manager POST:url parameters:user success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = responseObject;
        if ([dic objectForKey:@"success"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"login"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            success(dic);
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"login"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            failure([NSError errorWithDomain:@"Incorrect email or password" code:0 userInfo:nil]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

+ (void)getChapelSkips:(void (^)(NSDictionary *skips))success failure:(void (^)(NSError *err))failure
{
    if([Banner hasLoggedIn]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *url = [NSString stringWithFormat:@"%@/chapel", c_Banner];
        
        [manager POST:url parameters:[Banner getUser] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dic = responseObject;
            success(dic);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    }
}

+ (void)getDegree:(void (^)(NSArray *degree))success failure:(void (^)(NSError *err))failure
{
    if([Banner hasLoggedIn]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *url = [NSString stringWithFormat:@"%@/degree", c_Banner];
        
        [manager POST:url parameters:[Banner getUser] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *dic = responseObject;
            
            NSMutableArray *requirements = [[NSMutableArray alloc] init];
            
            for (NSDictionary *requirement in dic) {
                CourseRequirement *cr = [[CourseRequirement alloc] init];
                cr.met = [requirement objectForKey:@"sectionMet"];
                cr.type = [requirement objectForKey:@"sectionType"];
                
                NSMutableArray *courses = [[NSMutableArray alloc] init];
                
                for (NSDictionary *course in [requirement objectForKey:@"classes"]) {
                    Course *c = [[Course alloc] init];
                    [c jsonParse:course];
                    [courses addObject:c];
                }
                cr.courses = courses;
                [requirements addObject:cr];
            }
            
            success(requirements);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    }
}

+ (BOOL)hasLoggedIn
{
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types
        && [[NSUserDefaults standardUserDefaults] boolForKey:@"login"]
        && [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"]
        && [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]
        ) {
        return YES;
    }
    return NO;
}

+ (NSDictionary *)getUser
{
    return @{
             @"uuid": [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"],
             @"token": [[NSUserDefaults standardUserDefaults] objectForKey:@"token"]
             };
}

@end