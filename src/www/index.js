import exec from 'cordova/exec';

export const AUTHORIZATION_STATUS_AUTHORIZED = 0;
export const AUTHORIZATION_STATUS_DENIED = 1;
export const AUTHORIZATION_STATUS_NOT_DETERMINED = 2;
export const AUTHORIZATION_STATUS_RESTRICTED = 3;
export const AUTHORIZATION_STATUS_UNKNOWN = -1;

export const TASK_HINT_CONFIRMATION = 3;
export const TASK_HINT_DICTATION = 1;
export const TASK_HINT_SEARCH = 2;
export const TASK_HINT_UNSPECIFIED = 0;

export const authorizationStatus = (success, failure) => (
  exec(success, failure, 'SpeechRecognitionIos', 'authorizationStatus', [])
);

export const isAvailable = (success, failure) => (
  exec(success, failure, 'SpeechRecognitionIos', 'isAvailable', [])
);

export const requestAuthorization = (success, failure) => (
  exec(success, failure, 'SpeechRecognitionIos', 'requestAuthorization', [])
);

const startSuccess = success => ({ transcriptions, ...rest }) => success({
  bestTranscription: transcriptions[0],
  transcriptions,
  ...rest,
});

export const start = (id, options, success, failure) => (
  exec(startSuccess(success), failure, 'SpeechRecognitionIos', 'start', [id, options || {}])
);

export const stop = (id, success, failure) => (
  exec(success, failure, 'SpeechRecognitionIos', 'stop', [id])
);

export const supportedLocales = (success, failure) => (
  exec(success, failure, 'SpeechRecognitionIos', 'supportedLocales', [])
);
