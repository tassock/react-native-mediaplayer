// /**
//  * @providesModule RNMediaPlayer
//  * @flow
//  */

'use strict';
import {
  NativeModules,
  NativeEventEmitter,
} from 'react-native';

const RNMediaPlayer = NativeModules.RNMediaPlayer;
const eventEmitter = new NativeEventEmitter(NativeRNMediaPlayer);

export default {
  open(options) {
    return NativeRNMediaPlayer.open(options);
  },

  addEventListener(event, listener) {
    if (event === 'onShow') {
      return eventEmitter.addListener('MediaPlayerOnShow', listener);
    } else if (event === 'onDismiss') {
      return eventEmitter.addListener('MediaPlayerOnDismiss', listener);
    } else {
      console.warn(`Trying to subscribe to unknown event: ${event}`);
      return {
        remove: () => {}
      };
    }
  },

  removeEventListener(event, listener) {
    if (event === 'onShow') {
      eventEmitter.removeListener('MediaPlayerOnShow', listener);
    } else if (event === 'onDismiss') {
      eventEmitter.removeListener('MediaPlayerOnDismiss', listener);
    }
  }
};
