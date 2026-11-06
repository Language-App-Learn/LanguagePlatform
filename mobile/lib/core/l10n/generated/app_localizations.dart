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

  /// No description provided for @demoNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo data. Nothing is saved to a server.'**
  String get demoNotice;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @interfaceLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get interfaceLanguageTitle;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themeTitle;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

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

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Learn a new language'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In en, this message translates to:
  /// **'Pick the language you want to learn and start from the language you already know.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Grow with interactive lessons'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In en, this message translates to:
  /// **'Short lessons with dialogues, vocabulary and grammar help you move forward step by step.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Practice words and speaking'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In en, this message translates to:
  /// **'Review vocabulary today. Speaking practice is on its way.'**
  String get onboarding3Body;

  /// No description provided for @onboarding4Title.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get onboarding4Title;

  /// No description provided for @onboarding4Body.
  ///
  /// In en, this message translates to:
  /// **'See finished lessons, quiz scores and your daily goal in one place.'**
  String get onboarding4Body;

  /// No description provided for @onboardingStepSemantics.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepSemantics(int current, int total);

  /// No description provided for @languageSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your languages'**
  String get languageSetupTitle;

  /// No description provided for @languageSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App language, the language you know and the language you want to learn are three separate choices.'**
  String get languageSetupSubtitle;

  /// No description provided for @knownLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'I speak'**
  String get knownLanguageTitle;

  /// No description provided for @targetLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'I want to learn'**
  String get targetLanguageTitle;

  /// No description provided for @sameLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Pick two different languages for \"I speak\" and \"I want to learn\".'**
  String get sameLanguageHint;

  /// No description provided for @chooseBothLanguagesHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the language you know and the language you want to learn.'**
  String get chooseBothLanguagesHint;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @startLesson.
  ///
  /// In en, this message translates to:
  /// **'Start lesson'**
  String get startLesson;

  /// No description provided for @continueCourse.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueCourse;

  /// No description provided for @startCourse.
  ///
  /// In en, this message translates to:
  /// **'Start course'**
  String get startCourse;

  /// No description provided for @reviewCourse.
  ///
  /// In en, this message translates to:
  /// **'Review course'**
  String get reviewCourse;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get navCourses;

  /// No description provided for @navVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get navVocabulary;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeGreeting;

  /// No description provided for @homeLearningLabel.
  ///
  /// In en, this message translates to:
  /// **'Learning: {language}'**
  String homeLearningLabel(String language);

  /// No description provided for @homeChooseTargetHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the language you want to learn in Settings.'**
  String get homeChooseTargetHint;

  /// No description provided for @homeDailyGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get homeDailyGoalTitle;

  /// No description provided for @homeGoalReached.
  ///
  /// In en, this message translates to:
  /// **'You reached today\'s goal!'**
  String get homeGoalReached;

  /// No description provided for @homeDailyGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {goal} lessons today'**
  String homeDailyGoalProgress(int done, int goal);

  /// No description provided for @homeContinueTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get homeContinueTitle;

  /// No description provided for @homeStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your first lesson'**
  String get homeStartTitle;

  /// No description provided for @homeNextLessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get homeNextLessonTitle;

  /// No description provided for @homeAllDone.
  ///
  /// In en, this message translates to:
  /// **'You finished every available lesson. Great work!'**
  String get homeAllDone;

  /// No description provided for @homeFeaturedCourses.
  ///
  /// In en, this message translates to:
  /// **'Featured courses'**
  String get homeFeaturedCourses;

  /// No description provided for @homeRecommendedPractice.
  ///
  /// In en, this message translates to:
  /// **'Recommended practice'**
  String get homeRecommendedPractice;

  /// No description provided for @practiceVocabularyTitle.
  ///
  /// In en, this message translates to:
  /// **'Review vocabulary'**
  String get practiceVocabularyTitle;

  /// No description provided for @practiceVocabularySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse your words and update how well you know them'**
  String get practiceVocabularySubtitle;

  /// No description provided for @practiceQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Test yourself'**
  String get practiceQuizTitle;

  /// No description provided for @homeProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get homeProgressTitle;

  /// No description provided for @coursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesTitle;

  /// No description provided for @searchCoursesHint.
  ///
  /// In en, this message translates to:
  /// **'Search courses'**
  String get searchCoursesHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @filterLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get filterLanguageTitle;

  /// No description provided for @filterLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get filterLevelTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @noCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'No courses found'**
  String get noCoursesTitle;

  /// No description provided for @noCoursesMessage.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search or filters.'**
  String get noCoursesMessage;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @lessonCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No lessons} =1{1 lesson} other{{count} lessons}}'**
  String lessonCount(int count);

  /// No description provided for @lessonMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String lessonMinutes(int minutes);

  /// No description provided for @courseProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} lessons'**
  String courseProgressLabel(int done, int total);

  /// No description provided for @courseLessonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get courseLessonsTitle;

  /// No description provided for @noLessonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lessons are coming soon'**
  String get noLessonsTitle;

  /// No description provided for @noLessonsMessage.
  ///
  /// In en, this message translates to:
  /// **'The content for this course is being prepared.'**
  String get noLessonsMessage;

  /// No description provided for @quizBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best: {score}'**
  String quizBestScore(String score);

  /// No description provided for @lessonDialogue.
  ///
  /// In en, this message translates to:
  /// **'Dialogue'**
  String get lessonDialogue;

  /// No description provided for @lessonVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get lessonVocabulary;

  /// No description provided for @lessonGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get lessonGrammar;

  /// No description provided for @lessonExample.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get lessonExample;

  /// No description provided for @lessonExercise.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get lessonExercise;

  /// No description provided for @checkAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get checkAnswer;

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

  /// No description provided for @markLessonComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as complete'**
  String get markLessonComplete;

  /// No description provided for @lessonCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get lessonCompleted;

  /// No description provided for @takeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take the quiz'**
  String get takeQuiz;

  /// No description provided for @previousLesson.
  ///
  /// In en, this message translates to:
  /// **'Previous lesson'**
  String get previousLesson;

  /// No description provided for @nextLesson.
  ///
  /// In en, this message translates to:
  /// **'Next lesson'**
  String get nextLesson;

  /// No description provided for @quizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quizTitle;

  /// No description provided for @quizQuestionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizQuestionOf(int current, int total);

  /// No description provided for @quizNext.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get quizNext;

  /// No description provided for @quizFinish.
  ///
  /// In en, this message translates to:
  /// **'See results'**
  String get quizFinish;

  /// No description provided for @quizResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your result'**
  String get quizResultTitle;

  /// No description provided for @quizScoreSummary.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct'**
  String quizScoreSummary(int correct, int total);

  /// No description provided for @quizPassed.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get quizPassed;

  /// No description provided for @quizFailed.
  ///
  /// In en, this message translates to:
  /// **'Keep practicing.'**
  String get quizFailed;

  /// No description provided for @quizTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get quizTryAgain;

  /// No description provided for @quizLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'In this demo build, results are kept only on this device.'**
  String get quizLocalOnly;

  /// No description provided for @quizEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No questions yet'**
  String get quizEmptyTitle;

  /// No description provided for @vocabularyTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabularyTitle;

  /// No description provided for @vocabularyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No words found'**
  String get vocabularyEmptyTitle;

  /// No description provided for @vocabularyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Change the filter or choose a language to learn.'**
  String get vocabularyEmptyMessage;

  /// No description provided for @vocabularyStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get vocabularyStatusNew;

  /// No description provided for @vocabularyStatusLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get vocabularyStatusLearning;

  /// No description provided for @vocabularyStatusLearned.
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get vocabularyStatusLearned;

  /// No description provided for @wordMeaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get wordMeaning;

  /// No description provided for @wordStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning status'**
  String get wordStatusTitle;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Progress is kept only on this device and resets when you close the app. It is not saved to an account.'**
  String get progressDemoNotice;

  /// No description provided for @progressCompletedLessons.
  ///
  /// In en, this message translates to:
  /// **'Completed lessons'**
  String get progressCompletedLessons;

  /// No description provided for @progressAverageScore.
  ///
  /// In en, this message translates to:
  /// **'Average quiz score'**
  String get progressAverageScore;

  /// No description provided for @progressNoQuizYet.
  ///
  /// In en, this message translates to:
  /// **'No quizzes yet'**
  String get progressNoQuizYet;

  /// No description provided for @progressDailyGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get progressDailyGoalTitle;

  /// No description provided for @dailyGoalOption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lesson a day} other{{count} lessons a day}}'**
  String dailyGoalOption(int count);

  /// No description provided for @progressCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Course progress'**
  String get progressCoursesTitle;

  /// No description provided for @progressEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No progress yet'**
  String get progressEmptyTitle;

  /// No description provided for @progressEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete a lesson to see your progress here.'**
  String get progressEmptyMessage;

  /// No description provided for @browseCourses.
  ///
  /// In en, this message translates to:
  /// **'Browse courses'**
  String get browseCourses;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileDemoName.
  ///
  /// In en, this message translates to:
  /// **'Demo learner'**
  String get profileDemoName;

  /// No description provided for @profileGuestName.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuestName;

  /// No description provided for @profileDemoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Demo mode, not signed in'**
  String get profileDemoSubtitle;

  /// No description provided for @profileSignedOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get profileSignedOutSubtitle;

  /// No description provided for @profileLanguagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get profileLanguagesTitle;

  /// No description provided for @accountIntegrationPending.
  ///
  /// In en, this message translates to:
  /// **'Account features need a server connection and are not available yet.'**
  String get accountIntegrationPending;

  /// No description provided for @exitDemoMode.
  ///
  /// In en, this message translates to:
  /// **'Exit demo mode'**
  String get exitDemoMode;

  /// No description provided for @accountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSectionTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'LanguagePlatform helps you learn languages in your own language. This is a demo build.'**
  String get aboutDescription;

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

  /// No description provided for @demoModeExplain.
  ///
  /// In en, this message translates to:
  /// **'Demo mode lets you explore the app with sample content. No account is created and nothing is saved.'**
  String get demoModeExplain;

  /// No description provided for @continueDemo.
  ///
  /// In en, this message translates to:
  /// **'Continue in demo mode'**
  String get continueDemo;

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

  /// No description provided for @homeResumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume your lesson'**
  String get homeResumeTitle;

  /// No description provided for @weeklyActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get weeklyActivityTitle;

  /// No description provided for @activityStreak.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1-day streak} other{{days}-day streak}}'**
  String activityStreak(int days);

  /// No description provided for @activityNone.
  ///
  /// In en, this message translates to:
  /// **'No activity recorded yet. Finish a lesson, quiz or review to see it here.'**
  String get activityNone;

  /// No description provided for @statWordsLearned.
  ///
  /// In en, this message translates to:
  /// **'Words learned'**
  String get statWordsLearned;

  /// No description provided for @statWordsLearning.
  ///
  /// In en, this message translates to:
  /// **'Words in progress'**
  String get statWordsLearning;

  /// No description provided for @statReviewsDue.
  ///
  /// In en, this message translates to:
  /// **'Reviews due'**
  String get statReviewsDue;

  /// No description provided for @vocabularySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search words'**
  String get vocabularySearchHint;

  /// No description provided for @vocabularyFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get vocabularyFavorites;

  /// No description provided for @favoriteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favoriteRemove;

  /// No description provided for @reviewDueBadge.
  ///
  /// In en, this message translates to:
  /// **'Due for review'**
  String get reviewDueBadge;

  /// No description provided for @reviewDueBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No words due. Practice new words} =1{1 word due for review} other{{count} words due for review}}'**
  String reviewDueBanner(int count);

  /// No description provided for @startReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get startReview;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get reviewTitle;

  /// No description provided for @reviewShowAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get reviewShowAnswer;

  /// No description provided for @reviewProgress.
  ///
  /// In en, this message translates to:
  /// **'Card {current} of {total}'**
  String reviewProgress(int current, int total);

  /// No description provided for @ratingAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get ratingAgain;

  /// No description provided for @ratingHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get ratingHard;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get ratingEasy;

  /// No description provided for @reviewDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get reviewDoneTitle;

  /// No description provided for @reviewDoneSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You reviewed 1 word.} other{You reviewed {count} words.}}'**
  String reviewDoneSummary(int count);

  /// No description provided for @reviewNothingTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review'**
  String get reviewNothingTitle;

  /// No description provided for @reviewNothingMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a language to learn or come back when words are due.'**
  String get reviewNothingMessage;

  /// No description provided for @settingsDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo build: your settings and progress are stored only on this device, not in an account.'**
  String get settingsDemoNotice;

  /// No description provided for @resetDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset local demo data'**
  String get resetDataTitle;

  /// No description provided for @resetDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deletes progress, vocabulary state and preferences on this device'**
  String get resetDataSubtitle;

  /// No description provided for @resetDataConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset local data?'**
  String get resetDataConfirmTitle;

  /// No description provided for @resetDataConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This deletes your onboarding state, language choices, progress and vocabulary records on this device. It cannot be undone.'**
  String get resetDataConfirmMessage;

  /// No description provided for @resetDataConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetDataConfirmAction;

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

  /// No description provided for @storageWriteFailed.
  ///
  /// In en, this message translates to:
  /// **'Some changes could not be saved on this device and may be lost when you close the app.'**
  String get storageWriteFailed;

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

  /// No description provided for @unsupportedContent.
  ///
  /// In en, this message translates to:
  /// **'This content is not supported in this version of the app.'**
  String get unsupportedContent;

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

  /// No description provided for @activeCourseTitle.
  ///
  /// In en, this message translates to:
  /// **'Your course'**
  String get activeCourseTitle;

  /// No description provided for @activeCourseEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No course yet'**
  String get activeCourseEmptyTitle;

  /// No description provided for @activeCourseEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Pick a course to see your level and progress here.'**
  String get activeCourseEmptyMessage;

  /// No description provided for @openCourse.
  ///
  /// In en, this message translates to:
  /// **'Open course'**
  String get openCourse;

  /// No description provided for @reviewHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Review history'**
  String get reviewHistoryTitle;

  /// No description provided for @reviewHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get reviewHistoryEmptyTitle;

  /// No description provided for @reviewHistoryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your flashcard reviews will appear here.'**
  String get reviewHistoryEmptyMessage;

  /// No description provided for @historyNextReview.
  ///
  /// In en, this message translates to:
  /// **'Next review: {date}'**
  String historyNextReview(String date);

  /// No description provided for @historyUnknownWord.
  ///
  /// In en, this message translates to:
  /// **'Word no longer available'**
  String get historyUnknownWord;

  /// No description provided for @reviewHistoryOpen.
  ///
  /// In en, this message translates to:
  /// **'Review history'**
  String get reviewHistoryOpen;
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
