//
//  RNMediaPlayer.m
//  RNMediaPlayer
//
//  Created by Chris Elly on 2015.07.12
//

#import "RNMediaPlayer.h"
#import <React/RCTUtils.h>
#import <React/RCTLog.h>
#import <React/RCTConvert.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@implementation RNMediaPlayer
{
  AVPlayer *_player;
  AVPlayerViewController *_playerViewcontroller;

  NSString *_uri;
  bool hasListeners;
  NSTimer *timer;
}


RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (void)startObserving
{
  hasListeners = YES;
}

- (void)stopObserving
{
  hasListeners = NO;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"MediaPlayerOnShow", @"MediaPlayerOnDismiss"];
}

RCT_EXPORT_METHOD(open:(NSDictionary *)options)
{
  // this method can receive the following options
  //
  // uri: STRING (full resource name with file extension)
  //
  // missing: option to disable autoplay
    NSLog(@"[RNMediaPlayer] AVPlayerViewController OPEN");

  _uri = [options objectForKey:@"uri"];

  NSString *encodedString = [_uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL *fileURL = [[NSURL alloc] initWithString:encodedString];

  dispatch_async(dispatch_get_main_queue(), ^{

    _playerViewcontroller = [[AVPlayerViewController alloc] init];
    _playerViewcontroller.delegate = self;
    _playerViewcontroller.player = [AVPlayer playerWithURL:fileURL];
    [_playerViewcontroller.player play];

    UIViewController *ctrl = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIView *view = [ctrl view];

    view.window.windowLevel = UIWindowLevelStatusBar;

    [ctrl presentViewController:_playerViewcontroller animated:TRUE completion: nil];

    if (hasListeners) {
      [self sendEventWithName:@"MediaPlayerOnShow" body:nil];
    }

    timer = [NSTimer scheduledTimerWithTimeInterval: 0.2
                                             target: self
                                           selector:@selector(onTick:)
                                           userInfo: nil
                                            repeats: YES];

  });
}

-(void)onTick:(NSTimer *)timer {
  if (_playerViewcontroller.player.rate == 0 &&
      (_playerViewcontroller.isBeingDismissed || _playerViewcontroller.nextResponder == nil)) {
    // Handle user Done button click and invalidate timer
    NSLog(@"[RNMediaPlayer] AVPlayerViewController dismissed.");
    if (hasListeners) {
      [self sendEventWithName:@"MediaPlayerOnDismiss" body:nil];
    }
    [timer invalidate];
  }
}

@end
