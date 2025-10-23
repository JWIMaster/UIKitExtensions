#import "iOS6BarFix.h"

void SetStatusBarBlackTranslucent(void) {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

void SetWantsFullScreenLayout(UIViewController *controller, BOOL enabled) {
    if ([controller respondsToSelector:@selector(setWantsFullScreenLayout:)]) {
        [controller setWantsFullScreenLayout:enabled];
    }
}
