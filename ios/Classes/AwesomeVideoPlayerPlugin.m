#import "AwesomeVideoPlayerPlugin.h"
#if __has_include(<awesome_video_player/awesome_video_player-Swift.h>)
#import <awesome_video_player/awesome_video_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "awesome_video_player-Swift.h"
#endif

@implementation AwesomeVideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwesomeVideoPlayerPlugin registerWithRegistrar:registrar];
}
@end
