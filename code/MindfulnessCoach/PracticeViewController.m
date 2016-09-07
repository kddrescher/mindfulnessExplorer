//
//  PracticeViewController.m
//

#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "PracticeViewController.h"
#import "Activity.h"
#import "ActivityEditViewController.h"
#import "Client.h"
#import "AppConstants.h"
#import "Photo.h"
#import "Song.h"
#import "UIFactory.h"
#import "UIView+VPDView.h"

@implementation PracticeViewController



#pragma mark - Lifecycle

/**
 *  initWithStyle:client:viewContent
 */
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client viewContent:(PracticeViewContent)viewContent {
  self = [self initWithStyle:style client:client];
  if (self != nil) {
    _viewContent = viewContent;
    _viewState = kPracticeViewStateStopped;
    _timerDuration = 60 * 5; // 5 Minutes for countdown timers.
    _runTime = 0;
    
    _fetchedContentItemsController = nil;
    _fetchedContentObject = nil;
    
    if (viewContent == kPracticeViewContentPhotos) {
      self.fetchedContentItemsController = [self.client fetchedResultsControllerForPhotos];
    } else if (viewContent == kPracticeViewContentSongs) {
      self.fetchedContentItemsController = [self.client fetchedResultsControllerForSongs];
    }
  }
  
  return self;
}

