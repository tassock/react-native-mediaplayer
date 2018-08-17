//
//  RNMediaPlayer.h
//  RNMediaPlayer
//
//  Created by Chris Elly on 2015.07.12
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface RNMediaPlayer : RCTEventEmitter <RCTBridgeModule, AVPlayerViewControllerDelegate>

@end
