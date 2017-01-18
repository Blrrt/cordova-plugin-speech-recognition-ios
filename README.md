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

## options

Initialization options:

* **init.localeId** - The locale for the speech
* **init.orientation** - The microphone to use: `back`, `bottom`, `front`, `top`

Speech Recognition options:

* **speechRecognition.contextualStrings**
* **speechRecognition.interactionIdentifier**
* **speechRecognition.shouldReportPartialResultss**
* **speechRecognition.taskHint**

Refer to [the docs](https://developer.apple.com/reference/speech/sfspeechrecognitionrequest) for more information.
