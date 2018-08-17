//
//  RNMediaPlayer.m
//  RNMediaPlayer
//
//  Created by Chris Elly on 2015.07.12
//

#import "RNMediaPlayer.h"
#import "RCTLog.h"
#import "RCTConvert.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@implementation RNMediaPlayer
{
  AVPlayer *_player;
  AVPlayerViewController *_playerViewcontroller;

  NSString *_uri;
  bool hasListeners;
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

  _uri = [options objectForKey:@"uri"];

  NSString* mediaFilePath = [[NSBundle mainBundle] pathForResource:_uri ofType:nil];
  NSAssert(mediaFilePath, @"Media not found: %@", _uri);

  // refactor: implement an option to load network asset instead
  NSURL *fileURL = [NSURL fileURLWithPath:mediaFilePath];

  dispatch_async(dispatch_get_main_queue(), ^{

    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.exitsFullScreenWhenPlaybackEnds = true;
    playerViewController.delegate = self;

    playerViewController.player = [AVPlayer playerWithURL:fileURL];

    // autoplay
    [playerViewController.player play];

    _playerViewcontroller = playerViewController;

    UIViewController *ctrl = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIView *view = [ctrl view];

    view.window.windowLevel = UIWindowLevelStatusBar;

    [ctrl presentViewController:playerViewController animated:TRUE completion: nil];

    if (hasListeners) {
      [self sendEventWithName:@"MediaPlayerOnShow" body:nil];
    }

  });
}

-(void)playerViewControllerDidEndDismissalTransition:(nonnull AVPlayerViewController *)controller
{
    _playerViewcontroller = nil;
    NSLog(@"[RNMediaPlayer] AVPlayerViewController dismissed.");
    if (hasListeners) {
      [self sendEventWithName:@"MediaPlayerOnDismiss" body:nil];
    }
}

@end
