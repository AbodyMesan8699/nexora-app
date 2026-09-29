import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NEXORA'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Connect. Share. Discover.'**
  String get tagline;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to log in'**
  String get backToLogin;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @checkEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkEmailTitle;

  /// No description provided for @checkEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We sent you a confirmation link. Verify your email to activate your account.'**
  String get checkEmailBody;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @whatsOnYourMind.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get whatsOnYourMind;

  /// No description provided for @addLocation.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get addLocation;

  /// No description provided for @addFeeling.
  ///
  /// In en, this message translates to:
  /// **'Add feeling / activity'**
  String get addFeeling;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @postCreated.
  ///
  /// In en, this message translates to:
  /// **'Post published'**
  String get postCreated;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get editPost;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get deletePost;

  /// No description provided for @deletePostConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this post permanently?'**
  String get deletePostConfirm;

  /// No description provided for @reportPost.
  ///
  /// In en, this message translates to:
  /// **'Report post'**
  String get reportPost;

  /// No description provided for @sharePost.
  ///
  /// In en, this message translates to:
  /// **'Share post'**
  String get sharePost;

  /// No description provided for @savePost.
  ///
  /// In en, this message translates to:
  /// **'Save post'**
  String get savePost;

  /// No description provided for @unsavePost.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get unsavePost;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment…'**
  String get writeComment;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first!'**
  String get noCommentsYet;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changeAvatar;

  /// No description provided for @changeCover.
  ///
  /// In en, this message translates to:
  /// **'Change cover'**
  String get changeCover;

  /// No description provided for @myPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get myPosts;

  /// No description provided for @savedPostsTab.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedPostsTab;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @friendRequest.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get friendRequest;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @removeFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get removeFriend;

  /// No description provided for @removeFriendConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this friend?'**
  String get removeFriendConfirm;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Friend requests'**
  String get requests;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests.'**
  String get noRequests;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search people, usernames and posts…'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @stories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get stories;

  /// No description provided for @addStory.
  ///
  /// In en, this message translates to:
  /// **'Add story'**
  String get addStory;

  /// No description provided for @storyTextHint.
  ///
  /// In en, this message translates to:
  /// **'Write your story…'**
  String get storyTextHint;

  /// No description provided for @storyViewers.
  ///
  /// In en, this message translates to:
  /// **'Story viewers'**
  String get storyViewers;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'views'**
  String get views;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @profileVisibility.
  ///
  /// In en, this message translates to:
  /// **'Profile visibility'**
  String get profileVisibility;

  /// No description provided for @whoCanFollow.
  ///
  /// In en, this message translates to:
  /// **'Who can follow me'**
  String get whoCanFollow;

  /// No description provided for @whoCanMessage.
  ///
  /// In en, this message translates to:
  /// **'Who can message me'**
  String get whoCanMessage;

  /// No description provided for @whoCanRequest.
  ///
  /// In en, this message translates to:
  /// **'Who can send friend requests'**
  String get whoCanRequest;

  /// No description provided for @showOnlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Show online status'**
  String get showOnlineStatus;

  /// No description provided for @visibilityEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get visibilityEveryone;

  /// No description provided for @visibilityFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get visibilityFollowers;

  /// No description provided for @visibilityFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get visibilityFriends;

  /// No description provided for @visibilityNobody.
  ///
  /// In en, this message translates to:
  /// **'Nobody'**
  String get visibilityNobody;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @blockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Block this user? They will not be able to interact with you.'**
  String get blockConfirm;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @reportAccount.
  ///
  /// In en, this message translates to:
  /// **'Report account'**
  String get reportAccount;

  /// No description provided for @reportReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reportReason;

  /// No description provided for @reasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reasonSpam;

  /// No description provided for @reasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get reasonHarassment;

  /// No description provided for @reasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reasonInappropriate;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @optionalDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get optionalDescription;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Report submitted. Thank you.'**
  String get reportSent;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get aboutApp;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'NEXORA overview, features, and vision'**
  String get aboutAppSubtitle;

  /// No description provided for @aboutIntro.
  ///
  /// In en, this message translates to:
  /// **'NEXORA is a modern social app designed to provide an easy, comfortable digital space to connect, share posts, discover content, and interact with others in one place.'**
  String get aboutIntro;

  /// No description provided for @aboutFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'✨ What NEXORA offers'**
  String get aboutFeaturesTitle;

  /// No description provided for @aboutFeatureProfile.
  ///
  /// In en, this message translates to:
  /// **'👤 Create and manage your profile.'**
  String get aboutFeatureProfile;

  /// No description provided for @aboutFeaturePosts.
  ///
  /// In en, this message translates to:
  /// **'📝 Publish posts and share content.'**
  String get aboutFeaturePosts;

  /// No description provided for @aboutFeatureLikes.
  ///
  /// In en, this message translates to:
  /// **'❤️ Interact with posts and like them.'**
  String get aboutFeatureLikes;

  /// No description provided for @aboutFeatureComments.
  ///
  /// In en, this message translates to:
  /// **'💬 Comment, reply, and interact with users.'**
  String get aboutFeatureComments;

  /// No description provided for @aboutFeatureFriends.
  ///
  /// In en, this message translates to:
  /// **'👥 Follow friends and stay connected.'**
  String get aboutFeatureFriends;

  /// No description provided for @aboutFeatureSearch.
  ///
  /// In en, this message translates to:
  /// **'🔎 Search for users and discover accounts.'**
  String get aboutFeatureSearch;

  /// No description provided for @aboutFeatureNotifications.
  ///
  /// In en, this message translates to:
  /// **'🔔 Get notifications about interactions and activity.'**
  String get aboutFeatureNotifications;

  /// No description provided for @aboutFeatureSecurity.
  ///
  /// In en, this message translates to:
  /// **'🔒 Account and content protections with access controls.'**
  String get aboutFeatureSecurity;

  /// No description provided for @aboutFeatureSettings.
  ///
  /// In en, this message translates to:
  /// **'⚙️ Advanced account and privacy settings.'**
  String get aboutFeatureSettings;

  /// No description provided for @aboutVisionTitle.
  ///
  /// In en, this message translates to:
  /// **'🎯 Our vision'**
  String get aboutVisionTitle;

  /// No description provided for @aboutVisionBody.
  ///
  /// In en, this message translates to:
  /// **'At NEXORA, we aim to offer a simple, modern social experience that brings communication, content, and interaction together in one platform, with a focus on ease of use, security, and reliability.'**
  String get aboutVisionBody;

  /// No description provided for @aboutDevelopmentTitle.
  ///
  /// In en, this message translates to:
  /// **'👨‍💻 Development'**
  String get aboutDevelopmentTitle;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developed and supervised by: Al-Haqli Itqan'**
  String get aboutDeveloper;

  /// No description provided for @aboutFounder.
  ///
  /// In en, this message translates to:
  /// **'Platform founder: Prof. Abdulrahman Al-Haqli'**
  String get aboutFounder;

  /// No description provided for @aboutVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'📱 Version'**
  String get aboutVersionTitle;

  /// No description provided for @aboutCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version: {version}'**
  String aboutCurrentVersion(String version);

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© All rights reserved — NEXORA | Al-Haqli Itqan'**
  String get aboutCopyright;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get adminPanel;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total users'**
  String get totalUsers;

  /// No description provided for @activeUsers.
  ///
  /// In en, this message translates to:
  /// **'Active users'**
  String get activeUsers;

  /// No description provided for @totalPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get totalPosts;

  /// No description provided for @totalComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get totalComments;

  /// No description provided for @pendingReports.
  ///
  /// In en, this message translates to:
  /// **'Pending reports'**
  String get pendingReports;

  /// No description provided for @suspendedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Suspended accounts'**
  String get suspendedAccounts;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage objects'**
  String get storageUsed;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @reviewReport.
  ///
  /// In en, this message translates to:
  /// **'Mark reviewed'**
  String get reviewReport;

  /// No description provided for @dismissReport.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissReport;

  /// No description provided for @suspendAccount.
  ///
  /// In en, this message translates to:
  /// **'Suspend account'**
  String get suspendAccount;

  /// No description provided for @restoreAccount.
  ///
  /// In en, this message translates to:
  /// **'Restore account'**
  String get restoreAccount;

  /// No description provided for @reviewedReports.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewedReports;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorAuth.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get errorAuth;

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Changes will not sync until you reconnect.'**
  String get errorOffline;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeMessage;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @deleteMessageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this message?'**
  String get deleteMessageConfirm;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notificationsEmpty;

  /// No description provided for @feedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your feed is empty. Follow people to see their posts!'**
  String get feedEmpty;

  /// No description provided for @newFollower.
  ///
  /// In en, this message translates to:
  /// **'started following you'**
  String get newFollower;

  /// No description provided for @acceptedYourRequest.
  ///
  /// In en, this message translates to:
  /// **'accepted your friend request'**
  String get acceptedYourRequest;

  /// No description provided for @likedYourPost.
  ///
  /// In en, this message translates to:
  /// **'liked your post'**
  String get likedYourPost;

  /// No description provided for @commentedOnYourPost.
  ///
  /// In en, this message translates to:
  /// **'commented on your post'**
  String get commentedOnYourPost;

  /// No description provided for @repliedToYourComment.
  ///
  /// In en, this message translates to:
  /// **'replied to your comment'**
  String get repliedToYourComment;

  /// No description provided for @sharedYourPost.
  ///
  /// In en, this message translates to:
  /// **'shared your post'**
  String get sharedYourPost;

  /// No description provided for @sentYouMessage.
  ///
  /// In en, this message translates to:
  /// **'sent you a message'**
  String get sentYouMessage;

  /// No description provided for @viewedYourStory.
  ///
  /// In en, this message translates to:
  /// **'viewed your story'**
  String get viewedYourStory;

  /// No description provided for @sentYouFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'sent you a friend request'**
  String get sentYouFriendRequest;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}m ago'**
  String minutesAgo(int n);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String hoursAgo(int n);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}d ago'**
  String daysAgo(int n);

  /// No description provided for @configNeeded.
  ///
  /// In en, this message translates to:
  /// **'Configuration required'**
  String get configNeeded;

  /// No description provided for @configNeededBody.
  ///
  /// In en, this message translates to:
  /// **'This build was compiled without Supabase credentials. Rebuild the app passing SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define. See SETUP.md in the project root.'**
  String get configNeededBody;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new update is available'**
  String get updateAvailable;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'NEXORA version {version} is ready. Update now to get the latest improvements.'**
  String updateAvailableBody(String version);

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateChooseMethod.
  ///
  /// In en, this message translates to:
  /// **'How would you like to update?'**
  String get updateChooseMethod;

  /// No description provided for @updateInApp.
  ///
  /// In en, this message translates to:
  /// **'Update inside the app'**
  String get updateInApp;

  /// No description provided for @updateInAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download the file and open Android\'s installer'**
  String get updateInAppSubtitle;

  /// No description provided for @updateInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Update in a browser'**
  String get updateInBrowser;

  /// No description provided for @updateInBrowserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open the release page in an external browser'**
  String get updateInBrowserSubtitle;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading the NEXORA update…'**
  String get updateDownloading;

  /// No description provided for @updateInstallPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow update installation'**
  String get updateInstallPermissionTitle;

  /// No description provided for @updateInstallPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow NEXORA to install apps in Android settings, then return and tap Continue installation. Android will ask you to confirm the final install.'**
  String get updateInstallPermissionBody;

  /// No description provided for @updateContinueInstall.
  ///
  /// In en, this message translates to:
  /// **'Continue installation'**
  String get updateContinueInstall;

  /// No description provided for @updateErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the update'**
  String get updateErrorTitle;

  /// No description provided for @updateDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'The update could not be downloaded or verified. Try again or use the browser option.'**
  String get updateDownloadFailed;

  /// No description provided for @updateLatest.
  ///
  /// In en, this message translates to:
  /// **'You are using the latest available version.'**
  String get updateLatest;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manually check for the latest app version'**
  String get checkForUpdatesSubtitle;

  /// No description provided for @updateRepositoryNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Update checks will be enabled after the GitHub repository is configured at build time.'**
  String get updateRepositoryNotConfigured;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check for updates. Check your internet connection and try again.'**
  String get updateCheckFailed;
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
      <String>['ar', 'en'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
