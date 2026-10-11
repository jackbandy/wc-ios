//
//  MoreTableViewController.m
//  Wheaton App
//
//  Created by Chris Anderson on 11/11/13.
//
//

#import "MoreTableViewController.h"
#import "WebViewController.h"
#import "Wheaton_App-Swift.h"


@interface MoreTableViewController ()


@end


@implementation MoreTableViewController {
    NSMutableArray *moreTable;
}
@synthesize tor;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    moreTable = [[NSMutableArray alloc] init];
    
    [self generateTable];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    UISwipeGestureRecognizer *rightRecognizer;
    rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    [rightRecognizer setDirection: UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:rightRecognizer];
    
    UISwipeGestureRecognizer *leftRecognizer;
    leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [leftRecognizer setDirection: UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:leftRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self generateTable];
    [super viewWillAppear:animated];
}

- (void)generateTable
{
    [moreTable removeAllObjects];
    
    NSMutableDictionary *optionsDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *optionsArray = [[NSMutableArray alloc] init];
    
    [optionsDictionary setObject:@"Extra" forKey:@"header"];
    
    
    NSMutableDictionary *chapelOption = [[NSMutableDictionary alloc] init];
    WebViewController *cVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
    cVC.allowZoom = YES;
    cVC.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"chapelNEW" ofType:@"pdf"]];
    [chapelOption setValue:@"Chapel Seat Layout" forKey:@"name"];
    [chapelOption setValue:cVC forKey:@"controller"];
    [optionsArray addObject:chapelOption];
    
    
    
    NSMutableDictionary *recordOption = [[NSMutableDictionary alloc] init];
    RecordArticlesViewController *theRecord = [[RecordArticlesViewController alloc] init];
    [recordOption setValue:@"The Record" forKey:@"name"];
    [recordOption setValue:theRecord forKey:@"controller"];
    [optionsArray addObject:recordOption];
    
    
    
    [optionsDictionary setObject:optionsArray forKey:@"array"];
    [moreTable addObject:optionsDictionary];
    
    NSMutableDictionary *endDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *endArray = [[NSMutableArray alloc] init];
    
    [endDictionary setObject:@"" forKey:@"header"];
    
    NSMutableDictionary *reportOption = [[NSMutableDictionary alloc] init];
    WebViewController *rVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
    rVC.url = [NSURL URLWithString:c_Report];
    [reportOption setValue:@"Report a bug" forKey:@"name"];
    [reportOption setValue:rVC forKey:@"controller"];
    [endArray addObject:reportOption];
    
    NSMutableDictionary *aboutOption = [[NSMutableDictionary alloc] init];
    WebViewController *aVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
    aVC.url = [NSURL URLWithString:c_About];
    [aboutOption setValue:@"About" forKey:@"name"];
    [aboutOption setValue:aVC forKey:@"controller"];
    [endArray addObject:aboutOption];
    
    [endDictionary setObject:endArray forKey:@"array"];
    [moreTable addObject:endDictionary];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [moreTable count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[moreTable objectAtIndex:section] objectForKey:@"array"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex
{
    NSDictionary *entry = [moreTable objectAtIndex:sectionIndex];
    
    return [entry objectForKey:@"header"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [[moreTable objectAtIndex:indexPath.section] objectForKey:@"array"];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [[array objectAtIndex:indexPath.row] objectForKey:@"name"];
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [[[moreTable objectAtIndex:indexPath.section]
                          objectForKey:@"array"]
                         objectAtIndex:indexPath.row];
    UIViewController *selected = [dic objectForKey:@"controller"];
    selected.title = [dic objectForKey:@"name"];
    [self.navigationController
     pushViewController:selected
     animated:YES];
}


- (void)handleSwipeRight:(id)swipe
{
    CGFloat yVal = [swipe locationInView:self.view].y - 80.0;
    
    NSLog(@"Right");
    tor = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TorTouch"]];
    tor.frame = CGRectMake(-160.0, yVal, 160.0, 160.0);
    CGPoint leftPos = CGPointMake(-160, yVal);
    CGPoint rightPos = CGPointMake(self.view.frame.size.width+160, yVal);
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    anim.fromValue  = [NSValue valueWithCGPoint:leftPos];
    anim.toValue    = [NSValue valueWithCGPoint:rightPos];
    anim.duration   = 0.4f;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    anim.removedOnCompletion = TRUE;

    [self.view addSubview:tor];
    [tor.layer addAnimation:anim forKey:@"position.x"];
    //[tor removeFromSuperview];
}

- (void)handleSwipeLeft:(id)swipe
{
    CGFloat yVal = [swipe locationInView:self.view].y - 80.0;
    
    NSLog(@"Left");
    tor = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TorTouch"]];
    tor.transform = CGAffineTransformMakeScale(-1, 1); //Flipped
    tor.frame = CGRectMake(self.view.frame.size.width+160, yVal, 160.0, 160.0);
    CGPoint rightPos = CGPointMake(self.view.frame.size.width+160, yVal);
    CGPoint leftPos = CGPointMake(-160.0, yVal);
    
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    anim.fromValue  = [NSValue valueWithCGPoint:rightPos];
    anim.toValue    = [NSValue valueWithCGPoint:leftPos];
    anim.duration   = 0.4f;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    anim.removedOnCompletion = TRUE;
    
    [self.view addSubview:tor];
    [tor.layer addAnimation:anim forKey:@"position.x"];
    //[tor removeFromSuperview];
}

@end
