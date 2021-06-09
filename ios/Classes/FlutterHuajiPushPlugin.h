#import <Flutter/Flutter.h>

@interface FlutterHuajiPushPlugin : NSObject<FlutterPlugin>

// channel调用iOS API
@property FlutterMethodChannel *channel;

@end
