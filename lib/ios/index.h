#import <Cordova/CDV.h>
#import <Speech/Speech.h>

@interface SpeechRecognitionIos : CDVPlugin

- (void)authorizationStatus:(CDVInvokedUrlCommand *)command;
- (int)getStatusCode:(SFSpeechRecognizerAuthorizationStatus)status;
- (void)isAvailable:(CDVInvokedUrlCommand *)command;
- (void)requestAuthorization:(CDVInvokedUrlCommand *)command;
- (void)start:(CDVInvokedUrlCommand *)command;
- (void)stop:(CDVInvokedUrlCommand *)command;
- (void)supportedLocales:(CDVInvokedUrlCommand *)command;

@end
