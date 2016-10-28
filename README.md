# cordova-plugin-speech-recognition-ios

Cordova plugin exposing the iOS Speech Recognition API

## Installation

    cordova plugin add @blrrt/cordova-plugin-speech-recognition-ios

## Usage

    const speechRecognitionRequest = { shouldReportPartialResults: true };
    const id = '...';
    const options = { speechRecognitionRequest };

    cordova.plugins.SpeechRecognitionIos.requestAuthorization(status => {
      if (status === cordova.plugins.SpeechRecognitionIos.AUTHORIZATION_STATUS_AUTHORIZED) {
        cordova.plugins.SpeechRecognitionIos.start(id, options, result => {
          // ...
        });

        // capture speech for 5 seconds
        setTimeout(() => (
          cordova.plugins.SpeechRecognitionIos.stop(id), 5000
        ));
      }
    });
