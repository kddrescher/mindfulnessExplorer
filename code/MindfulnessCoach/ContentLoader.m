//
//  ContentLoader.m
//

#import "ContentLoader.h"
#import "Action.h"
#import "Client.h"
#import "Exercise.h"
#import "AppConstants.h"

@implementation ContentLoader

#pragma mark - Lifecycle

/**
 *  initWithClient
 */
- (id)initWithClient:(Client *)client {
  self = [self init];
  if (self != nil) {
    _client = [client retain];
    _tbxml = [[TBXML tbxmlWithXMLFile:kApplicationContentPath] retain];
  }
  
  return self;
}

/**
 *  dealloc
 */
- (void)dealloc {
  [_tbxml release];
  [_client release];
  
  [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  contentVersion
 */
- (NSString *)contentVersion {
  NSString *version = nil;
  
  if (self.tbxml.rootXMLElement != nil) {
    version = [TBXML valueOfAttributeNamed:@"version" forElement:self.tbxml.rootXMLElement];
  }
  
  return version;
}

#pragma mark - Instance Methods

/**
 *  loadContent
 */
- (void)loadContent {
  if (self.tbxml.rootXMLElement != nil) {
    // Load Actions
    [self loadContentFromElement:[TBXML childElementNamed:@"actions" parentElement:self.tbxml.rootXMLElement]
                       childName:@"action"
                    parentObject:nil
                       loadBlock:^(TBXMLElement *element) { return [self actionFromXMLElement:element]; }];
    
    // Load Exercises
    [self loadContentFromElement:[TBXML childElementNamed:@"exercises" parentElement:self.tbxml.rootXMLElement] 
                       childName:@"exercise"
                    parentObject:nil
                       loadBlock:^(TBXMLElement *element) { return [self exerciseFromXMLElement:element]; }];
  }
  
  self.client.contentVersion = self.contentVersion;
}

/**
 *  actionFromXMLElement
 */
- (Action *)actionFromXMLElement:(TBXMLElement *)element {
  NSString *actionType = [TBXML valueOfAttributeNamed:@"type" forElement:element];
  
  // This is a rather long-winded way of populating actionValues, but we can't use the convenience
  // constructors on NSMutableDictionary because some of these attributes might return nil and 
  // would thus be interpretted as a terminating nil.
  NSMutableDictionary *actionValues = [[NSMutableDictionary alloc] initWithCapacity:3];
  [actionValues setValue:actionType forKey:@"type"];
  [actionValues setValue:[TBXML valueOfAttributeNamed:@"accessory" forElement:element] forKey:@"accessoryType"];
  [actionValues setValue:[TBXML valueOfAttributeNamed:@"details" forElement:element] forKey:@"details"];
  [actionValues setValue:[TBXML valueOfAttributeNamed:@"filename" forElement:element] forKey:@"filename"];
  [actionValues setValue:[TBXML valueOfAttributeNamed:@"group" forElement:element] forKey:@"group"];
  [actionValues setValue:[TBXML valueOfAttributeNamed:@"help" forElement:element] forKey:@"helpFilename"];
  [actionValues setValue:[TBXML valueOfAttributeNamed:@"icon" forElement:element] forKey:@"icon"];
  [actionValues setValue:[TBXML valueOfAttributeNamed:@"navigationTitle" forElement:element] forKey:@"navigationTitle"];
  [actionValues setValue:[TBXML valueOfAttributeNamed:@"style" forElement:element] forKey:@"style"];
  [actionValues setValue:[TBXML valueOfAttributeNamed:@"uid" forElement:element] forKey:@"uid"];
  [actionValues setValue:[TBXML valueOfAttributeNamed:@"userInfo" forElement:element] forKey:@"userInfo"];
  
  // Small hack to allow for editors to just use "\n" in the XML file for line breaks.
  NSString *title = [TBXML valueOfAttributeNamed:@"title" forElement:element];
  NSString *magicNewLineString = @"\n";
  NSString *magicTitle = [title stringByReplacingOccurrencesOfString:@"\\n" withString:magicNewLineString];
  [actionValues setValue:magicTitle forKey:@"title"];
  
  TBXMLElement *instructions = [TBXML childElementNamed:@"instructions" parentElement:element];
  if (instructions != nil) {
    [actionValues setValue:[TBXML textForElement:instructions] forKey:@"instructions"];
  }
  
  NSString *section = [TBXML valueOfAttributeNamed:@"section" forElement:element];
  if (section == nil) {
    section = @"DEADBEEF";
  }
  
  [actionValues setValue:section forKey:@"section"];
  
  Action *action = [self.client insertNewActionWithValues:actionValues];
  [actionValues release];
  
  return action;
}

/**
 *  exerciseFromXMLElement
 */
- (Exercise *)exerciseFromXMLElement:(TBXMLElement *)element {
  NSMutableDictionary *exerciseValues = [[NSMutableDictionary alloc] initWithCapacity:1];
  [exerciseValues setValue:[TBXML valueOfAttributeNamed:@"title" forElement:element] forKey:@"title"];
  [exerciseValues setValue:[TBXML valueOfAttributeNamed:@"filename" forElement:element] forKey:@"filename"];
  
  Exercise *exercise = [self.client insertNewExerciseWithValues:exerciseValues];
  [exerciseValues release];
  
  return exercise;
}

/**
 *  loadContentFromElement:parentName:childName:recurse:loadBlock
 */
- (void)loadContentFromElement:(TBXMLElement *)rootElement 
                     childName:(NSString *)childName
                  parentObject:(NSManagedObject *)parentObject
                     loadBlock:(LoadElementsBlock)block {
  if (rootElement == nil) {
    return;
  }
  
  TBXMLElement *childElement = [TBXML childElementNamed:childName parentElement:rootElement];
  NSUInteger rank = 1;
  
  while (childElement != nil) {
    NSManagedObject *managedObject = block(childElement);
    NSEntityDescription *entityDescription = [managedObject entity];
    NSArray *attributeKeys = [[entityDescription attributesByName] allKeys];
    NSArray *relationshipKeys = [[entityDescription relationshipsByName] allKeys];
    
    if ([attributeKeys containsObject:@"rank"]) {
      [managedObject setValue:[NSNumber numberWithUnsignedInt:rank] forKey:@"rank"];
    }
    
    if ([relationshipKeys containsObject:@"parent"]) {
      [managedObject setValue:parentObject forKey:@"parent"];
    }
    
    // Recursively load any children.
    [self loadContentFromElement:childElement 
                       childName:childName 
                    parentObject:managedObject 
                       loadBlock:block];
    
    rank += 1;
    childElement = [TBXML nextSiblingNamed:childName searchFromElement:childElement];
  }
}

@end
