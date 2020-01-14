#import "AwsomeVideoPlayerPlugin.h"
#if __has_include(<awsome_video_player/awsome_video_player-Swift.h>)
#import <awsome_video_player/awsome_video_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "awsome_video_player-Swift.h"
#endif

@implementation AwsomeVideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwsomeVideoPlayerPlugin registerWithRegistrar:registrar];
}
@end
