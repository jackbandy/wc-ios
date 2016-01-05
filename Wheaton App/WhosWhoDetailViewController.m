//
//  WhosWhoDetailViewController.m
//  Wheaton App
//
//  Created by Chris Anderson on 1/9/14.
//
//

#import "WhosWhoDetailViewController.h"

@interface WhosWhoDetailViewController ()

@end

@implementation WhosWhoDetailViewController {
    UIImageView *imageHolder;
    UIBarButtonItem *winkButton;
    Mixpanel *mixpanel;
    
    JCRBlurView *blurView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.name.text = [self.person fullNameWithPref];
    self.email.text = self.person.email;
    self.classification.text = self.person.classification;
    self.cpo.text = [NSString stringWithFormat:@"CPO: %@", self.person.cpo];
    
    self.profileImage.contentMode = UIViewContentModeTop;
    
    mixpanel = [Mixpanel sharedInstance];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:NO];
    
    @try {
        if (!blurView) {
            blurView = [JCRBlurView new];
            [blurView setFrame:CGRectMake(0,
                                          self.view.frame.size.height-150,
                                          self.view.frame.size.width,
                                          100)];
            [self.view insertSubview:blurView belowSubview:(UIView *)self.bottomBlur];
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    
    [mixpanel track:@"Whos Who" properties:@{ @"query": self.person.fullName }];
    
    NSString *imagename = self.person.photo;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: imagename]]];
        if (self.view.frame.size.height < 400) {
            self.image = [self.image scaleToWidth:self.view.frame.size.width
                                       constraint:self.view.frame.size.height-50];
        } else {
            self.image = [self.image scaleToWidth:self.view.frame.size.width
                                  constraint:self.view.frame.size.height];
        }
        if (self.image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profileImage.image = self.image;
            });
        }
    });
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized) {
            [self alertMessage:@"Sad face" message:@"No winking right now" button:@"Ok"];
            [mixpanel track:@"Wink Attempted" properties:@{}];
    }
}

- (void)displayWink
{
    if (!winkButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(10, 10, 24, 24)];
        [button setBackgroundImage:[UIImage imageNamed:@"wink_small"] forState:UIControlStateNormal];
        
        winkButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    if ([self inFavorites]) {
        self.navigationItem.rightBarButtonItem = winkButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)animateWink
{
    if (!imageHolder) {
        imageHolder = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-64,
                                                                    self.view.frame.size.height/2-64, 128, 128)];
        UIImage *winkImage = [UIImage imageNamed:@"wink"];
        imageHolder.image = winkImage;
        imageHolder.alpha = 0.0f;
        [self.view addSubview:imageHolder];
    }
    
    if ([self inFavorites]) {
        imageHolder.transform = CGAffineTransformMakeScale(.75,.75);
        [UIView beginAnimations:@"fadeInNewView" context:NULL];
        [UIView setAnimationDuration:.3];
        imageHolder.transform = CGAffineTransformMakeScale(1,1);
        imageHolder.alpha = 1.0f;
        [UIView commitAnimations];
        
        imageHolder.transform = CGAffineTransformMakeScale(1,1);
        [UIView beginAnimations:@"fadeOut" context:NULL];
        [UIView setAnimationDuration:.35];
        imageHolder.transform = CGAffineTransformMakeScale(3,3);
        imageHolder.alpha = 0.0f;
        [UIView commitAnimations];
    }
}

- (void)setFavorite
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[NSMutableArray alloc] initWithArray:[prefs objectForKey:@"favorites"]];
    if (!favorites) {
        favorites = [[NSMutableArray alloc] init];
    }
    
    if ([self inFavorites]) {
        [favorites removeObject:self.person.uid];
    } else {
        if ([favorites count] < 10) {
            [favorites addObject:self.person.uid];
            [mixpanel track:@"Wink" properties:@{ @"student": self.person.fullName }];
        } else {
            [self alertMessage:@"Wink" message:@"There is a limit to the number of winks you can use." button:@"Darn it"];
        }
    }
    
    [prefs setObject:favorites forKey:@"favorites"];
    [prefs synchronize];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"uuid": [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"],
                                 @"token": [[NSUserDefaults standardUserDefaults] objectForKey:@"token"],
                                 @"favorites":favorites
                                 };
    
    [manager POST:c_Favorites parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {}
          failure:^(AFHTTPRequestOperation *operation, NSError *error) { NSLog(@"COULD NOT SAVE"); }];
}

- (BOOL)inFavorites
{
    NSArray *favorites = [[NSUserDefaults standardUserDefaults] objectForKey:@"favorites"];
    if (favorites) {
        for (NSString *uid in favorites) {
            if ([uid isEqualToString:self.person.uid]) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)alertMessage:(NSString *)title message:(NSString *)message button:(NSString *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:button
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
