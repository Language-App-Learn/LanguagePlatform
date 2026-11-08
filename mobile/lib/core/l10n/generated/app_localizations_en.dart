// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LanguagePlatform';

  @override
  String get retry => 'Try again';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get loadingLabel => 'Loading';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get startLesson => 'Start lesson';

  @override
  String lessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
      zero: 'No lessons',
    );
    return '$_temp0';
  }

  @override
  String get answerCorrect => 'Correct!';

  @override
  String get answerIncorrect => 'Not quite.';

  @override
  String get nextLesson => 'Next lesson';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get loginButton => 'Sign in';

  @override
  String get noAccountPrompt => 'New here?';

  @override
  String get registerButton => 'Create account';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle =>
      'Account creation will be available once the service is connected.';

  @override
  String get nameLabel => 'Name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get haveAccountPrompt => 'Already have an account?';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we will send reset instructions.';

  @override
  String get sendResetButton => 'Send reset link';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String passwordTooShort(int min) {
    return 'Password must be at least $min characters';
  }

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get authUnavailable =>
      'Sign-in is not connected to a server yet. This build cannot create or verify accounts.';

  @override
  String get cancel => 'Cancel';

  @override
  String get errorNetwork =>
      'No internet connection. Check your connection and try again.';

  @override
  String get errorTimeout => 'The request took too long. Please try again.';

  @override
  String get errorUnauthorized => 'Please sign in to continue.';

  @override
  String get errorForbidden => 'You don\'t have access to this content.';

  @override
  String get errorServer => 'The server had a problem. Please try again later.';

  @override
  String get errorUnavailable => 'This feature is not connected yet.';

  @override
  String get answerTrue => 'True';

  @override
  String get answerFalse => 'False';

  @override
  String get pageNotFoundTitle => 'Page not found';

  @override
  String get pageNotFoundMessage => 'The page you opened does not exist.';

  @override
  String get goHome => 'Go to home';

  @override
  String get brandTagline => 'LANGUAGE LEARNING PLATFORM';

  @override
  String lessonPosition(int current, int total) {
    return 'Lesson $current of $total';
  }

  @override
  String get stageReading => 'Reading';

  @override
  String get stageSpeaking => 'Speaking';

  @override
  String get stageListening => 'Listening';

  @override
  String get stageWriting => 'Writing';

  @override
  String get stageTranslation => 'Translation';

  @override
  String get stageReadingDesc =>
      'Read the Arabic text, listen to each line and answer questions.';

  @override
  String get stageSpeakingDesc => 'Study the dialogue and practice speaking.';

  @override
  String get stageListeningDesc => 'Listen and place the words in the blanks.';

  @override
  String get stageWritingDesc => 'Fill in missing words and build sentences.';

  @override
  String get stageTranslationDesc => 'Translate from Turkish into Arabic.';

  @override
  String get stageStatusAvailable => 'Available';

  @override
  String get stageStatusInProgress => 'In progress';

  @override
  String get stageStatusCompleted => 'Completed';

  @override
  String get stageStatusLocked => 'Not yet accessible';

  @override
  String get stageStatusUnavailable => 'Content not published yet';

  @override
  String get stageRetry => 'Practice again';

  @override
  String get lessonStatusNotStarted => 'Not started';

  @override
  String get lessonStatusInProgress => 'In progress';

  @override
  String get lessonStatusAwaiting => 'Awaiting official assessment';

  @override
  String get lessonStatusPassed => 'Passed';

  @override
  String get lessonStatusFailed => 'Not passed, try again';

  @override
  String get overallScoreNone => 'No official score yet';

  @override
  String passMarkInfo(int mark) {
    return 'Overall pass mark: $mark out of 100';
  }

  @override
  String get scoringPolicyMissing =>
      'The stage weights are set by the server and are not available yet, so no final score is shown.';

  @override
  String get wordBank => 'Word bank';

  @override
  String get stageContentMissing =>
      'This lesson has no published content for this stage yet.';

  @override
  String get authInvalidCredentials =>
      'Email or password is incorrect, or the account is not confirmed yet.';

  @override
  String get registerAccepted =>
      'Registration request sent. Check your email to confirm your account.';

  @override
  String get resetRequested =>
      'If this address belongs to an account, reset instructions will be sent.';

  @override
  String get signOut => 'Sign out';

  @override
  String get remoteSignInPrompt => 'Sign in to see and save your progress.';

  @override
  String get remoteBeginLesson => 'Begin this lesson';

  @override
  String stageAttempts(int count) {
    return 'Attempts: $count';
  }

  @override
  String stageWeight(String weight) {
    return 'Weight: $weight%';
  }

  @override
  String get remoteStageNoAssessment =>
      'No graded activity is published for this stage yet.';

  @override
  String get remoteStageTextTitle => 'Stage text';

  @override
  String get startAssessment => 'Start graded activity';

  @override
  String get submitAnswers => 'Submit answers';

  @override
  String get officialResultTitle => 'Official result';

  @override
  String officialResultScore(String score, String max) {
    return '$score of $max';
  }

  @override
  String get nextLessonAction => 'Go to the next lesson';

  @override
  String get unsupportedQuestion =>
      'This question type is not supported in this version of the app.';

  @override
  String get errorConflict =>
      'This action isn\'t available right now. The stage may be locked, or the attempt limit may be reached.';

  @override
  String get errorRateLimited =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get errorTooLarge => 'The file is too large.';

  @override
  String get errorUnsupportedMedia => 'This file type is not supported.';

  @override
  String get readingMaterialTitle => 'Teacher-approved Arabic text';

  @override
  String get readingMaterialEmpty =>
      'The reading text has not been published yet.';

  @override
  String get readingPdfDownload => 'Download original PDF';

  @override
  String get readingPdfDownloading => 'Downloading…';

  @override
  String readingPdfReady(String size) {
    return 'PDF downloaded ($size)';
  }

  @override
  String get readingPdfHandoffUnavailable =>
      'This build cannot save or open PDF files yet.';

  @override
  String readingLineLabel(int number) {
    return 'Line $number';
  }

  @override
  String mediaVideoAvailable(String title) {
    return 'Teacher video: $title';
  }

  @override
  String get mediaNone =>
      'No audio or video has been published for this stage.';

  @override
  String get speakingStartAttempt => 'Start speaking attempt';

  @override
  String get speakingWaitingTitle => 'Waiting for evaluation';

  @override
  String get speakingWaitingBody =>
      'An authorized evaluator scores your speaking. Your result appears here once it is recorded.';

  @override
  String get speakingCheckResult => 'Check result';

  @override
  String get speakingStillPending => 'No result yet.';

  @override
  String get speakingAiUnavailable =>
      'AI conversation practice is not available yet.';

  @override
  String get rqTypeAnswer => 'Your answer';

  @override
  String get rqArabicHint => 'Type in Arabic';

  @override
  String get rqWordBank => 'Available words';

  @override
  String get rqYourOrder => 'Your order';

  @override
  String get rqUndo => 'Undo';

  @override
  String get rqReset => 'Reset';

  @override
  String get rqBlank => 'blank';

  @override
  String get rqChooseWord => 'Choose the word for the blank';

  @override
  String get rqNoQuestions => 'This activity has no questions yet.';

  @override
  String get attemptRestored => 'Your unfinished attempt was restored.';

  @override
  String get attemptSubmitUnsure =>
      'We couldn\'t confirm the submission. Your answers are kept; try again.';

  @override
  String get resendConfirmation => 'Resend confirmation email';

  @override
  String get confirmationResent =>
      'If this address needs confirmation, a new email will be sent.';

  @override
  String get resetCodeLabel => 'Code from the email';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get resetConfirmAction => 'Change password';

  @override
  String get resetDone => 'Password changed. You can sign in now.';

  @override
  String get confirmEmailTitle => 'Confirming your email';

  @override
  String get confirmEmailDone => 'Email confirmed. You can sign in now.';

  @override
  String get confirmEmailFailed =>
      'The confirmation link is invalid or expired.';

  @override
  String get passwordPolicy =>
      'Use at least 12 characters with upper and lower case letters, a digit and a symbol.';

  @override
  String get authInvalidInput => 'Please check the details you entered.';

  @override
  String get attemptRecorded =>
      'Result recorded. Your lesson result is updated on the lesson page.';

  @override
  String get authenticatorCodeLabel =>
      'Authenticator code (only if you use one)';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountAction => 'Request account deletion';

  @override
  String get deleteAccountIntro =>
      'Requesting deletion deactivates your account right away and signs you out on every device.';

  @override
  String get deleteAccountReview =>
      'Your request is then reviewed by the service operator. Your data is not erased instantly; the final removal is completed by the operator.';

  @override
  String get deleteAccountPermanent =>
      'You will not be able to sign in with this account again.';

  @override
  String get deleteAccountReauth =>
      'Enter your password to confirm that it is you.';

  @override
  String get deleteAccountUnderstand =>
      'I understand and want to request deletion';

  @override
  String get deleteAccountDialogTitle => 'Request deletion?';

  @override
  String get deleteAccountDialogBody =>
      'Your account will be deactivated now. This cannot be undone from the app.';

  @override
  String get deleteAccountDone =>
      'Deletion request received. Your account is deactivated and you have been signed out. The final removal of your data is completed by the operator.';

  @override
  String get deleteAccountInvalid => 'The password or code is not valid.';

  @override
  String get mediaPlay => 'Play';

  @override
  String get mediaPause => 'Pause';

  @override
  String get mediaStop => 'Stop';

  @override
  String get mediaPlaybackFailed =>
      'The media could not be played. The link may have expired or you may be offline.';

  @override
  String get mediaListeningAudio => 'Listening audio';

  @override
  String get appLanguageTitle => 'Which language should the app use?';

  @override
  String get appLanguageSubtitle => 'Choose the app\'s interface language.';

  @override
  String get menuLearn => 'Learn a Language';

  @override
  String get menuTranslate => 'Translate in All Languages';

  @override
  String get menuTranslateSoon => 'Translation is coming soon.';

  @override
  String get languagePairTitle => 'Language pair';

  @override
  String get languagePairSubtitle =>
      'Choose the language you know and the language you want to learn.';

  @override
  String get pairKnownLabel => 'Language you know';

  @override
  String get pairTargetLabel => 'Language you will learn';

  @override
  String get languageNameTr => 'Turkish';

  @override
  String get languageNameAr => 'Arabic';

  @override
  String get sectionLearnArabic => 'Learn Arabic';

  @override
  String get sectionReadingWriting => 'Learn Reading and Writing';

  @override
  String get sectionQuran => 'The Holy Quran';

  @override
  String get sectionExams => 'YDS / YDT / YÖKDİL';

  @override
  String get sectionAi => 'Practice with AI';

  @override
  String get comingSoonTag => 'Soon';

  @override
  String get featureUnavailable => 'This section is not available yet.';

  @override
  String get levelPickerTitle => 'Choose your level';

  @override
  String get levelPickerSubtitle => 'Choose your level to learn Arabic.';

  @override
  String get levelFromScratch => 'Start from scratch';

  @override
  String get lessonMenuSubtitle => 'Choose a learning mode.';

  @override
  String get modeTest => 'Test';

  @override
  String get continueButton => 'Continue';

  @override
  String get lessonMenuTitle => 'Arabic Lessons';
}
