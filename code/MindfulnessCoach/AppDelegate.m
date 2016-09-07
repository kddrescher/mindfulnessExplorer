//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "Action.h"
#import "ActionMenuViewController.h"
#import "AppConstants.h"
#import "Client.h"
#import "ContentLoader.h"
#import "ExercisesViewController.h"
//#import "Flurry.h"
#import "HomeViewController.h"
#import "LegalViewController.h"
//#import "TestFlight.h"
#import "WebViewController.h"

@implementation AppDelegate

#pragma mark - Lifecycle

/**
 *  application:didFinishLaunchingWithOptions
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // [TestFlight takeOff:kTestFlightAppToken];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitingFromLegal) name:@"kExitingFromLegal" object:NULL];
    ContentLoader *contentLoader = [[ContentLoader alloc] initWithClient:self.client];
    if ([self.client.contentVersion isEqualToString:contentLoader.contentVersion]) {
        [self initializeApplicationState];
    } else {
        [self clearUserDataAndResetApplicationState];
    }

    [contentLoader release];
    
    return YES;
}

/**
 *  applicationWillResignActive
 */
- (void)applicationWillResignActive:(UIApplication *)application {
    [self saveClientState];
}

/**
 *  dealloc
 */
- (void)dealloc {
    [_client release];
    [_tabBarController release];
    [_window release];
    
    [super dealloc];
}

#pragma mark - Property Accessors

/**
 *  client
 */
- (Client *)client {
    if (_client == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedClient = [defaults objectForKey:@"client"];
        if (encodedClient != nil) {
            _client = [(Client *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedClient] retain];
        } else {
            _client = [[Client alloc] init];
        }
    }
    
    return _client;
}

#pragma mark - Instance Methods

/**
 *  initializeApplicationState
 */
- (void)initializeApplicationState {

    
    // Show legal screen if required.
    if (self.client.hasViewedLegalScreens == NO) {
        LegalViewController *legalViewController = [[LegalViewController alloc] initWithClient:self.client filename:kContentHTMLURLLegalEULA];
        UINavigationController *legalNavigationController = [[UINavigationController alloc] initWithRootViewController:legalViewController];
        legalNavigationController.navigationBar.tintColor = [AppConstants navigationBarTintColor];
        
        UIWindow *mainWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window = mainWindow;
        self.window.rootViewController = legalNavigationController;
        [self.window makeKeyAndVisible];
        
//        [homeNavigationController presentViewController:legalNavigationController animated:NO completion:nil];
        [legalNavigationController release];
        [legalViewController release];
    }
    else [self exitingFromLegal];
    
    /*
     // Enable Analytics
     if (self.client.isAuthorizedToRecordUsageData) {
     [Flurry startSession:kFlurryAnalyticsAPIKey];
     }
     */
}

/**
 *  saveClientState
 */
- (void)saveClientState {
    NSData *encodedClient = [NSKeyedArchiver archivedDataWithRootObject:self.client];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:encodedClient forKey:@"client"];
    [userDefaults synchronize];
}

/**
 *  clearUserDataAndResetApplicationState
 */
- (void)clearUserDataAndResetApplicationState {
    NSLog(@"Clearing user data and resetting application state...");
    
    // Delete the client's datastore
    [self.client deletePersistentStore];
    
    // Delete the client's saved state.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"client"];
    [userDefaults synchronize];
    
    self.client = nil;
    
    // Reload the content
    ContentLoader *loader = [[ContentLoader alloc] initWithClient:self.client];
    [loader loadContent];
    [self saveClientState];
    self.client.contentVersion = loader.contentVersion;
    [loader release];
    
    // Rebuild the UI state
    [self initializeApplicationState];
}

/**
 *  navigationControllerWithRootController:title:tabBarImageName
 */
- (UINavigationController *)navigationControllerWithRootController:(UIViewController *)rootController {
    UIViewController <ViewControllerCompositeProtocol> *compositeViewController = (UIViewController <ViewControllerCompositeProtocol> *)rootController;
    Action *action = compositeViewController.action;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootController];
    navigationController.tabBarItem.title = NSLocalizedString(action.title, nil);
    navigationController.tabBarItem.image = [UIImage imageNamed:action.icon];
    navigationController.navigationBar.tintColor = [AppConstants navigationBarTintColor];
    
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Home", nil)
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:rootController
                                                                      action:@selector(handleHomeButtonTapped:)];
    rootController.navigationItem.leftBarButtonItem = homeButtonItem;
    [homeButtonItem release];
    
    return [navigationController autorelease];
}

- (void) exitingFromLegal {
    NSMutableArray *navigationViewControllers = [[NSMutableArray alloc] init];
    
    // Learn
    ActionMenuViewController *learnMenuViewController = [[ActionMenuViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                                                 client:self.client];
    learnMenuViewController.action = [self.client rootActionForGroup:kActionGroupLearn];
    [navigationViewControllers addObject:[self navigationControllerWithRootController:learnMenuViewController]];
    [learnMenuViewController release];
    
    // Practice
    ExercisesViewController *practiceViewController = [[ExercisesViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                                              client:self.client];
    practiceViewController.action = [self.client rootActionForGroup:kActionGroupPractice];
    [navigationViewControllers addObject:[self navigationControllerWithRootController:practiceViewController]];
    [practiceViewController release];
    
    // Track
    ActionMenuViewController *trackMenuViewController = [[ActionMenuViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                                                 client:self.client];
    trackMenuViewController.action = [self.client rootActionForGroup:kActionGroupTrack];
    [navigationViewControllers addObject:[self navigationControllerWithRootController:trackMenuViewController]];
    [trackMenuViewController release];
    
    // Reminders
    ActionMenuViewController *remindersViewController = [[ActionMenuViewController alloc] initWithStyle:UITableViewStyleGrouped client:self.client];
    remindersViewController.action = [self.client rootActionForGroup:kActionGroupRemind];
    [navigationViewControllers addObject:[self navigationControllerWithRootController:remindersViewController]];
    [remindersViewController release];
    
    // Tab Bar Controller
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = navigationViewControllers;
    
    self.tabBarController = tabBarController;
    [tabBarController release];
    [navigationViewControllers release];
    
    // Setup Main Window
    UIWindow *mainWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window = mainWindow;
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    [mainWindow release];
    
    // Home
    HomeViewController *homeViewController = [[HomeViewController alloc] initWithClient:self.client];
    homeViewController.action = [self.client rootActionForGroup:kActionGroupHome];
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    homeNavigationController.navigationBar.tintColor = [AppConstants navigationBarTintColor];
    
    [self.window.rootViewController presentViewController:homeNavigationController animated:NO completion:nil];
    
    [homeViewController release];
    [homeNavigationController release];
}

@end
