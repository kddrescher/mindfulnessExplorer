//
//  ContentLoader.h
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@class Action;
@class Client;
@class Exercise;

typedef NSManagedObject *(^LoadElementsBlock)(TBXMLElement *);

@interface ContentLoader : NSObject

// Properties
@property(nonatomic, copy, readonly) NSString *contentVersion;
@property(nonatomic, strong, readonly) TBXML *tbxml;
@property(nonatomic, strong) Client *client;

// Initializers
- (id)initWithClient:(Client *)client;

// Instance Methods
- (void)loadContent;

- (Action *)actionFromXMLElement:(TBXMLElement *)element;
- (Exercise *)exerciseFromXMLElement:(TBXMLElement *)element;

- (void)loadContentFromElement:(TBXMLElement *)rootElement 
                     childName:(NSString *)childName
                  parentObject:(NSManagedObject *)parentObject
                     loadBlock:(LoadElementsBlock)block;

@end
