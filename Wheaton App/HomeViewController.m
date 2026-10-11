//
//  HomeViewController.m
//  Wheaton App
//
//  Created by Chris Anderson on 11/11/13.
//
//
//  NOTICE: Modified by an LLM (Claude Code), 2026-10-11. See HomeViewController.h.
//

#import "HomeViewController.h"
#import "WhosWhoDetailViewController.h"
#import "WhoswhoTableCell.h"
#import "HomePastViewController.h"
#import "Person.h"


@interface HomeViewController ()

@end

@implementation HomeViewController {
    NSArray *directory;
}

@synthesize switchViewControllers, allViewControllers, currentViewController, viewContainer, searchResults, searchBar, resultsTable;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.searchBar.placeholder = @"Who's Who";
    self.searchBar.clipsToBounds = YES;
    self.searchBar.delegate = self;
    self.searchBar.searchTextField.textColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    HomePastViewController *pVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PastHome"];
    
    pVC.view.frame = CGRectMake(0,
                                0,
                                CGRectGetWidth(self.viewContainer.bounds),
                                CGRectGetHeight(self.viewContainer.bounds));
    
    [self addChildViewController:pVC];
    [self.viewContainer addSubview:pVC.view];
    
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


- (void)viewWillAppear:(BOOL)animated
{
    [self showWhosWho:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

}


- (void)showWhosWho:(BOOL)show
{
    [self.searchBar setUserInteractionEnabled:show];
    [self.searchBar setPlaceholder:@"Who's Who"];
}


- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}




#pragma mark - Search bar

- (void)setResultsVisible:(BOOL)visible
{
    if (visible && !resultsTable) {
        resultsTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        resultsTable.translatesAutoresizingMaskIntoConstraints = NO;
        resultsTable.dataSource = self;
        resultsTable.delegate = self;
        resultsTable.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [self.view addSubview:resultsTable];
        [NSLayoutConstraint activateConstraints:@[
            [resultsTable.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor],
            [resultsTable.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [resultsTable.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [resultsTable.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        ]];
    }
    resultsTable.hidden = !visible;
    [self.searchBar setShowsCancelButton:visible animated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)bar
{
    [self setResultsVisible:YES];
}

- (void)searchBar:(UISearchBar *)bar textDidChange:(NSString *)searchText
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performSearch:) object:nil];
    [self performSelector:@selector(performSearch:) withObject:searchText afterDelay:0.2];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)bar
{
    [bar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)bar
{
    bar.text = @"";
    [bar resignFirstResponder];
    [searchResults removeAllObjects];
    [resultsTable reloadData];
    [self setResultsVisible:NO];
}

- (NSArray *)directory
{
    if (!directory) {
        NSMutableArray *people = [[NSMutableArray alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"whoswho" ofType:@"json"];
        NSData *data = path ? [NSData dataWithContentsOfFile:path] : nil;
        NSArray *records = data ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] : nil;
        for (NSDictionary *dic in ([records isKindOfClass:[NSArray class]] ? records : @[])) {
            Person *person = [[Person alloc] init];
            person.firstName = dic[@"firstName"] ?: @"";
            person.lastName = dic[@"lastName"] ?: @"";
            person.group = dic[@"group"];
            person.title = dic[@"title"];
            person.sourceUrl = dic[@"sourceUrl"];
            person.photo = dic[@"photo"];
            person.uid = [NSString stringWithFormat:@"%@|%@|%@", person.firstName, person.lastName, person.group];
            [people addObject:person];
        }
        directory = [people sortedArrayUsingComparator:^NSComparisonResult(Person *a, Person *b) {
            return [[a fullName] caseInsensitiveCompare:[b fullName]];
        }];
    }
    return directory;
}

- (void)performSearch:(NSString *)searchString
{
    NSString *query = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    searchResults = [[NSMutableArray alloc] init];
    if (query.length > 0) {
        for (Person *person in [self directory]) {
            NSString *haystack = [NSString stringWithFormat:@"%@ %@ %@", [person fullName], person.title ?: @"", person.group ?: @""];
            if ([haystack rangeOfString:query options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound) {
                [searchResults addObject:person];
            }
        }
    }
    [resultsTable reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"WhoswhoTableCell";
    WhoswhoTableCell *cell = (WhoswhoTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    Person *person = (Person *)[searchResults objectAtIndex:indexPath.row];
    
    cell.firstName.text = [NSString stringWithFormat:@"%@", [person fullName]];
    
    NSString *imagename = person.photo;
    [Utilities loadImageAtURL:imagename intoImageView:cell.profileImage placeholder:[UIImage imageNamed:@"default-image"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == resultsTable) {
        Person *selectedPerson = (Person *)[self.searchResults objectAtIndex:indexPath.row];
        
        WhosWhoDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"WhosWhoDetail"];

        detail.title = selectedPerson.firstName;

        detail.person = selectedPerson;

        [self.navigationController pushViewController:detail animated:YES];
    }
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
