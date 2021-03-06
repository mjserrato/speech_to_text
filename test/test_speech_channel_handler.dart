import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Holds a set of responses and acts as a mock for the platform specific
/// implementations allowing test cases to determine what the result of
/// a call should be.
class TestSpeechChannelHandler {
  final SpeechToText _speech;
  TestSpeechChannelHandler(this._speech);

  bool initResult = true;
  bool initInvoked = false;
  bool listenInvoked = false;
  bool cancelInvoked = false;
  bool stopInvoked = false;
  bool localesInvoked = false;
  bool hasPermissionResult = true;
  String listeningStatusResponse = SpeechToText.listeningStatus;
  String listenLocale;
  List<String> locales = [];
  static const String localeId1 = "en_US";
  static const String localeId2 = "fr_CA";
  static const String name1 = "English US";
  static const String name2 = "French Canada";
  static const String locale1 = "$localeId1:$name1";
  static const String locale2 = "$localeId2:$name2";
  static const String firstRecognizedWords = 'hello';
  static const String secondRecognizedWords = 'hello there';
  static const double firstConfidence = 0.85;
  static const double secondConfidence = 0.62;
  static const String firstRecognizedJson =
      '{"alternates":[{"recognizedWords":"$firstRecognizedWords","confidence":$firstConfidence}],"finalResult":false}';
  static const String secondRecognizedJson =
      '{"alternates":[{"recognizedWords":"$secondRecognizedWords","confidence":$secondConfidence}],"finalResult":false}';
  static const String finalRecognizedJson =
      '{"alternates":[{"recognizedWords":"$secondRecognizedWords","confidence":$secondConfidence}],"finalResult":true}';
  static const SpeechRecognitionWords firstWords =
      SpeechRecognitionWords(firstRecognizedWords, firstConfidence);
  static const SpeechRecognitionWords secondWords =
      SpeechRecognitionWords(secondRecognizedWords, secondConfidence);
  final SpeechRecognitionResult firstRecognizedResult =
      SpeechRecognitionResult([firstWords], false);
  final SpeechRecognitionResult secondRecognizedResult =
      SpeechRecognitionResult([secondWords], false);
  final SpeechRecognitionResult finalRecognizedResult =
      SpeechRecognitionResult([secondWords], true);
  static const String transientErrorJson =
      '{"errorMsg":"network","permanent":false}';
  static const String permanentErrorJson =
      '{"errorMsg":"network","permanent":true}';
  static const double level1 = 0.5;
  static const double level2 = 10;

  Future<dynamic> methodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case "has_permission":
        return hasPermissionResult;
        break;
      case "initialize":
        initInvoked = true;
        return initResult;
        break;
      case "cancel":
        cancelInvoked = true;
        return true;
        break;
      case "stop":
        stopInvoked = true;
        return true;
        break;
      case SpeechToText.listenMethod:
        listenInvoked = true;
        listenLocale = methodCall.arguments["localeId"];
        await _speech.processMethodCall(MethodCall(
            SpeechToText.notifyStatusMethod, listeningStatusResponse));
        return initResult;
        break;
      case "locales":
        localesInvoked = true;
        return locales;
        break;
      default:
    }
    return initResult;
  }

  void notifyFinalWords() {
    _speech.processMethodCall(
        MethodCall(SpeechToText.textRecognitionMethod, finalRecognizedJson));
  }

  void notifyPartialWords() {
    _speech.processMethodCall(
        MethodCall(SpeechToText.textRecognitionMethod, firstRecognizedJson));
  }

  void notifyPermanentError() {
    _speech.processMethodCall(
        MethodCall(SpeechToText.notifyErrorMethod, permanentErrorJson));
  }

  void notifyTransientError() {
    _speech.processMethodCall(
        MethodCall(SpeechToText.notifyErrorMethod, transientErrorJson));
  }
}
