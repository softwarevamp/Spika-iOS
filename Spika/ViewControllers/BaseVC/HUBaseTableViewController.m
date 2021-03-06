/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Clover Studio Ltd. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "HUBaseTableViewController.h"
#import "HUBaseViewController+Style.h"
#import "HUBaseTableViewController+Style.h"

@interface HUBaseTableViewController () {

    /*
    UIView                      *_loadingView;
    UILabel                     *_loadingLabel;
    UIActivityIndicatorView     *_loadingIndicatorView;
    
    UIView                      *_noItemsView;
    UILabel                     *_noItemsLabel;
     
    */
    
}

@end

@implementation HUBaseTableViewController

@synthesize items = _items;
@synthesize tableView = _tableView;
@synthesize tableViewStyle = _tableViewStyle;

#pragma mark - Memory Management

- (void) dealloc {
    
    [self removeObserver:self
              forKeyPath:@"items"];
    
    [self removeObserver:self
              forKeyPath:@"tableViewStyle"];

    CS_RELEASE(_items);
    CS_RELEASE(_tableView);
    
    /*
    CS_RELEASE(_loadingView);
    CS_RELEASE(_loadingLabel);
    CS_RELEASE(_loadingIndicatorView);
    CS_RELEASE(_noItemsView);
    CS_RELEASE(_noItemsLabel);
    */
    
    CS_SUPER_DEALLOC;
}

#pragma mark - Initialization

- (id) init {

    if (self = [super init]) {
        
        _items = [[NSMutableArray alloc] init];
        
        _tableViewStyle = UITableViewStylePlain;
        
        [self addObserver:self
               forKeyPath:@"items"
                  options:0
                  context:NULL];
        
        [self addObserver:self
               forKeyPath:@"tableViewStyle"
                  options:0
                  context:NULL];
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (void) loadView {

    [super loadView];

    self.view.backgroundColor = [HUBaseViewController sharedViewBackgroundColor];
    
    /*
    _loadingView = CS_RETAIN([self loadingView]);
    
    _loadingLabel = CS_RETAIN([self loadingLabel]);
    _loadingLabel.text = [self loadingTitle];
    [_loadingView addSubview:_loadingLabel];
    _loadingLabel.alpha = 0.0;
    
    _loadingIndicatorView = CS_RETAIN([self loadingIndicatorView]);
    [_loadingView addSubview:_loadingIndicatorView];
    _loadingView.alpha = 0.0;
    [self.view addSubview:_loadingView];
    
    _noItemsView = CS_RETAIN([self noItemsView]);
    
    _noItemsLabel = CS_RETAIN([self noItemsLabel]);
    _noItemsLabel.text = [self noItemsTitle];
    [_noItemsView addSubview:_noItemsLabel];
    _noItemsView.alpha = 0.0;
    
    [self.view addSubview:_noItemsView];
    */
    
    _tableView = CS_RETAIN([self contentTableView]);
    [self.view addSubview:_tableView];
    _tableView.alpha = 0.0;

    [self showViewType:HUViewTypeMain animated:NO];
}

#pragma mark - Override

- (BOOL) isFirstSectionReservedForLoadingView {
    return NO;
}

- (BOOL) isCellSelectionEnabled {
    return YES;
}

- (void) showViewType:(HUViewType)viewType animated:(BOOL)animated {

     __weak HUBaseTableViewController *this = self;
    
    BOOL showMainView = NO;
    BOOL showLoadingView = NO;
    BOOL showNoItemsView = NO;
    
    if (viewType == HUViewTypeMain) {
        
        showMainView = YES;
        
    }
    else if (viewType == HUViewTypeLoading) {
        
        showLoadingView = YES;
        
    }
    else if (viewType == HUViewTypeNoItems) {
        
        showNoItemsView = YES;
        
    }
    
    void (^animations)() = ^(){
    
        self.tableView.alpha = showMainView;
        
    };
    
    void (^completion)(BOOL) = ^(BOOL finished) {
    
        if (showMainView) {
            [self.tableView reloadData];
        }
        
    };
    
    if (!animated) {
        animations();
        completion(YES);
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:animations
                     completion:completion];

}

#pragma mark - Observing

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {

    if ([keyPath isEqualToString:@"items"]) {
        
        [_tableView reloadData];
    }
    else if ([keyPath isEqualToString:@"tableViewStyle"]) {
    
        if (_tableView.style != _tableViewStyle) {
            
            [_tableView removeFromSuperview];
            CS_RELEASE(_tableView);
            
            _tableView = CS_RETAIN([self contentTableView]);
            [self.view addSubview:_tableView];
        }
    }
}

#pragma mark - Setters

- (void) setTableItems:(NSArray *)items {

    _items = [[NSMutableArray alloc] initWithArray:items];
    [_tableView reloadData];
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _items.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 44.0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSObject* tableObject = [_items objectAtIndex:indexPath.row];
    NSAssert([tableObject isKindOfClass:NSClassFromString(@"NSString")], @"Table object is not an NSString. Override this method in your subclass", nil);
    
    NSString *cellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        
        cell = CS_AUTORELEASE([[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier]);
    }
    
    cell.textLabel.text = cellIdentifier;
    
    return cell;

}

- (void)killScroll
{
    CGPoint offset = _tableView.contentOffset;
    offset.x -= 1.0;
    offset.y -= 1.0;
    [_tableView setContentOffset:offset animated:NO];
    offset.x += 1.0;
    offset.y += 1.0;
    [_tableView setContentOffset:offset animated:NO];
}


@end
