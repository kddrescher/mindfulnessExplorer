//
//  EmailBuilder.m
//

#import "EmailBuilder.h"
#import "Activity.h"
#import "NSString+VPDString.h"

@implementation EmailBuilder

#pragma mark - Lifecycle

/**
 *  init
 */
- (id)init {
  self = [super init];
  if (self) {
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
  }
  
  return self;
}
/**
 *  initWithActivity
 */
- (id)initWithActivity:(Activity *)activity {
  self = [self init];
  if (self != nil) {
    _activity = [activity retain];
  }
  
  return self;
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_dateFormatter release];
  
  [_activity release];
  
  [_subject release];
  [_body release];
  
  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  subject
 */
- (NSString *)subject {
  if (_subject == nil) {
    _subject = [NSLocalizedString(@"Mindfulness Coach Log Entry", nil) copy];
  }
  
  return _subject;
}

/**
 *  body
 */
- (NSString *)body {
  if (_body == nil) {
    NSMutableArray *bodyParts = [[NSMutableArray alloc] init];
    
    if (self.activity != nil) {
      [bodyParts addObject:[self bodyWithActivity:self.activity]];
    }
        
    _body = [[bodyParts componentsJoinedByString:@"\n\n--------------------------------------------------\n\n"] copy];
    [bodyParts release];
  }
  
  return _body;
}

#pragma mark - Instance Methods

/**
 *  bodyWithActivity
 */
- (NSString *)bodyWithActivity:(Activity *)activity {
  NSMutableArray *bodyParts = [NSMutableArray arrayWithCapacity:6];
  
  // Date
  [bodyParts addObject:[NSString stringWithFormat:@"* %@\n\n%@\n", NSLocalizedString(@"Date:", nil),
                        [self.dateFormatter stringFromDate:activity.date]]];
  
  // Duration
  [bodyParts addObject:[NSString stringWithFormat:@"* %@\n\n%@\n", NSLocalizedString(@"Duration:", nil),
                        [NSString stringWithTimeInterval:[self.activity.duration doubleValue]]]];
  
  // Audio Guided
  NSString *guided = ([activity.audio boolValue] ? NSLocalizedString(@"Audio Guided", nil) :
                                                   NSLocalizedString(@"Self Guided", nil));
  [bodyParts addObject:[NSString stringWithFormat:@"* %@\n\n%@\n", NSLocalizedString(@"Audio:", nil), guided]];
  
  // Comments
  [bodyParts addObject:[NSString stringWithFormat:@"* %@\n\n%@\n", NSLocalizedString(@"Comments:", nil), activity.comments]];

  return [bodyParts componentsJoinedByString:@"\n"];
}

@end
