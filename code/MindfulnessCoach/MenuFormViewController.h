//
//  MenuFormViewController.h
//

#import "FRCFormViewController.h"

enum {
  kMenuFormTableViewSectionItems = 0,
  kMenuFormTableViewSectionOther
};

@interface MenuFormViewController : FRCFormViewController {
  NSMutableSet *_selectedManagedObjects;
}

// Properties
@property(nonatomic, copy) NSString *titleKey;
@property(nonatomic, copy) NSString *userAdditionPlaceholderText;

@property(nonatomic, assign) BOOL allowMultipleSelections;
@property(nonatomic, assign) BOOL allowEmptySelection;
@property(nonatomic, assign) BOOL allowUserAdditions;

// Instance Methods
- (void)setSelectedManagedObjects:(NSSet *)selectedObjects;

@end
