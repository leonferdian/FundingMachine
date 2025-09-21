/// A class that holds all the string constants used in the app
class Strings {
  // App info
  static const String appName = 'Funding Machine';
  static const String appVersion = '1.0.0';
  
  // Common
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String retry = 'Retry';
  static const String close = 'Close';
  static const String save = 'Save';
  static const String submit = 'Submit';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  
  // Authentication
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String createAccount = 'Create Account';
  
  // Validation messages
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDontMatch = 'Passwords do not match';
  
  // Errors
  static const String somethingWentWrong = 'Something went wrong';
  static const String noInternetConnection = 'No internet connection';
  static const String connectionTimeout = 'Connection timeout';
  static const String unauthorized = 'Unauthorized access';
  static const String serverError = 'Server error occurred';
  
  // Success messages
  static const String loginSuccess = 'Login successful';
  static const String registrationSuccess = 'Registration successful';
  static const String passwordResetSent = 'Password reset email sent';
  
  // Navigation
  static const String home = 'Home';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String notifications = 'Notifications';
  
  // Settings
  static const String darkMode = 'Dark Mode';
  static const String notificationsSettings = 'Notifications';
  static const String language = 'Language';
  static const String help = 'Help & Support';
  static const String about = 'About';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';
  
  // About
  static const String aboutApp = 'About $appName';
  static const String version = 'Version $appVersion';
  static const String copyright = '© 2025 Funding Machine. All rights reserved.';
  
  // Empty states
  static const String noDataAvailable = 'No data available';
  static const String noInternet = 'No internet connection';
  static const String tryAgain = 'Please check your connection and try again';
  
  // Buttons
  static const String tryAgainBtn = 'Try Again';
  static const String refresh = 'Refresh';
  static const String backToHome = 'Back to Home';
  
  // Placeholders
  static const String search = 'Search...';
  static const String typeMessage = 'Type a message...';
  
  // Time
  static const String justNow = 'Just now';
  static const String minutesAgo = 'm ago';
  static const String hoursAgo = 'h ago';
  static const String daysAgo = 'd ago';
  
  // Format strings
  static String formatMinutesAgo(int minutes) => '$minutes${Strings.minutesAgo}';
  static String formatHoursAgo(int hours) => '$hours${Strings.hoursAgo}';
  static String formatDaysAgo(int days) => '$days${Strings.daysAgo}';
}
