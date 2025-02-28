import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Screen tracking
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // Track when user adds produce
  Future<void> logAddProduce({
    required String produceName,
    required String category,
  }) async {
    await _analytics.logEvent(
      name: 'add_produce',
      parameters: {
        'produce_name': produceName,
        'category': category,
      },
    );
  }

  // Track when user updates goals
  Future<void> logGoalUpdate({
    required String goalType,
    required int oldValue,
    required int newValue,
  }) async {
    await _analytics.logEvent(
      name: 'update_goal',
      parameters: {
        'goal_type': goalType,
        'old_value': oldValue,
        'new_value': newValue,
      },
    );
  }

  // Track when user views history
  Future<void> logViewHistory({
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _analytics.logEvent(
      name: 'view_history',
      parameters: {
        'period': period,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );
  }

  // Track authentication events
  Future<void> logSignIn({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // Track app engagement
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  // Track feature usage
  Future<void> logFeatureUse({required String featureName}) async {
    await _analytics.logEvent(
      name: 'feature_use',
      parameters: {
        'feature_name': featureName,
      },
    );
  }

  // Track errors
  Future<void> logError({
    required String errorCode,
    required String message,
  }) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_code': errorCode,
        'error_message': message,
      },
    );
  }

  // Set user properties
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}
