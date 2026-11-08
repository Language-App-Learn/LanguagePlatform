import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('tr'),
  ];

  /// Application name. Brand name; keep untranslated.
  ///
  /// In en, this message translates to:
  /// **'LanguagePlatform'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get errorNotFound;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loadingLabel;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @startLesson.
  ///
  /// In en, this message translates to:
  /// **'Start lesson'**
  String get startLesson;

  /// No description provided for @lessonCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No lessons} =1{1 lesson} other{{count} lessons}}'**
  String lessonCount(int count);

  /// No description provided for @answerCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get answerCorrect;

  /// No description provided for @answerIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Not quite.'**
  String get answerIncorrect;

  /// No description provided for @nextLesson.
  ///
  /// In en, this message translates to:
  /// **'Next lesson'**
  String get nextLesson;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordLink;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get noAccountPrompt;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerButton;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account creation will be available once the service is connected.'**
  String get registerSubtitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccountPrompt;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send reset instructions.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetButton.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetButton;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters'**
  String passwordTooShort(int min);

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @authUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is not connected to a server yet. This build cannot create or verify accounts.'**
  String get authUnavailable;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to this content.'**
  String get errorForbidden;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The server had a problem. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This feature is not connected yet.'**
  String get errorUnavailable;

  /// No description provided for @answerTrue.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get answerTrue;

  /// No description provided for @answerFalse.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get answerFalse;

  /// No description provided for @pageNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFoundTitle;

  /// No description provided for @pageNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The page you opened does not exist.'**
  String get pageNotFoundMessage;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get goHome;

  /// No description provided for @brandTagline.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE LEARNING PLATFORM'**
  String get brandTagline;

  /// No description provided for @lessonPosition.
  ///
  /// In en, this message translates to:
  /// **'Lesson {current} of {total}'**
  String lessonPosition(int current, int total);

  /// No description provided for @stageReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get stageReading;

  /// No description provided for @stageSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get stageSpeaking;

  /// No description provided for @stageListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get stageListening;

  /// No description provided for @stageWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get stageWriting;

  /// No description provided for @stageTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get stageTranslation;

  /// No description provided for @stageReadingDesc.
  ///
  /// In en, this message translates to:
  /// **'Read the Arabic text, listen to each line and answer questions.'**
  String get stageReadingDesc;

  /// No description provided for @stageSpeakingDesc.
  ///
  /// In en, this message translates to:
  /// **'Study the dialogue and practice speaking.'**
  String get stageSpeakingDesc;

  /// No description provided for @stageListeningDesc.
  ///
  /// In en, this message translates to:
  /// **'Listen and place the words in the blanks.'**
  String get stageListeningDesc;

  /// No description provided for @stageWritingDesc.
  ///
  /// In en, this message translates to:
  /// **'Fill in missing words and build sentences.'**
  String get stageWritingDesc;

  /// No description provided for @stageTranslationDesc.
  ///
  /// In en, this message translates to:
  /// **'Translate from Turkish into Arabic.'**
  String get stageTranslationDesc;

  /// No description provided for @stageStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get stageStatusAvailable;

  /// No description provided for @stageStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get stageStatusInProgress;

  /// No description provided for @stageStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get stageStatusCompleted;

  /// No description provided for @stageStatusLocked.
  ///
  /// In en, this message translates to:
  /// **'Not yet accessible'**
  String get stageStatusLocked;

  /// No description provided for @stageStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Content not published yet'**
  String get stageStatusUnavailable;

  /// No description provided for @stageRetry.
  ///
  /// In en, this message translates to:
  /// **'Practice again'**
  String get stageRetry;

  /// No description provided for @lessonStatusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get lessonStatusNotStarted;

  /// No description provided for @lessonStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get lessonStatusInProgress;

  /// No description provided for @lessonStatusAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting official assessment'**
  String get lessonStatusAwaiting;

  /// No description provided for @lessonStatusPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get lessonStatusPassed;

  /// No description provided for @lessonStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Not passed, try again'**
  String get lessonStatusFailed;

  /// No description provided for @overallScoreNone.
  ///
  /// In en, this message translates to:
  /// **'No official score yet'**
  String get overallScoreNone;

  /// No description provided for @passMarkInfo.
  ///
  /// In en, this message translates to:
  /// **'Overall pass mark: {mark} out of 100'**
  String passMarkInfo(int mark);

  /// No description provided for @scoringPolicyMissing.
  ///
  /// In en, this message translates to:
  /// **'The stage weights are set by the server and are not available yet, so no final score is shown.'**
  String get scoringPolicyMissing;

  /// No description provided for @wordBank.
  ///
  /// In en, this message translates to:
  /// **'Word bank'**
  String get wordBank;

  /// No description provided for @stageContentMissing.
  ///
  /// In en, this message translates to:
  /// **'This lesson has no published content for this stage yet.'**
  String get stageContentMissing;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect, or the account is not confirmed yet.'**
  String get authInvalidCredentials;

  /// No description provided for @registerAccepted.
  ///
  /// In en, this message translates to:
  /// **'Registration request sent. Check your email to confirm your account.'**
  String get registerAccepted;

  /// No description provided for @resetRequested.
  ///
  /// In en, this message translates to:
  /// **'If this address belongs to an account, reset instructions will be sent.'**
  String get resetRequested;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @remoteSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see and save your progress.'**
  String get remoteSignInPrompt;

  /// No description provided for @remoteBeginLesson.
  ///
  /// In en, this message translates to:
  /// **'Begin this lesson'**
  String get remoteBeginLesson;

  /// No description provided for @stageAttempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts: {count}'**
  String stageAttempts(int count);

  /// No description provided for @stageWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight: {weight}%'**
  String stageWeight(String weight);

  /// No description provided for @remoteStageNoAssessment.
  ///
  /// In en, this message translates to:
  /// **'No graded activity is published for this stage yet.'**
  String get remoteStageNoAssessment;

  /// No description provided for @remoteStageTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Stage text'**
  String get remoteStageTextTitle;

  /// No description provided for @startAssessment.
  ///
  /// In en, this message translates to:
  /// **'Start graded activity'**
  String get startAssessment;

  /// No description provided for @submitAnswers.
  ///
  /// In en, this message translates to:
  /// **'Submit answers'**
  String get submitAnswers;

  /// No description provided for @officialResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Official result'**
  String get officialResultTitle;

  /// No description provided for @officialResultScore.
  ///
  /// In en, this message translates to:
  /// **'{score} of {max}'**
  String officialResultScore(String score, String max);

  /// No description provided for @nextLessonAction.
  ///
  /// In en, this message translates to:
  /// **'Go to the next lesson'**
  String get nextLessonAction;

  /// No description provided for @unsupportedQuestion.
  ///
  /// In en, this message translates to:
  /// **'This question type is not supported in this version of the app.'**
  String get unsupportedQuestion;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'This action isn\'t available right now. The stage may be locked, or the attempt limit may be reached.'**
  String get errorConflict;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The file is too large.'**
  String get errorTooLarge;

  /// No description provided for @errorUnsupportedMedia.
  ///
  /// In en, this message translates to:
  /// **'This file type is not supported.'**
  String get errorUnsupportedMedia;

  /// No description provided for @readingMaterialTitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher-approved Arabic text'**
  String get readingMaterialTitle;

  /// No description provided for @readingMaterialEmpty.
  ///
  /// In en, this message translates to:
  /// **'The reading text has not been published yet.'**
  String get readingMaterialEmpty;

  /// No description provided for @readingPdfDownload.
  ///
  /// In en, this message translates to:
  /// **'Download original PDF'**
  String get readingPdfDownload;

  /// No description provided for @readingPdfDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get readingPdfDownloading;

  /// No description provided for @readingPdfReady.
  ///
  /// In en, this message translates to:
  /// **'PDF downloaded ({size})'**
  String readingPdfReady(String size);

  /// No description provided for @readingPdfHandoffUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This build cannot save or open PDF files yet.'**
  String get readingPdfHandoffUnavailable;

  /// No description provided for @readingLineLabel.
  ///
  /// In en, this message translates to:
  /// **'Line {number}'**
  String readingLineLabel(int number);

  /// No description provided for @mediaVideoAvailable.
  ///
  /// In en, this message translates to:
  /// **'Teacher video: {title}'**
  String mediaVideoAvailable(String title);

  /// No description provided for @mediaNone.
  ///
  /// In en, this message translates to:
  /// **'No audio or video has been published for this stage.'**
  String get mediaNone;

  /// No description provided for @speakingStartAttempt.
  ///
  /// In en, this message translates to:
  /// **'Start speaking attempt'**
  String get speakingStartAttempt;

  /// No description provided for @speakingWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for evaluation'**
  String get speakingWaitingTitle;

  /// No description provided for @speakingWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'An authorized evaluator scores your speaking. Your result appears here once it is recorded.'**
  String get speakingWaitingBody;

  /// No description provided for @speakingCheckResult.
  ///
  /// In en, this message translates to:
  /// **'Check result'**
  String get speakingCheckResult;

  /// No description provided for @speakingStillPending.
  ///
  /// In en, this message translates to:
  /// **'No result yet.'**
  String get speakingStillPending;

  /// No description provided for @speakingAiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI conversation practice is not available yet.'**
  String get speakingAiUnavailable;

  /// No description provided for @rqTypeAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get rqTypeAnswer;

  /// No description provided for @rqArabicHint.
  ///
  /// In en, this message translates to:
  /// **'Type in Arabic'**
  String get rqArabicHint;

  /// No description provided for @rqWordBank.
  ///
  /// In en, this message translates to:
  /// **'Available words'**
  String get rqWordBank;

  /// No description provided for @rqYourOrder.
  ///
  /// In en, this message translates to:
  /// **'Your order'**
  String get rqYourOrder;

  /// No description provided for @rqUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get rqUndo;

  /// No description provided for @rqReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get rqReset;

  /// No description provided for @rqBlank.
  ///
  /// In en, this message translates to:
  /// **'blank'**
  String get rqBlank;

  /// No description provided for @rqChooseWord.
  ///
  /// In en, this message translates to:
  /// **'Choose the word for the blank'**
  String get rqChooseWord;

  /// No description provided for @rqNoQuestions.
  ///
  /// In en, this message translates to:
  /// **'This activity has no questions yet.'**
  String get rqNoQuestions;

  /// No description provided for @attemptRestored.
  ///
  /// In en, this message translates to:
  /// **'Your unfinished attempt was restored.'**
  String get attemptRestored;

  /// No description provided for @attemptSubmitUnsure.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm the submission. Your answers are kept; try again.'**
  String get attemptSubmitUnsure;

  /// No description provided for @resendConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Resend confirmation email'**
  String get resendConfirmation;

  /// No description provided for @confirmationResent.
  ///
  /// In en, this message translates to:
  /// **'If this address needs confirmation, a new email will be sent.'**
  String get confirmationResent;

  /// No description provided for @resetCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code from the email'**
  String get resetCodeLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @resetConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get resetConfirmAction;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Password changed. You can sign in now.'**
  String get resetDone;

  /// No description provided for @confirmEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirming your email'**
  String get confirmEmailTitle;

  /// No description provided for @confirmEmailDone.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed. You can sign in now.'**
  String get confirmEmailDone;

  /// No description provided for @confirmEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'The confirmation link is invalid or expired.'**
  String get confirmEmailFailed;

  /// No description provided for @passwordPolicy.
  ///
  /// In en, this message translates to:
  /// **'Use at least 12 characters with upper and lower case letters, a digit and a symbol.'**
  String get passwordPolicy;

  /// No description provided for @authInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Please check the details you entered.'**
  String get authInvalidInput;

  /// No description provided for @attemptRecorded.
  ///
  /// In en, this message translates to:
  /// **'Result recorded. Your lesson result is updated on the lesson page.'**
  String get attemptRecorded;

  /// No description provided for @authenticatorCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Authenticator code (only if you use one)'**
  String get authenticatorCodeLabel;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Request account deletion'**
  String get deleteAccountAction;

  /// No description provided for @deleteAccountIntro.
  ///
  /// In en, this message translates to:
  /// **'Requesting deletion deactivates your account right away and signs you out on every device.'**
  String get deleteAccountIntro;

  /// No description provided for @deleteAccountReview.
  ///
  /// In en, this message translates to:
  /// **'Your request is then reviewed by the service operator. Your data is not erased instantly; the final removal is completed by the operator.'**
  String get deleteAccountReview;

  /// No description provided for @deleteAccountPermanent.
  ///
  /// In en, this message translates to:
  /// **'You will not be able to sign in with this account again.'**
  String get deleteAccountPermanent;

  /// No description provided for @deleteAccountReauth.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm that it is you.'**
  String get deleteAccountReauth;

  /// No description provided for @deleteAccountUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand and want to request deletion'**
  String get deleteAccountUnderstand;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Request deletion?'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Your account will be deactivated now. This cannot be undone from the app.'**
  String get deleteAccountDialogBody;

  /// No description provided for @deleteAccountDone.
  ///
  /// In en, this message translates to:
  /// **'Deletion request received. Your account is deactivated and you have been signed out. The final removal of your data is completed by the operator.'**
  String get deleteAccountDone;

  /// No description provided for @deleteAccountInvalid.
  ///
  /// In en, this message translates to:
  /// **'The password or code is not valid.'**
  String get deleteAccountInvalid;

  /// No description provided for @mediaPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get mediaPlay;

  /// No description provided for @mediaPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get mediaPause;

  /// No description provided for @mediaStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get mediaStop;

  /// No description provided for @mediaPlaybackFailed.
  ///
  /// In en, this message translates to:
  /// **'The media could not be played. The link may have expired or you may be offline.'**
  String get mediaPlaybackFailed;

  /// No description provided for @mediaListeningAudio.
  ///
  /// In en, this message translates to:
  /// **'Listening audio'**
  String get mediaListeningAudio;

  /// No description provided for @appLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Which language should the app use?'**
  String get appLanguageTitle;

  /// No description provided for @appLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the app\'s interface language.'**
  String get appLanguageSubtitle;

  /// No description provided for @menuLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn a Language'**
  String get menuLearn;

  /// No description provided for @menuTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate in All Languages'**
  String get menuTranslate;

  /// No description provided for @menuTranslateSoon.
  ///
  /// In en, this message translates to:
  /// **'Translation is coming soon.'**
  String get menuTranslateSoon;

  /// No description provided for @languagePairTitle.
  ///
  /// In en, this message translates to:
  /// **'Language pair'**
  String get languagePairTitle;

  /// No description provided for @languagePairSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the language you know and the language you want to learn.'**
  String get languagePairSubtitle;

  /// No description provided for @pairKnownLabel.
  ///
  /// In en, this message translates to:
  /// **'Language you know'**
  String get pairKnownLabel;

  /// No description provided for @pairTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Language you will learn'**
  String get pairTargetLabel;

  /// No description provided for @languageNameTr.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageNameTr;

  /// No description provided for @languageNameAr.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageNameAr;

  /// No description provided for @sectionLearnArabic.
  ///
  /// In en, this message translates to:
  /// **'Learn Arabic'**
  String get sectionLearnArabic;

  /// No description provided for @sectionReadingWriting.
  ///
  /// In en, this message translates to:
  /// **'Learn Reading and Writing'**
  String get sectionReadingWriting;

  /// No description provided for @sectionQuran.
  ///
  /// In en, this message translates to:
  /// **'The Holy Quran'**
  String get sectionQuran;

  /// No description provided for @sectionExams.
  ///
  /// In en, this message translates to:
  /// **'YDS / YDT / YÖKDİL'**
  String get sectionExams;

  /// No description provided for @sectionAi.
  ///
  /// In en, this message translates to:
  /// **'Practice with AI'**
  String get sectionAi;

  /// No description provided for @comingSoonTag.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get comingSoonTag;

  /// No description provided for @featureUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This section is not available yet.'**
  String get featureUnavailable;

  /// No description provided for @levelPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your level'**
  String get levelPickerTitle;

  /// No description provided for @levelPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your level to learn Arabic.'**
  String get levelPickerSubtitle;

  /// No description provided for @levelFromScratch.
  ///
  /// In en, this message translates to:
  /// **'Start from scratch'**
  String get levelFromScratch;

  /// No description provided for @lessonMenuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a learning mode.'**
  String get lessonMenuSubtitle;

  /// No description provided for @modeTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get modeTest;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @lessonMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Arabic Lessons'**
  String get lessonMenuTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
