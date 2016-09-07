//
//  PracticeViewController.h
//

#import "BaseTableViewController.h"

typedef enum {
  kPracticeViewContentPhotos = 0,
  kPracticeViewContentSongs,
  kPracticeViewContentEnvironment
} PracticeViewContent;

typedef enum {
  kPracticeViewStateStopped = 0,
  kPracticeViewStateRunning,
  kPracticeViewStatePaused,
  kPracticeViewStateCompleted
} PracticeViewState;

@interface PracticeViewController : BaseTableViewController

// Properties
@property(nonatomic, retain) UIButton *startButton;
@property(nonatomic, retain) UIButton *stopButton;
@property(nonatomic, retain) UIButton *pauseButton;
@property(nonatomic, retain) UIButton *skipButton;
@property(nonatomic, retain) UIButton *activityButton;
@property(nonatomic, retain) UIButton *restartButton;
@property(nonatomic, retain) UILabel *songTitleLabel;
@property(nonatomic, retain) UIImageView *photoImageView;
@property(nonatomic, retain) UILabel *countdownLabel;
@property(nonatomic, retain) UISwitch *audioAlertSwitch;
@property(nonatomic, retain) NSDate *timerFiredDate;
@property(nonatomic, retain) NSTimer *timer;
@property(nonatomic, assign) NSTimeInterval timerDuration;
@property(nonatomic, assign) NSTimeInterval runTime;

@property(nonatomic, retain) NSFetchedResultsController *fetchedContentItemsController;
@property(nonatomic, retain) NSManagedObject *fetchedContentObject;

@property(nonatomic, assign, readonly) PracticeViewContent viewContent;
@property(nonatomic, assign) PracticeViewState viewState;

// Initializers
- (id)initWithStyle:(UITableViewStyle)style client:(Client *)client viewContent:(PracticeViewContent)viewContent;

// Message Handlers
- (void)handleStartButtonTapped:(id)sender;
- (void)handleRestartButtonTapped:(id)sender;
- (void)handleStopButtonTapped:(id)sender;
- (void)handlePauseButtonTapped:(id)sender;
- (void)handleSkipButtonTapped:(id)sender;
- (void)handleActivityButtonTapped:(id)sender;
- (void)handleTimerDidFire:(NSTimer *)timer;

// Instance Methods
- (void)updateCountdownLabel;
- (void)updatePhotoImageView;
- (void)updateSongTitleLabel;
- (void)clearTimer;
- (BOOL)shouldShowSkipButton;

@end
