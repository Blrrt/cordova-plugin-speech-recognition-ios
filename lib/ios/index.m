#import "index.h"
#import <Cordova/CDV.h>
#import <Speech/Speech.h>

@interface SpeechRecognitionIos()

@property (nonatomic, strong) NSMutableDictionary *audioEngineRefs;
@property (nonatomic, strong) NSMutableDictionary *speechRecognizerRefs;
@property (nonatomic, strong) NSMutableDictionary *speechRequestRefs;
@property (nonatomic, strong) NSMutableDictionary *speechTaskRefs;

@end

@implementation SpeechRecognitionIos

- (void)authorizationStatus:(CDVInvokedUrlCommand *)command {
  @try {
    SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
    int statusCode = [self getStatusCode:status];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:statusCode];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
  }
  @catch (NSException *exception) {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
  }
}

- (void)pluginInitialize
{
  self.audioEngineRefs = [[NSMutableDictionary alloc] init];
  self.speechRecognizerRefs = [[NSMutableDictionary alloc] init];
  self.speechRequestRefs = [[NSMutableDictionary alloc] init];
  self.speechTaskRefs = [[NSMutableDictionary alloc] init];
}

- (int)getStatusCode:(SFSpeechRecognizerAuthorizationStatus)status {
  switch (status) {
    case SFSpeechRecognizerAuthorizationStatusAuthorized:
      return 0;
    case SFSpeechRecognizerAuthorizationStatusDenied:
      return 1;
    case SFSpeechRecognizerAuthorizationStatusNotDetermined:
      return 2;
    case SFSpeechRecognizerAuthorizationStatusRestricted:
      return 3;
    default:
      return -1;
  }
}

- (void)isAvailable:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *result = nil;

  if ([SFSpeechRecognizer class]) {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
  } else {
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
  }

  [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)requestAuthorization:(CDVInvokedUrlCommand *)command {
  @try {
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
      dispatch_async(dispatch_get_main_queue(), ^{
        int statusCode = [self getStatusCode:status];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:statusCode];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
      });
    }];
  }
  @catch (NSException *exception) {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
  }
}

- (void)start:(CDVInvokedUrlCommand *)command {
  @try {
    NSString *id = [command.arguments objectAtIndex:0];
    NSMutableDictionary *options = [command.arguments objectAtIndex:1];
    NSMutableDictionary *optionsInit = [options objectForKey:@"init"];
    NSMutableDictionary *optionsRecognitionRequest = [options objectForKey:@"speechRecognitionRequest"];
    NSString *localeId = [optionsInit objectForKey:@"locale"];
    AVAudioEngine *audioEngine;
    AVAudioFormat *audioFormat;
    AVAudioInputNode *audioInputNode;
    AVAudioSession *audioSession;
    SFSpeechRecognizer *speechRecognizer;
    SFSpeechAudioBufferRecognitionRequest *speechRequest;
    SFSpeechRecognitionTask *speechTask;

    if (localeId == nil) {
      speechRecognizer = [[SFSpeechRecognizer alloc] init];
    } else {
      NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeId];
      speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:locale];
    }

    [self.speechRecognizerRefs setObject:speechRecognizer forKey:id];

    audioEngine = [[AVAudioEngine alloc] init];
    [self.audioEngineRefs setObject:audioEngine forKey:id];

    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];

    speechRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    speechRequest.contextualStrings = [optionsRecognitionRequest objectForKey:@"contextualStrings"];
    speechRequest.interactionIdentifier = [optionsRecognitionRequest objectForKey:@"interactionIdentifier"];
    speechRequest.shouldReportPartialResults = [[optionsRecognitionRequest objectForKey:@"shouldReportPartialResults"] boolValue];
    speechRequest.taskHint = (SFSpeechRecognitionTaskHint) [optionsRecognitionRequest objectForKey:@"taskHint"];
    [self.speechRequestRefs setObject:speechRequest forKey:id];

    audioInputNode = audioEngine.inputNode;
    audioFormat = [audioInputNode outputFormatForBus:0];

    speechTask = [speechRecognizer recognitionTaskWithRequest:speechRequest resultHandler:^(SFSpeechRecognitionResult *speechResult, NSError *error) {
      if (error) {
        [audioEngine stop];
        [audioInputNode removeTapOnBus:0];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
        return [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
      }

      NSMutableArray *serializedTranscriptions = [[NSMutableArray alloc] init];

      for (SFTranscription *transcription in speechResult.transcriptions) {
        NSDictionary *serializedTranscription;
        NSMutableArray *serializedSegments = [[NSMutableArray alloc] init];

        for (SFTranscriptionSegment *segment in transcription.segments) {
          NSDictionary *serializedSegment = @{
            @"alternativeSubstrings": segment.alternativeSubstrings,
            @"confidence": @(segment.confidence),
            @"duration": @(segment.duration),
            @"substring": segment.substring,
            @"timestamp": @(segment.timestamp)
          };

          [serializedSegments addObject:serializedSegment];
        }

        serializedTranscription = @{
          @"formattedString": transcription.formattedString,
          @"segments": serializedSegments
        };

        [serializedTranscriptions addObject:serializedTranscription];
      }

      NSDictionary *resultValue = @{
        @"isFinal": @(speechResult.isFinal),
        @"transcriptions": serializedTranscriptions
      };

      CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultValue];
      [result setKeepCallbackAsBool:YES];
      [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];

    [self.speechTaskRefs setObject:speechTask forKey:id];

    [audioInputNode installTapOnBus:0 bufferSize:1024 format:audioFormat block:^(AVAudioPCMBuffer *buffer, AVAudioTime *time) {
      [speechRequest appendAudioPCMBuffer:buffer];
    }];

    [audioEngine prepare];
    [audioEngine startAndReturnError:nil];
  }
  @catch (NSException *exception) {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
  }
}

- (void)stop:(CDVInvokedUrlCommand *)command {
  @try {
    NSString *id = [command.arguments objectAtIndex:0];
    AVAudioEngine *audioEngine = [self.audioEngineRefs objectForKey:id];
    SFSpeechRecognizer *speechRecognizer = [self.speechRecognizerRefs objectForKey:id];
    SFSpeechAudioBufferRecognitionRequest *speechRequest = [self.speechRequestRefs objectForKey:id];
    SFSpeechRecognitionTask *speechTask = [self.speechTaskRefs objectForKey:id];

    if (audioEngine.isRunning) {
      [audioEngine stop];
      [speechRequest endAudio];
    }

    [self.audioEngineRefs removeObjectForKey:id];
    [self.speechRecognizerRefs removeObjectForKey:id];
    [self.speechRequestRefs removeObjectForKey:id];
    [self.speechTaskRefs removeObjectForKey:id];

    audioEngine = nil;
    speechRecognizer = nil;
    speechRequest = nil;
    speechTask = nil;

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
  }
  @catch (NSException *exception) {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
  }
}

- (void)supportedLocales:(CDVInvokedUrlCommand *)command {
  @try {
    NSSet<NSLocale *> *supportedLocales = [SFSpeechRecognizer supportedLocales];
    NSMutableArray *supportedLocaleIdList = [[NSMutableArray alloc] init];

    for (NSLocale *locale in supportedLocales) {
      [supportedLocaleIdList addObject:[locale localeIdentifier]];
    }

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:supportedLocaleIdList];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
  }
  @catch (NSException *exception) {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
  }
}

@end
