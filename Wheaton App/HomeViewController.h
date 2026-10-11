//
//  HomeViewController.h
//  Wheaton App
//
//  Created by Chris Anderson on 11/11/13.
//
//
//  NOTICE: Modified by an LLM (Claude Code), 2026-10-11: Who's Who now searches
//  a bundled directory (whoswho.json) instead of the campus intranet.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSInteger priorSegmentIndex;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *switchViewControllers;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, copy) NSArray *allViewControllers;
@property (nonatomic,retain) IBOutlet UIView *viewContainer;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *resultsTable;

- (void)performSearch:(NSString *)searchString;

@end
