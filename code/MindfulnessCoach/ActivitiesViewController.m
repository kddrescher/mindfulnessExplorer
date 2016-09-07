//
//  ActivitiesViewController.m
//
#import "ActivitiesViewController.h"
#import "Activity.h"
#import "ActivityEditViewController.h"
#import "Client.h"
#import "Exercise.h"
#import "AppConstants.h"
#import "NSString+VPDString.h"
#import "UIFactory.h"
#import "UIView+VPDView.h"

@implementation ActivitiesViewController

#pragma mark - Lifecycle

/**
 *  initWithStyle:client
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client {
  self = [super initWithStyle:UITableViewStylePlain client:client];
  if (self != nil) {
    self.navigationItem.title = NSLocalizedString(@"Activities", nil);
  }
  
  return self;
}

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  
  // In this case, we really do want a white background.
  self.tableView.backgroundColor = [UIColor whiteColor];
  self.tableView.backgroundView = nil;
}

#pragma mark - Property Accessors

/**
 *  fetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController {
  if ([super fetchedResultsController] == nil) {
    [super setFetchedResultsController:[self.client fetchedResultsControllerForActivitiesSortedByDuration:self.sortBySecondary]];
    [[super fetchedResultsController] setDelegate:self];
  }
  
  return [super fetchedResultsController];
}

#pragma mark - UITableViewDataSource Methods

/**
 *  tableView:editingStyleForRowAtIndexPath
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

/**
 *  tableView:commitEditingStyle:forRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    NSManagedObject *objectToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.client deleteObject:objectToDelete];
  }
}

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *sActivityCellIdentifier = @"ActivityCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sActivityCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sActivityCellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
    UIFont *labelFont = [AppConstants textFont];
    UIColor *labelColor = [UIColor colorWithRed:0.827 green:0.843 blue:0.859 alpha:1.000];
    UIColor *labelTextColor = [UIColor colorWithWhite:0.4 alpha:1.0];
  
    CGFloat labelWidth = 80.0;
    CGFloat labelHeight = labelFont.lineHeight + kUIViewVerticalMargin;
    
    CGRect labelFrame = CGRectMake(0, 0, labelWidth, labelHeight);
    
    // Date label
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:labelFrame];
    dateLabel.backgroundColor = labelColor;
    dateLabel.font = labelFont;
    dateLabel.tag = kViewTagTableViewCellLabelDate;
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.textColor = labelTextColor;
    
    [cell.contentView addSubview:dateLabel];
  
    // Audio icon view
    UILabel *audioLabel = [[UILabel alloc] initWithFrame:labelFrame];
    audioLabel.backgroundColor = dateLabel.backgroundColor;
    audioLabel.font = dateLabel.font;
    audioLabel.tag = kViewTagTableViewCellLabelAudio;
    audioLabel.textAlignment = dateLabel.textAlignment;
    audioLabel.textColor = labelTextColor;
    
    [cell.contentView addSubview:audioLabel];
    [audioLabel moveToRightInParent];

    // Duration label
    labelFrame.size.width = cell.contentView.frame.size.width - (labelWidth * 2) - 2;
    
    UILabel *durationLabel = [[UILabel alloc] initWithFrame:labelFrame];
    durationLabel.backgroundColor = dateLabel.backgroundColor;
    durationLabel.font = dateLabel.font;
    durationLabel.tag = kViewTagTableViewCellLabelDuration;
    durationLabel.textAlignment = dateLabel.textAlignment;
    durationLabel.textColor = labelTextColor;
    
    [cell.contentView addSubview:durationLabel];
    [durationLabel positionToTheRightOfView:dateLabel margin:1.0];
  
    // Title label
    CGRect titleFrame = CGRectMake(kUIViewHorizontalMargin, 0.0, 
                                   cell.contentView.frame.size.width - (kUIViewHorizontalMargin * 2), 
                                   [AppConstants tableCellTitleFont].lineHeight);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.font = [AppConstants tableCellTitleFont];
    titleLabel.tag = kViewTagTableViewCellLabelTitle;
    titleLabel.textColor = [AppConstants primaryTextColor];
    
    [cell.contentView addSubview:titleLabel];
    [titleLabel positionBelowView:dateLabel margin:kUIViewVerticalMargin];
  
    // Comments label
    titleFrame.size.height = dateLabel.font.lineHeight;
    UILabel *commentsLabel = [[UILabel alloc] initWithFrame:titleFrame];
    commentsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    commentsLabel.font = dateLabel.font;
    commentsLabel.numberOfLines = 0;
    commentsLabel.tag = kViewTagTableViewCellLabelComments;
    commentsLabel.textColor = dateLabel.textColor;
    
    [cell.contentView addSubview:commentsLabel];
    [commentsLabel positionBelowView:titleLabel margin:0.0];
    
    [commentsLabel release];
    [titleLabel release];
    [durationLabel release];
    [audioLabel release];
    [dateLabel release];
  
  }
  
  [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

#pragma mark - UITableViewDelegate Methods

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Activity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  // Height for date/duration/audio labels
  CGFloat height = [AppConstants textFont].lineHeight + kUIViewVerticalMargin;
  
  // Height for title and inset
  height += [AppConstants tableCellTitleFont].lineHeight + kUIViewVerticalMargin;
  
  // Height for comments label and whitespace footer.
  NSString *comments = activity.comments;
  CGSize constraintSize = CGSizeMake(tableView.frame.size.width - (kUIViewHorizontalMargin * 2), CGFLOAT_MAX);
  CGRect boundingRect = [comments boundingRectWithSize:constraintSize
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:@{NSFontAttributeName:[AppConstants textFont]}
                                               context:nil];
  
  height += boundingRect.size.height + kUIViewVerticalMargin;
  
  // There's a minimum height so that the disclosure indicator and 'Delete' button don't bump in to the audio label.
  return MAX(height, 100.0);
}

/**
 *  tableView:didSelectRowAtIndexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Activity *selectedActivity = [self.fetchedResultsController objectAtIndexPath:indexPath];
  ActivityEditViewController *editViewController = [[ActivityEditViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                                              client:self.client 
                                                                                            activity:selectedActivity];
  editViewController.popViewControllerInsteadOfDismissing = YES;
  [self.navigationController pushViewController:editViewController animated:YES];
  [editViewController release];
}

#pragma mark - Message Handlers

/**
 *  handleCreateLogEntryButtonTapped
 */
