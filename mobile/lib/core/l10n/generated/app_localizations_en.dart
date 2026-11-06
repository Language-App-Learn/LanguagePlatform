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
}
