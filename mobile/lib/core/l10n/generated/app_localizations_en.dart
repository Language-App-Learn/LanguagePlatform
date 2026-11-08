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
  String get demoNotice => 'Demo data. Nothing is saved to a server.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get interfaceLanguageTitle => 'App language';

  @override
  String get themeTitle => 'Appearance';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get getStarted => 'Get started';

  @override
  String get continueAction => 'Continue';

  @override
  String get onboarding1Title => 'Learn a new language';

  @override
  String get onboarding1Body =>
      'Pick the language you want to learn and start from the language you already know.';

  @override
  String get onboarding2Title => 'Grow with interactive lessons';

  @override
  String get onboarding2Body =>
      'Short lessons with dialogues, vocabulary and grammar help you move forward step by step.';

  @override
  String get onboarding3Title => 'Practice words and speaking';

  @override
  String get onboarding3Body =>
      'Review vocabulary today. Speaking practice is on its way.';

  @override
  String get onboarding4Title => 'Track your progress';

  @override
  String get onboarding4Body =>
      'See finished lessons, quiz scores and your daily goal in one place.';

  @override
  String onboardingStepSemantics(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get languageSetupTitle => 'Choose your languages';

  @override
  String get languageSetupSubtitle =>
      'App language, the language you know and the language you want to learn are three separate choices.';

  @override
  String get knownLanguageTitle => 'I speak';

  @override
  String get targetLanguageTitle => 'I want to learn';

  @override
  String get sameLanguageHint =>
      'Pick two different languages for \"I speak\" and \"I want to learn\".';

  @override
  String get chooseBothLanguagesHint =>
      'Choose the language you know and the language you want to learn.';

  @override
  String get done => 'Done';

  @override
  String get viewAll => 'View all';

  @override
  String get startLesson => 'Start lesson';

  @override
  String get continueCourse => 'Continue';

  @override
  String get startCourse => 'Start course';

  @override
  String get reviewCourse => 'Review course';

  @override
  String get navHome => 'Home';

  @override
  String get navCourses => 'Courses';

  @override
  String get navVocabulary => 'Words';

  @override
  String get navProgress => 'Progress';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeGreeting => 'Welcome back';

  @override
  String homeLearningLabel(String language) {
    return 'Learning: $language';
  }

  @override
  String get homeChooseTargetHint =>
      'Choose the language you want to learn in Settings.';

  @override
  String get homeDailyGoalTitle => 'Daily goal';

  @override
  String get homeGoalReached => 'You reached today\'s goal!';

  @override
  String homeDailyGoalProgress(int done, int goal) {
    return '$done of $goal lessons today';
  }

  @override
  String get homeContinueTitle => 'Continue learning';

  @override
  String get homeStartTitle => 'Start your first lesson';

  @override
  String get homeNextLessonTitle => 'Up next';

  @override
  String get homeAllDone => 'You finished every available lesson. Great work!';

  @override
  String get homeFeaturedCourses => 'Featured courses';

  @override
  String get homeRecommendedPractice => 'Recommended practice';

  @override
  String get practiceVocabularyTitle => 'Review vocabulary';

  @override
  String get practiceVocabularySubtitle =>
      'Browse your words and update how well you know them';

  @override
  String get practiceQuizTitle => 'Test yourself';

  @override
  String get homeProgressTitle => 'Your progress';

  @override
  String get coursesTitle => 'Courses';

  @override
  String get searchCoursesHint => 'Search courses';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get filterLanguageTitle => 'Language';

  @override
  String get filterLevelTitle => 'Level';

  @override
  String get filterAll => 'All';

  @override
  String get noCoursesTitle => 'No courses found';

  @override
  String get noCoursesMessage => 'Try changing your search or filters.';

  @override
  String get clearFilters => 'Clear filters';

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
  String lessonMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String courseProgressLabel(int done, int total) {
    return '$done/$total lessons';
  }

  @override
  String get courseLessonsTitle => 'Lessons';

  @override
  String get noLessonsTitle => 'Lessons are coming soon';

  @override
  String get noLessonsMessage =>
      'The content for this course is being prepared.';

  @override
  String quizBestScore(String score) {
    return 'Best: $score';
  }

  @override
  String get lessonDialogue => 'Dialogue';

  @override
  String get lessonVocabulary => 'Vocabulary';

  @override
  String get lessonGrammar => 'Grammar';

  @override
  String get lessonExample => 'Example';

  @override
  String get lessonExercise => 'Practice';

  @override
  String get checkAnswer => 'Check answer';

  @override
  String get answerCorrect => 'Correct!';

  @override
  String get answerIncorrect => 'Not quite.';

  @override
  String get markLessonComplete => 'Mark as complete';

  @override
  String get lessonCompleted => 'Completed';

  @override
  String get takeQuiz => 'Take the quiz';

  @override
  String get previousLesson => 'Previous lesson';

  @override
  String get nextLesson => 'Next lesson';

  @override
  String get quizTitle => 'Quiz';

  @override
  String quizQuestionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get quizNext => 'Next question';

  @override
  String get quizFinish => 'See results';

  @override
  String get quizResultTitle => 'Your result';

  @override
  String quizScoreSummary(int correct, int total) {
    return '$correct of $total correct';
  }

  @override
  String get quizPassed => 'Great job!';

  @override
  String get quizFailed => 'Keep practicing.';

  @override
  String get quizTryAgain => 'Try again';

  @override
  String get quizLocalOnly =>
      'In this demo build, results are kept only on this device.';

  @override
  String get quizEmptyTitle => 'No questions yet';

  @override
  String get vocabularyTitle => 'Vocabulary';

  @override
  String get vocabularyEmptyTitle => 'No words found';

  @override
  String get vocabularyEmptyMessage =>
      'Change the filter or choose a language to learn.';

  @override
  String get vocabularyStatusNew => 'New';

  @override
  String get vocabularyStatusLearning => 'Learning';

  @override
  String get vocabularyStatusLearned => 'Learned';

  @override
  String get wordMeaning => 'Meaning';

  @override
  String get wordStatusTitle => 'Learning status';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressDemoNotice =>
      'Progress is kept only on this device and resets when you close the app. It is not saved to an account.';

  @override
  String get progressCompletedLessons => 'Completed lessons';

  @override
  String get progressAverageScore => 'Average quiz score';

  @override
  String get progressNoQuizYet => 'No quizzes yet';

  @override
  String get progressDailyGoalTitle => 'Daily goal';

  @override
  String dailyGoalOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons a day',
      one: '1 lesson a day',
    );
    return '$_temp0';
  }

  @override
  String get progressCoursesTitle => 'Course progress';

  @override
  String get progressEmptyTitle => 'No progress yet';

  @override
  String get progressEmptyMessage =>
      'Complete a lesson to see your progress here.';

  @override
  String get browseCourses => 'Browse courses';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDemoName => 'Demo learner';

  @override
  String get profileGuestName => 'Guest';

  @override
  String get profileDemoSubtitle => 'Demo mode, not signed in';

  @override
  String get profileSignedOutSubtitle => 'Not signed in';

  @override
  String get profileLanguagesTitle => 'Languages';

  @override
  String get accountIntegrationPending =>
      'Account features need a server connection and are not available yet.';

  @override
  String get exitDemoMode => 'Exit demo mode';

  @override
  String get accountSectionTitle => 'Account';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changePassword => 'Change password';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutDescription =>
      'LanguagePlatform helps you learn languages in your own language. This is a demo build.';

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
  String get demoModeExplain =>
      'Demo mode lets you explore the app with sample content. No account is created and nothing is saved.';

  @override
  String get continueDemo => 'Continue in demo mode';

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
  String get homeResumeTitle => 'Resume your lesson';

  @override
  String get weeklyActivityTitle => 'Last 7 days';

  @override
  String activityStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days-day streak',
      one: '1-day streak',
    );
    return '$_temp0';
  }

  @override
  String get activityNone =>
      'No activity recorded yet. Finish a lesson, quiz or review to see it here.';

  @override
  String get statWordsLearned => 'Words learned';

  @override
  String get statWordsLearning => 'Words in progress';

  @override
  String get statReviewsDue => 'Reviews due';

  @override
  String get vocabularySearchHint => 'Search words';

  @override
  String get vocabularyFavorites => 'Favorites';

  @override
  String get favoriteAdd => 'Add to favorites';

  @override
  String get favoriteRemove => 'Remove from favorites';

  @override
  String get reviewDueBadge => 'Due for review';

  @override
  String reviewDueBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words due for review',
      one: '1 word due for review',
      zero: 'No words due. Practice new words',
    );
    return '$_temp0';
  }

  @override
  String get startReview => 'Review';

  @override
  String get reviewTitle => 'Flashcards';

  @override
  String get reviewShowAnswer => 'Show answer';

  @override
  String reviewProgress(int current, int total) {
    return 'Card $current of $total';
  }

  @override
  String get ratingAgain => 'Again';

  @override
  String get ratingHard => 'Hard';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingEasy => 'Easy';

  @override
  String get reviewDoneTitle => 'Session complete';

  @override
  String reviewDoneSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You reviewed $count words.',
      one: 'You reviewed 1 word.',
    );
    return '$_temp0';
  }

  @override
  String get reviewNothingTitle => 'Nothing to review';

  @override
  String get reviewNothingMessage =>
      'Choose a language to learn or come back when words are due.';

  @override
  String get settingsDemoNotice =>
      'Demo build: your settings and progress are stored only on this device, not in an account.';

  @override
  String get resetDataTitle => 'Reset local demo data';

  @override
  String get resetDataSubtitle =>
      'Deletes progress, vocabulary state and preferences on this device';

  @override
  String get resetDataConfirmTitle => 'Reset local data?';

  @override
  String get resetDataConfirmMessage =>
      'This deletes your onboarding state, language choices, progress and vocabulary records on this device. It cannot be undone.';

  @override
  String get resetDataConfirmAction => 'Reset';

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
  String get storageWriteFailed =>
      'Some changes could not be saved on this device and may be lost when you close the app.';

  @override
  String get answerTrue => 'True';

  @override
  String get answerFalse => 'False';

  @override
  String get unsupportedContent =>
      'This content is not supported in this version of the app.';

  @override
  String get pageNotFoundTitle => 'Page not found';

  @override
  String get pageNotFoundMessage => 'The page you opened does not exist.';

  @override
  String get goHome => 'Go to home';

  @override
  String get activeCourseTitle => 'Your course';

  @override
  String get activeCourseEmptyTitle => 'No course yet';

  @override
  String get activeCourseEmptyMessage =>
      'Pick a course to see your level and progress here.';

  @override
  String get openCourse => 'Open course';

  @override
  String get reviewHistoryTitle => 'Review history';

  @override
  String get reviewHistoryEmptyTitle => 'No reviews yet';

  @override
  String get reviewHistoryEmptyMessage =>
      'Your flashcard reviews will appear here.';

  @override
  String historyNextReview(String date) {
    return 'Next review: $date';
  }

  @override
  String get historyUnknownWord => 'Word no longer available';

  @override
  String get reviewHistoryOpen => 'Review history';

  @override
  String get brandTagline => 'LANGUAGE LEARNING PLATFORM';

  @override
  String lessonPosition(int current, int total) {
    return 'Lesson $current of $total';
  }

  @override
  String get lessonCompletedSnack => 'Lesson marked as complete';

  @override
  String get leaveQuizTitle => 'Leave the quiz?';

  @override
  String get leaveQuizMessage =>
      'Your answers in this attempt will not be saved.';

  @override
  String get leaveQuizConfirm => 'Leave';

  @override
  String optionLetterSemantics(String letter) {
    return 'Option $letter';
  }

  @override
  String get trackTitle => 'Learn Arabic from Turkish';

  @override
  String get trackSubtitle => 'Choose your CEFR level';

  @override
  String get demoContentBadge => 'Demo content';

  @override
  String get levelNameA1 => 'Beginner';

  @override
  String get levelNameA2 => 'Elementary';

  @override
  String get levelNameB1 => 'Intermediate';

  @override
  String get levelNameB2 => 'Upper intermediate';

  @override
  String get levelNameC1 => 'Advanced';

  @override
  String get levelNameC2 => 'Proficient';

  @override
  String levelPublishedCount(int published, int total) {
    return '$published of $total lessons published';
  }

  @override
  String levelCompletedCount(int count) {
    return '$count completed';
  }

  @override
  String get levelNoLessons => 'No lessons published yet';

  @override
  String lessonNumber(int number) {
    return 'Lesson $number';
  }

  @override
  String get lessonInPreparation => 'In preparation';

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
  String get demoScoreNotice =>
      'Demo practice result. It is not an official score and does not count towards passing.';

  @override
  String stageScoreLabel(String score) {
    return 'Practice score: $score';
  }

  @override
  String get audioUnavailable => 'Audio is not available yet';

  @override
  String get pdfUnavailable => 'The original PDF is not available yet';

  @override
  String get videoUnavailable => 'The teacher video is not available yet';

  @override
  String get aiPracticeTitle => 'Conversation practice';

  @override
  String get aiPracticeUnavailable =>
      'AI conversation practice is not connected yet. No recording is made or sent.';

  @override
  String get dialogueTitle => 'Dialogue';

  @override
  String get readingQuestionsTitle => 'Questions';

  @override
  String get listeningInstruction =>
      'Audio is not available yet. Place each word into the right blank.';

  @override
  String get writingFillTitle => 'Fill in the blank';

  @override
  String get writingArrangeTitle => 'Arrange the words';

  @override
  String get translationChoiceTitle => 'Choose the correct translation';

  @override
  String get translationWriteTitle => 'Write the translation';

  @override
  String get wordBank => 'Word bank';

  @override
  String get tapToPlace => 'Tap a word, then tap a blank (or drag the word).';

  @override
  String blankLabel(int number) {
    return 'Blank $number';
  }

  @override
  String get checkStage => 'Check answers';

  @override
  String get resetStage => 'Reset';

  @override
  String get undoStep => 'Undo';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get finishPractice => 'Finish practice';

  @override
  String get stageContentMissing =>
      'This lesson has no published content for this stage yet.';

  @override
  String resultCorrect(int correct, int total) {
    return '$correct of $total correct';
  }

  @override
  String get practiceRecorded => 'Practice recorded on this device (demo).';

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
  String get profileAccountSubtitle => 'Signed in to your account';

  @override
  String get remoteSignInPrompt => 'Sign in to see and save your progress.';

  @override
  String get remoteNotConfigured =>
      'The learning server is not configured in this build.';

  @override
  String get remoteBeginLesson => 'Begin this lesson';

  @override
  String get remoteNoCourse => 'No Turkish-to-Arabic course is published yet.';

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
  String get attemptPassed => 'Passed';

  @override
  String get attemptNotPassed => 'Not passed';

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
  String get mediaAudioAvailable => 'Listening audio is available.';

  @override
  String mediaVideoAvailable(String title) {
    return 'Teacher video: $title';
  }

  @override
  String get mediaPlaybackUnavailable =>
      'Playback is not enabled in this build yet.';

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
  String get homeRemoteNotice =>
      'Your lessons and official results come from your account. Vocabulary, review and activity summaries will appear here when they are connected to it.';

  @override
  String get localPracticeNotice =>
      'This is practice data stored only on this device. It is not linked to your account and is not an official result.';

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