/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Table Header View
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 0.0)];
  headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  
  if (self.viewContent == kPracticeViewContentPhotos) {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, kUIViewVerticalMargin, 150.0, 150.0)];
    imageView.backgroundColor = [UIColor lightGrayColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.isAccessibilityElement = YES;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 5.0;
    imageView.layer.magnificationFilter = kCAFilterNearest;
    imageView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    imageView.layer.shadowRadius = 2.0;
    imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.shadowOpacity = 0.8;
    
    [imageView centerHorizontallyInView:headerView];
    [headerView addSubview:imageView];
    
    self.photoImageView = imageView;
    [imageView release];
  } else if (self.viewContent == kPracticeViewContentSongs) {
    UIFont *font = [AppConstants boldTextFont];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, kUIViewVerticalMargin, 
                                                               self.tableView.frame.size.width - (kUIViewHorizontalMargin * 2), 
                                                               font.lineHeight + (kUIViewVerticalMargin * 2))];
    label.accessibilityLabel = NSLocalizedString(@"Current Song", nil);
    label.backgroundColor = [UIColor whiteColor];
    label.font = font;
    label.layer.borderColor = [UIColor lightGrayColor].CGColor;
    label.layer.borderWidth = 1.0;
    label.layer.cornerRadius = 8.0;
    label.textAlignment = NSTextAlignmentCenter;
    
    [label centerHorizontallyInView:headerView];
    [headerView addSubview:label];
    
    self.songTitleLabel = label;
    [label release];
  } else if (self.viewContent == kPracticeViewContentEnvironment) {
    UILabel *instructionsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    instructionsLabel.backgroundColor = [UIColor clearColor];
    instructionsLabel.font = [AppConstants textFont];
    instructionsLabel.numberOfLines = 0;
    instructionsLabel.textColor = [AppConstants primaryTextColor];
    instructionsLabel.text = NSLocalizedString(@"Pay attention entirely to the sounds of the world around you. "
                                               "Do not label the sounds or think about their meanings. If your "
                                               "mind wanders, return to listening as soon as you realize it.", nil);
    
    CGSize constraintSize = CGSizeMake(320.0 - (kUIViewHorizontalMargin * 2), CGFLOAT_MAX);
    CGRect boundingRect = [instructionsLabel.text boundingRectWithSize:constraintSize
                                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                            attributes:@{NSFontAttributeName:instructionsLabel.font}
                                                               context:nil];
    
    [instructionsLabel resizeTo:boundingRect.size];
    [instructionsLabel moveToPoint:CGPointMake(kUIViewHorizontalMargin, kUIViewVerticalMargin)];
    
    [headerView addSubview:instructionsLabel];
    [instructionsLabel release];
  }
  
  UIFont *countdownFont = [UIFont systemFontOfSize:36.0];
  CGSize countdownSize = [@"00:00" sizeWithAttributes:@{NSFontAttributeName:countdownFont}];
  
  CGRect countdownRect = CGRectMake(0.0, 0.0, countdownSize.width + (kUIViewHorizontalMargin * 4), countdownSize.height + (kUIViewVerticalMargin * 2));
  
  UILabel *countdown = [[UILabel alloc] initWithFrame:countdownRect];
  countdown.accessibilityLabel = NSLocalizedString(@"Countdown Timer", nil);
  countdown.backgroundColor = [UIColor whiteColor];
  countdown.font = countdownFont;
  countdown.layer.borderColor = [UIColor grayColor].CGColor;
  countdown.layer.borderWidth = 5.0;
  countdown.layer.cornerRadius = 16.0;
  countdown.text = @"00:00";
  countdown.textAlignment = NSTextAlignmentCenter;
  
  [countdown centerHorizontallyInView:headerView];
  [countdown positionBelowView:[[headerView subviews] lastObject] margin:kUIViewVerticalMargin];
  [headerView addSubview:countdown];
  
  self.countdownLabel = countdown;
  [countdown release];
  
  // There's no countdown timer for songs. 
  if (self.viewContent == kPracticeViewContentSongs) {
    self.countdownLabel.hidden = YES;
  }
  
  [headerView resizeHeightToContainSubviewsWithMargin:kUIViewVerticalMargin];
  
  self.tableView.tableHeaderView = headerView;
  [headerView release];
  
  // Table Footer view
  UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 0.0)];
  footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

  NSString *skipButtonTitle = NSLocalizedString(@"Change Song", nil);
  if (self.viewContent == kPracticeViewContentPhotos) {
    skipButtonTitle = NSLocalizedString(@"Change Photo", nil);
  }
  
  self.skipButton = [UIFactory buttonWithTitle:skipButtonTitle];
  [self.skipButton addTarget:self action:@selector(handleSkipButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.skipButton resizeTo:CGSizeMake(self.tableView.frame.size.width - (kUIViewHorizontalMargin * 2), self.skipButton.frame.size.height)];
  [self.skipButton centerHorizontallyInView:footerView];
  [footerView addSubview:self.skipButton];

  self.startButton = [UIFactory buttonWithTitle:NSLocalizedString(@"Start", nil)];
  [self.startButton addTarget:self action:@selector(handleStartButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.startButton resizeTo:CGSizeMake(self.tableView.frame.size.width - (kUIViewHorizontalMargin * 2), self.startButton.frame.size.height)];
  [self.startButton centerHorizontallyInView:footerView];
  [self.startButton positionBelowView:self.skipButton margin:kUIViewVerticalMargin];
  [footerView addSubview:self.startButton];

  self.restartButton = [UIFactory buttonWithTitle:NSLocalizedString(@"Restart", nil)];
  [self.restartButton addTarget:self action:@selector(handleRestartButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.restartButton resizeTo:CGSizeMake(self.tableView.frame.size.width - (kUIViewHorizontalMargin * 2), self.restartButton.frame.size.height)];
  [self.restartButton centerHorizontallyInView:footerView];
  [self.restartButton alignTopWithView:self.startButton];
  [footerView addSubview:self.restartButton];
  
  self.stopButton = [UIFactory buttonWithTitle:NSLocalizedString(@"Stop", nil)];
  [self.stopButton addTarget:self action:@selector(handleStopButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.stopButton resizeTo:CGSizeMake((self.tableView.frame.size.width - (kUIViewHorizontalMargin * 3)) / 2, self.stopButton.frame.size.height)];
  [footerView addSubview:self.stopButton];
  [self.stopButton moveToLeftInParentWithMargin:kUIViewHorizontalMargin];
  [self.stopButton alignTopWithView:self.startButton];

  self.pauseButton = [UIFactory buttonWithTitle:NSLocalizedString(@"Pause", nil)];
  [self.pauseButton addTarget:self action:@selector(handlePauseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.pauseButton resizeTo:self.stopButton.frame.size];
  [footerView addSubview:self.pauseButton];
  [self.pauseButton alignTopWithView:self.stopButton];
  [self.pauseButton moveToRightInParentWithMargin:kUIViewHorizontalMargin];

  self.activityButton = [UIFactory buttonWithTitle:NSLocalizedString(@"Add Activity To Log", nil)];
  [self.activityButton addTarget:self action:@selector(handleActivityButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.activityButton resizeTo:self.startButton.frame.size];
  [self.activityButton alignLeftWithView:self.skipButton];
  [self.activityButton alignTopWithView:self.skipButton];
  [footerView addSubview:self.activityButton];

  [footerView resizeHeightToContainSubviewsWithMargin:kUIViewVerticalMargin];
  
  self.tableView.tableFooterView = footerView;
  [footerView release];
  
  [self addObserver:self forKeyPath:@"viewState" options:0 context:nil];
  self.viewState = kPracticeViewStateStopped;
    
  // Massage the accessibility labels
  if (self.viewContent == kPracticeViewContentSongs) {
    self.skipButton.accessibilityLabel = NSLocalizedString(@"Skip to song titled", nil);
  } else {
    self.skipButton.accessibilityLabel = NSLocalizedString(@"Skip to photo.", nil);
  }
  
  // Advance to the first content object.
  [self handleSkipButtonTapped:self.skipButton];
}

/**
 *  dealloc
 */
- (void)dealloc {
  [self removeObserver:self forKeyPath:@"viewState"];

  [_timer invalidate];
  
  [_startButton release];
  [_stopButton release];
  [_skipButton release];
  [_pauseButton release];
  [_activityButton release];
  [_restartButton release];
  [_songTitleLabel release];
  [_timerFiredDate release];
  [_countdownLabel release];
  [_timer release];
  
  [_fetchedContentItemsController release];
  [_fetchedContentObject release];
  
  [_photoImageView release];
  [_audioAlertSwitch release];
  
  [super dealloc];
}

#pragma mark - UITableViewDataSource Methods

/**
 *  tableView:numberOfRowsInSection
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

/**
 *  tableView:cellForRowAtIndexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [UIFactory cellWithDefaultStyleFromTableView:tableView];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.textLabel.text = NSLocalizedString(@"Audio Alert", nil);

  if (self.audioAlertSwitch == nil) {
    UISwitch *audioSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.audioAlertSwitch = audioSwitch;
    [audioSwitch release];
  }

  cell.accessoryView = self.audioAlertSwitch;

  return cell;
}

#pragma mark - Message Handlers

/**
 *  observeValueForKeyPath
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([keyPath isEqualToString:@"viewState"]) {
    switch (self.viewState) {
      case kPracticeViewStateStopped: {
        self.startButton.hidden = NO;
        self.skipButton.hidden = (self.viewContent == kPracticeViewContentPhotos || self.viewContent == kPracticeViewContentSongs) ? ![self shouldShowSkipButton] : YES;
        
        self.restartButton.hidden = YES;
        self.stopButton.hidden = YES;
        self.pauseButton.hidden = YES;
        self.activityButton.hidden = YES;
        
        [self clearTimer];
        [self updateCountdownLabel];
        break;
      }
        
      case kPracticeViewStateRunning: {
        self.startButton.hidden = YES;
        self.skipButton.hidden = YES;
        self.restartButton.hidden = YES;
        
        self.stopButton.hidden = NO;
        self.pauseButton.hidden = NO;
        self.activityButton.hidden = NO;
        
        [self.timer invalidate];
        self.timer = nil;
        
        if (self.viewContent == kPracticeViewContentPhotos || self.viewContent == kPracticeViewContentEnvironment) {
          self.timerFiredDate = [NSDate date];
          self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(handleTimerDidFire:) userInfo:nil repeats:YES];
        }
        
        break;
      }
        
      case kPracticeViewStatePaused: {
        self.startButton.hidden = YES;
        self.skipButton.hidden = YES;
        self.restartButton.hidden = YES;
        
        self.stopButton.hidden = NO;
        self.pauseButton.hidden = NO;
        self.activityButton.hidden = NO;
        
        [self.timer invalidate];
        self.timer = nil;
        self.timerFiredDate = nil;
        break;
      }
        
      case kPracticeViewStateCompleted: {
        self.restartButton.hidden = NO;
        self.activityButton.hidden = NO;
        
        self.startButton.hidden = YES;
        self.skipButton.hidden = YES;
        self.stopButton.hidden = YES;
        self.pauseButton.hidden = YES;
        
        [self clearTimer];
        [self updateCountdownLabel];
        break;
      }
    }
  }
}

/**
 *  handleStartButtonTapped
 */
- (void)handleStartButtonTapped:(id)sender {
    // Show a MoviePlayer if we're in Song mode.
    if (self.viewContent == kPracticeViewContentSongs) {
        Song *currentSong = (Song *)self.fetchedContentObject;
        MPMediaItem *mediaItem = currentSong.mediaItem;
        if (mediaItem != nil) {
            NSURL* url = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
            if(url != nil){
                MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
                [self presentMoviePlayerViewControllerAnimated:playerViewController];
                [playerViewController release];
                
                self.viewState = kPracticeViewStateCompleted;
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Song", nil)
                                                                    message:NSLocalizedString(@"This song is not playable. Either it is not residing on this device or it is DRM protected. Please verify in your music library that the song has been fully downloaded. Select \"Make Songs Available Offline\" to download the song.", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                          otherButtonTitles:nil];
                [alertView show];
                [alertView release];
                self.viewState = kPracticeViewStateStopped;
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Song", nil)
                                                                message:NSLocalizedString(@"This song no longer appears to be in your music library or you have not added any songs to your playlist.", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            self.viewState = kPracticeViewStateStopped;
        }
    } else {
        self.viewState = kPracticeViewStateRunning;
    }
}

/**
 *  handleRestartButtonTapped
 */
- (void)handleRestartButtonTapped:(id)sender {
  self.viewState = kPracticeViewStateStopped;
}

/**
 *  handleStopButtonTapped
 */
- (void)handleStopButtonTapped:(id)sender {
  self.viewState = kPracticeViewStateStopped;
}

/**
 *  handlePauseButtonTapped
 */
- (void)handlePauseButtonTapped:(id)sender {
  if (self.viewState == kPracticeViewStateRunning) {
    self.viewState = kPracticeViewStatePaused;
    [self.pauseButton setTitle:NSLocalizedString(@"Continue",nil) forState:UIControlStateNormal];
  } else {
    self.viewState = kPracticeViewStateRunning;
    [self.pauseButton setTitle:NSLocalizedString(@"Pause",nil) forState:UIControlStateNormal];
  }
}

/**
 *  handleSkipButtonTapped
 */
- (void)handleSkipButtonTapped:(id)sender {
  self.viewState = kPracticeViewStateStopped;
  
  NSArray *contentItems = [self.fetchedContentItemsController fetchedObjects];
  NSUInteger contentIndex = 0;
  
  if ([contentItems count] == 0) {
    self.fetchedContentObject = nil;
  } else {
    if (self.fetchedContentObject == nil) {
      self.fetchedContentObject = [contentItems objectAtIndex:0];
    } else {
      contentIndex = [contentItems indexOfObject:self.fetchedContentObject] + 1;
      if (contentIndex >= [contentItems count]) {
        contentIndex = 0;
      }
      self.fetchedContentObject = [contentItems objectAtIndex:contentIndex];
    }
  }

  NSUInteger nextIndex = contentIndex + 1;
  if (nextIndex >= [contentItems count]) {
    nextIndex = 0;
  }

  if (self.viewContent == kPracticeViewContentPhotos) {
    [self updatePhotoImageView];
    self.skipButton.accessibilityValue = [NSString stringWithFormat:@"%d %@ %d", nextIndex + 1, NSLocalizedString(@"of", nil), [contentItems count]];
  } else if (self.viewContent == kPracticeViewContentSongs) {
    [self updateSongTitleLabel];
    if ([contentItems count] > 1) {
      Song *nextSong = [contentItems objectAtIndex:nextIndex];
      self.skipButton.accessibilityValue = nextSong.title;
    }
  }
}

/**
 *  handleActivityButtonTapped
 */
- (void)handleActivityButtonTapped:(id)sender {
  ActivityEditViewController *editViewController = [[ActivityEditViewController alloc] initWithStyle:UITableViewStyleGrouped client:self.client activity:nil];
  editViewController.activity.duration = [NSNumber numberWithDouble:MAX(60, self.timerDuration - self.runTime)];
  [self presentModalNavigationControllerWithViewController:editViewController dismissTitle:nil];
  [editViewController release];

  self.viewState = kPracticeViewStateStopped;
}

/**
 *  handleTimerDidFire
 */
- (void)handleTimerDidFire:(NSTimer *)timer {
  [self updateCountdownLabel];
}

#pragma mark - Instance Methods

/**
 *  updateCountdownLabel
 */
- (void)updateCountdownLabel {
  NSTimeInterval elapsedTime = (self.timerFiredDate == nil ? 0 : [self.timerFiredDate timeIntervalSinceNow]) * -1; 
  self.runTime += elapsedTime;

  NSTimeInterval timeRemaining = MAX(0, self.timerDuration - self.runTime);

  long minutes = (long)timeRemaining / 60;
  long seconds = (long)timeRemaining % 60;
  self.countdownLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
  self.countdownLabel.accessibilityValue = self.countdownLabel.text;
  
  if (self.viewState == kPracticeViewStateRunning) {
    self.timerFiredDate = [NSDate date];
  }

  if (timeRemaining == 0) {
    self.viewState = kPracticeViewStateCompleted;
    if (self.audioAlertSwitch.on) {
      SystemSoundID chime;  
      AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"practiceChime" ofType:@"wav"]], &chime);  
      AudioServicesPlaySystemSound (chime);  
    }
  }
}

/**
 *  updatePhotoImageView
 */
- (void)updatePhotoImageView {
  Photo *photo = (Photo *)self.fetchedContentObject;
  self.photoImageView.image = (photo == nil ? nil : [UIImage imageWithData:photo.imageData]);
  NSArray *contentItems = [self.fetchedContentItemsController fetchedObjects];
  NSUInteger index = [contentItems indexOfObject:photo];
  self.photoImageView.accessibilityLabel = [NSString stringWithFormat:@"%@ %d %@ %d", NSLocalizedString(@"Image", nil), index + 1, NSLocalizedString(@"of", nil), [contentItems count]];
}

/**
 *  updateSongTitleLabel
 */
- (void)updateSongTitleLabel {
  Song *currentSong = (Song *)self.fetchedContentObject;
  if (currentSong == nil) {
    self.songTitleLabel.text = NSLocalizedString(@"No Songs Selected", nil);
  } else {
    self.songTitleLabel.text = currentSong.title;
  }
  self.songTitleLabel.accessibilityValue = self.songTitleLabel.text;
}

/**
 *  clearTimer
 */
- (void)clearTimer {
  [self.timer invalidate];
  self.timer = nil;
  self.timerFiredDate = nil;
  self.runTime = 0;
}

/**
 *  shouldShowSkipButton
 */
- (BOOL)shouldShowSkipButton {
  return [[self.fetchedContentItemsController fetchedObjects] count] > 1;
}

@end
