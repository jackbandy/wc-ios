//
//  HomePastViewController.m
//  Wheaton App
//
//  Created by Chris Anderson on 12/14/13.
//
//

#import "HomePastViewController.h"
#import "SportTableCell.h"
#import "EventTableCell.h"
#import "MetraTableViewCell.h"
#import "Sport.h"

@interface HomePastViewController ()

@property (strong, nonatomic) NSDictionary *chapelSkips;

@end

@implementation HomePastViewController

@synthesize home, scrollView;


- (void)viewDidLoad
{
    
    home = [[NSMutableArray alloc] init];
    
    NSMutableArray *chapelSection = [[NSMutableArray alloc] init];
    [home addObject:chapelSection];
    
    NSMutableArray *sportSection = [[NSMutableArray alloc] init];
    [home addObject:sportSection];
    
    //NSMutableArray *metraSection = [[NSMutableArray alloc] init];
    //[home addObject:metraSection];
    
    
    [super viewWillAppear:YES];
    UIScreen *scrn = [UIScreen mainScreen];
    CGFloat myWidth = scrn.bounds.size.width;
    scrollView =[[BannerScrollView alloc] initWithFrame:CGRectMake(0, 0, myWidth, myWidth/2)];
    [self.tableView addSubview:scrollView];
    [self.tableView setTableHeaderView:scrollView];
    [scrollView loaded:self];
    
    [scrollView setDelegate:self];
    [scrollView setScrollEnabled:YES];
    [self.tableView setShowsVerticalScrollIndicator:false];
    [scrollView setAutoresizingMask:UIViewAutoresizingNone];
    
    [self load];
    [super viewDidLoad];
    

    
}



-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView setShowsVerticalScrollIndicator:false];
   
}


- (void)load
{
        NSLog(@"loaded home data");
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: c_Home]];
            [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
        });
}


- (void)fetchedData:(NSData *)responseData
{
    if (responseData == nil) {
        return;
    }
    
    // parse out the json data
    NSError *error;
    NSDictionary *responseObject  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    [self parseResults:(responseObject)];
}


- (void) parseResults:(NSDictionary *)dic{
    [[home objectAtIndex:0] removeAllObjects];
    [[home objectAtIndex:1] removeAllObjects];
    //[[home objectAtIndex:2] removeAllObjects];
    
    
    NSArray *chapelArray = [dic objectForKey:@"chapel"];
    if ([chapelArray count] > 0) {
        [[home objectAtIndex:0] addObject:[chapelArray objectAtIndex:0]];
    }
    
    NSArray *sportArray = [dic objectForKey:@"sports"];
    NSMutableArray *hasTeam = [[NSMutableArray alloc] init];
    for (NSDictionary *s in sportArray) {
        Sport *sport = [[Sport alloc] init];
        [sport jsonToSport:s];
        [[home objectAtIndex:1] addObject:sport];

        /*
         //only adds the game if there are no other games for that team
        if (![hasTeam containsObject:sport.team]) {
            [hasTeam addObject:sport.team];
            [[home objectAtIndex:1] addObject:sport];
        }
         */
    }
    
    /*
    NSArray *metraArray = [dic objectForKey:@"train"];
    for (NSDictionary *m in metraArray) {
        [[home objectAtIndex:2] addObject:m];
    }
    */
    
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
    return [home count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[home objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Chapel";
    } else if(section == 1) {
        return @"Sports";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        NSString *cellIdentifier = @"EventCell";
        NSString *cellFileName = @"EventSubtitleLineView";
        
        NSDictionary *row = [[home objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        if ([[row objectForKey:@"description"] isEqualToString:@""]) {
            cellIdentifier = @"EventSingleCell";
            cellFileName = @"EventSingleLineView";
        }
        
        EventTableCell *eventCell = (EventTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (eventCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellFileName owner:nil options:nil];
            eventCell = [nib objectAtIndex:0];
        }
        
        eventCell.titleLabel.text = [row objectForKey:@"title"];
        eventCell.subtitleLabel.text = [row objectForKey:@"description"];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[[row objectForKey:@"timeStamp"] objectAtIndex:0] doubleValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [dateFormatter setDateFormat:@"dd"];
        
        
        eventCell.dateLabel.text = [dateFormatter stringFromDate:date];
        
        cell = eventCell;
    } else if (indexPath.section == 1) {
        
        Sport *sport = [[home objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        NSString *cellIdentifier = @"SportTableCell";
        
        if ([sport.score count] > 0 && ![[sport.score objectForKey:@"school"] isEqual: @""]) {
            cellIdentifier = @"SportScoreTableCell";
        }
        
        SportTableCell *sportCell = (SportTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (sportCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:nil options:nil];
            sportCell = [nib objectAtIndex:0];
        }
        
        cell = [sport generateCell:sportCell];
    } /*else if (indexPath.section == 2) {
        
        NSString *cellIdentifier = @"MetraCell";
        NSString *cellFileName = @"MetraTableViewCell";
        
        NSDictionary *inbound = [[[home objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"inbound"];
        NSDictionary *outbound = [[[home objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"outbound"];
        
        MetraTableViewCell *eventCell = (MetraTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (eventCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellFileName owner:nil options:nil];
            eventCell = [nib objectAtIndex:0];
        }
        
        eventCell.origin.text = [NSString stringWithFormat:@"to %@", [inbound objectForKey:@"origin"]];
        eventCell.destination.text =  [NSString stringWithFormat: @"to %@", [inbound objectForKey:@"destination"]];
        
        eventCell.departureTimeInbound.text = [inbound objectForKey:@"departure"];
        eventCell.departureTimeOutbound.text = [outbound objectForKey:@"departure"];
        
        cell = eventCell;
    }*/
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end