- (void)handleCreateLogEntryButtonTapped:(id)sender {
  ActivityEditViewController *editViewController = [[ActivityEditViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                                              client:self.client
                                                                                            activity:nil];
  
  [self presentModalNavigationControllerWithViewController:editViewController dismissTitle:NSLocalizedString(@"Cancel", nil)];
  [editViewController release];
}

#pragma mark - Instance Methods

/**
 *  configureCell
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  Activity *activity = [self.fetchedResultsController objectAtIndexPath:indexPath];

  self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
  self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
  
  // Date
  UILabel *label = (UILabel *)[cell viewWithTag:kViewTagTableViewCellLabelDate];
  label.text = [self.dateFormatter stringFromDate:activity.date];
  
  // Duration
  label = (UILabel *)[cell viewWithTag:kViewTagTableViewCellLabelDuration];
  label.text = [NSString stringWithTimeInterval:[activity.duration doubleValue]];
                
  // Audio
  BOOL hasAudio = [activity.audio boolValue];
  UILabel *audioLabel = (UILabel *)[cell viewWithTag:kViewTagTableViewCellLabelAudio];
  audioLabel.text = (hasAudio ? NSLocalizedString(@"Audio", nil) : NSLocalizedString(@"Self", nil));
  
  // Title
  label = (UILabel *)[cell viewWithTag:kViewTagTableViewCellLabelTitle];
  label.text = activity.exercise.title;
  
  // Comments
  NSString *comments = activity.comments;
  label = (UILabel *)[cell viewWithTag:kViewTagTableViewCellLabelComments];
  label.text = comments;
  
  CGRect commentsFrame = label.frame;
  CGSize constraintSize = CGSizeMake(commentsFrame.size.width, CGFLOAT_MAX);
  CGRect boundingRect = [comments boundingRectWithSize:constraintSize
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:@{NSFontAttributeName:label.font}
                                               context:nil];
  commentsFrame.size.height = boundingRect.size.height;
  label.frame = commentsFrame;
}

/**
 *  rebuildTableHeaderAndFooterViews
 */
- (void)rebuildTableHeaderAndFooterViews {
  self.tableView.tableHeaderView = nil;
  self.tableView.tableFooterView = nil;
  
  NSString *headerText = nil;
  NSString *footerButtonText = nil;
  
  if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
    // Hide the 'Help' button
    self.navigationItem.rightBarButtonItem = nil;
    
    // This text is taken from "helpTrack.html".
    headerText = NSLocalizedString(@"The mindfulness log can help you track when and how often you are "
                                   "practicing mindfulness tools. It is also a place to keep notes on "
                                   "what you notice when you practice. Using the log may help you remember "
                                   "to practice, and it will show you if you are keeping up on your "
                                   "commitment to mindfulness in your daily life.", nil);
    footerButtonText = NSLocalizedString(@"Create Mindfulness Log", nil);
    
    UIView *footerView = [UIFactory tableFooterViewWithButton:footerButtonText];
    UIButton *footerButton = (UIButton *)[footerView viewWithTag:kViewTagTableViewFooterButton];
    [footerButton addTarget:self action:@selector(handleCreateLogEntryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableFooterView = footerView;
  } else {
    headerText = NSLocalizedString(@"Track your Mindfulness Exercises. Tap '+' to enter a new log.", nil);
  }
  
  UIView *headerView = [UIFactory tableHeaderViewWithText:headerText
                                                imageName:nil
                                                    width:(self.tableView.frame.size.width - (kUIViewHorizontalMargin * 2))
                                                   styled:NO];
  self.tableView.tableHeaderView = headerView;
}

@end
