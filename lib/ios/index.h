#import <Cordova/CDV.h>
#import <Speech/Speech.h>

@interface SpeechRecognitionIos : CDVPlugin

- (void)authorizationStatus:(CDVInvokedUrlCommand *)command;
- (AVAudioSessionDataSourceDescription *)getAudioSessionDataSourceFrom:(NSArray<AVAudioSessionDataSourceDescription *> *)sources withOrientation:(NSString *)orientation;
- (AVAudioSessionPortDescription *)getAudioSessionInputBuiltinFrom:(NSArray *)inputs;
- (NSString *const)getAudioSessionOrientationByString:(NSString *)orientation;
- (int)getStatusCode:(SFSpeechRecognizerAuthorizationStatus)status;
- (void)isAvailable:(CDVInvokedUrlCommand *)command;
- (void)requestAuthorization:(CDVInvokedUrlCommand *)command;
- (void)start:(CDVInvokedUrlCommand *)command;
- (void)stop:(CDVInvokedUrlCommand *)command;
- (void)supportedLocales:(CDVInvokedUrlCommand *)command;

@end
