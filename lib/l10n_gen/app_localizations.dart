// GENERATED from lib/l10n/app_en.arb and app_ar.arb — do not edit by hand.
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('ar')];
  static const localizationsDelegates = _NexLocDelegates.all;

  static AppLocalizations of(BuildContext context) =>
      AppLocalizations(Localizations.localeOf(context));

  static bool isRtl(Locale l) => l.languageCode == 'ar';

  static const _en = {
    'appTitle': 'NEXORA',
    'tagline': 'Connect. Share. Discover.',
    'login': 'Log in',
    'register': 'Sign up',
    'logout': 'Log out',
    'email': 'Email',
    'password': 'Password',
    'firstName': 'First name',
    'lastName': 'Last name',
    'username': 'Username',
    'forgotPassword': 'Forgot password?',
    'resetPassword': 'Reset password',
    'sendResetLink': 'Send reset link',
    'backToLogin': 'Back to log in',
    'createAccount': 'Create your account',
    'haveAccount': 'Already have an account?',
    'noAccount': 'Don\'t have an account?',
    'checkEmailTitle': 'Check your email',
    'checkEmailBody':
        'We sent you a confirmation link. Verify your email to activate your account.',
    'home': 'Home',
    'discover': 'Discover',
    'create': 'Create',
    'notifications': 'Notifications',
    'messages': 'Messages',
    'profile': 'Profile',
    'whatsOnYourMind': 'What\'s on your mind?',
    'addLocation': 'Add location',
    'addFeeling': 'Add feeling / activity',
    'publish': 'Publish',
    'postCreated': 'Post published',
    'editPost': 'Edit post',
    'deletePost': 'Delete post',
    'deletePostConfirm': 'Delete this post permanently?',
    'reportPost': 'Report post',
    'sharePost': 'Share post',
    'savePost': 'Save post',
    'unsavePost': 'Remove from saved',
    'like': 'Like',
    'comment': 'Comment',
    'share': 'Share',
    'save': 'Save',
    'edit': 'Edit',
    'delete': 'Delete',
    'report': 'Report',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'ok': 'OK',
    'retry': 'Retry',
    'comments': 'Comments',
    'writeComment': 'Write a comment…',
    'reply': 'Reply',
    'noCommentsYet': 'No comments yet. Be the first!',
    'followers': 'Followers',
    'following': 'Following',
    'friends': 'Friends',
    'posts': 'Posts',
    'media': 'Media',
    'editProfile': 'Edit profile',
    'bio': 'Bio',
    'saveChanges': 'Save changes',
    'changeAvatar': 'Change photo',
    'changeCover': 'Change cover',
    'myPosts': 'Posts',
    'savedPostsTab': 'Saved',
    'follow': 'Follow',
    'unfollow': 'Unfollow',
    'friendRequest': 'Add friend',
    'accept': 'Accept',
    'reject': 'Reject',
    'removeFriend': 'Remove friend',
    'removeFriendConfirm': 'Remove this friend?',
    'requests': 'Friend requests',
    'noRequests': 'No pending requests.',
    'search': 'Search',
    'searchHint': 'Search people, usernames and posts…',
    'noResults': 'No results found',
    'people': 'People',
    'stories': 'Stories',
    'addStory': 'Add story',
    'storyTextHint': 'Write your story…',
    'storyViewers': 'Story viewers',
    'views': 'views',
    'settings': 'Settings',
    'privacy': 'Privacy',
    'profileVisibility': 'Profile visibility',
    'whoCanFollow': 'Who can follow me',
    'whoCanMessage': 'Who can message me',
    'whoCanRequest': 'Who can send friend requests',
    'showOnlineStatus': 'Show online status',
    'visibilityEveryone': 'Everyone',
    'visibilityFollowers': 'Followers',
    'visibilityFriends': 'Friends',
    'visibilityNobody': 'Nobody',
    'language': 'Language',
    'arabic': 'العربية',
    'english': 'English',
    'block': 'Block',
    'blocked': 'Blocked',
    'blockConfirm':
        'Block this user? They will not be able to interact with you.',
    'unblock': 'Unblock',
    'reportAccount': 'Report account',
    'reportReason': 'Reason',
    'reasonSpam': 'Spam',
    'reasonHarassment': 'Harassment',
    'reasonInappropriate': 'Inappropriate content',
    'reasonOther': 'Other',
    'optionalDescription': 'Description (optional)',
    'reportSent': 'Report submitted. Thank you.',
    'aboutApp': 'About the app',
    'aboutAppSubtitle': 'NEXORA overview, features, and vision',
    'aboutIntro':
        'NEXORA is a modern social app designed to provide an easy, comfortable digital space to connect, share posts, discover content, and interact with others in one place.',
    'aboutFeaturesTitle': '✨ What NEXORA offers',
    'aboutFeatureProfile': '👤 Create and manage your profile.',
    'aboutFeaturePosts': '📝 Publish posts and share content.',
    'aboutFeatureLikes': '❤️ Interact with posts and like them.',
    'aboutFeatureComments': '💬 Comment, reply, and interact with users.',
    'aboutFeatureFriends': '👥 Follow friends and stay connected.',
    'aboutFeatureSearch': '🔎 Search for users and discover accounts.',
    'aboutFeatureNotifications':
        '🔔 Get notifications about interactions and activity.',
    'aboutFeatureSecurity':
        '🔒 Account and content protections with access controls.',
    'aboutFeatureSettings': '⚙️ Advanced account and privacy settings.',
    'aboutVisionTitle': '🎯 Our vision',
    'aboutVisionBody':
        'At NEXORA, we aim to offer a simple, modern social experience that brings communication, content, and interaction together in one platform, with a focus on ease of use, security, and reliability.',
    'aboutDevelopmentTitle': '👨‍💻 Development',
    'aboutDeveloper': 'Developed and supervised by: Al-Haqli Itqan',
    'aboutFounder': 'Platform founder: Prof. Abdulrahman Al-Haqli',
    'aboutVersionTitle': '📱 Version',
    'aboutCurrentVersion': 'Current version: {version}',
    'aboutCopyright': '© All rights reserved — NEXORA | Al-Haqli Itqan',
    'adminPanel': 'Admin panel',
    'totalUsers': 'Total users',
    'activeUsers': 'Active users',
    'totalPosts': 'Posts',
    'totalComments': 'Comments',
    'pendingReports': 'Pending reports',
    'suspendedAccounts': 'Suspended accounts',
    'storageUsed': 'Storage objects',
    'recentActivity': 'Recent activity',
    'reviewReport': 'Mark reviewed',
    'dismissReport': 'Dismiss',
    'suspendAccount': 'Suspend account',
    'restoreAccount': 'Restore account',
    'reviewedReports': 'Reviewed',
    'errorGeneric': 'Something went wrong. Please try again.',
    'errorNetwork': 'Network error. Check your connection and try again.',
    'errorAuth': 'Invalid email or password.',
    'errorOffline':
        'You are offline. Changes will not sync until you reconnect.',
    'typeMessage': 'Type a message…',
    'online': 'Online',
    'edited': 'Edited',
    'deleteMessageConfirm': 'Delete this message?',
    'notificationsEmpty': 'No notifications yet.',
    'feedEmpty': 'Your feed is empty. Follow people to see their posts!',
    'newFollower': 'started following you',
    'acceptedYourRequest': 'accepted your friend request',
    'likedYourPost': 'liked your post',
    'commentedOnYourPost': 'commented on your post',
    'repliedToYourComment': 'replied to your comment',
    'sharedYourPost': 'shared your post',
    'sentYouMessage': 'sent you a message',
    'viewedYourStory': 'viewed your story',
    'sentYouFriendRequest': 'sent you a friend request',
    'justNow': 'just now',
    'minutesAgo': '{n}m ago',
    'hoursAgo': '{n}h ago',
    'daysAgo': '{n}d ago',
    'configNeeded': 'Configuration required',
    'configNeededBody':
        'This build was compiled without Supabase credentials. Rebuild the app passing SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define. See SETUP.md in the project root.',
    'updateAvailable': 'A new update is available',
    'updateAvailableBody':
        'NEXORA version {version} is ready. Update now to get the latest improvements.',
    'updateNow': 'Update',
    'updateLater': 'Later',
    'updateChooseMethod': 'How would you like to update?',
    'updateInApp': 'Update inside the app',
    'updateInAppSubtitle': 'Download the file and open Android\'s installer',
    'updateInBrowser': 'Update in a browser',
    'updateInBrowserSubtitle': 'Open the release page in an external browser',
    'updateDownloading': 'Downloading the NEXORA update…',
    'updateInstallPermissionTitle': 'Allow update installation',
    'updateInstallPermissionBody':
        'Allow NEXORA to install apps in Android settings, then return and tap Continue installation. Android will ask you to confirm the final install.',
    'updateContinueInstall': 'Continue installation',
    'updateErrorTitle': 'Could not complete the update',
    'updateDownloadFailed':
        'The update could not be downloaded or verified. Try again or use the browser option.',
    'updateLatest': 'You are using the latest available version.',
    'checkForUpdates': 'Check for updates',
    'checkForUpdatesSubtitle': 'Manually check for the latest app version',
    'updateRepositoryNotConfigured':
        'Update checks will be enabled after the GitHub repository is configured at build time.',
    'updateCheckFailed':
        'Could not check for updates. Check your internet connection and try again.',
  };
  static const _ar = {
    'appTitle': 'نيكسورا',
    'tagline': 'تواصل. شارك. اكتشف.',
    'login': 'تسجيل الدخول',
    'register': 'إنشاء حساب',
    'logout': 'تسجيل الخروج',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'firstName': 'الاسم الأول',
    'lastName': 'اسم العائلة',
    'username': 'اسم المستخدم',
    'forgotPassword': 'نسيت كلمة المرور؟',
    'resetPassword': 'إعادة تعيين كلمة المرور',
    'sendResetLink': 'إرسال رابط الاستعادة',
    'backToLogin': 'العودة لتسجيل الدخول',
    'createAccount': 'أنشئ حسابك',
    'haveAccount': 'لديك حساب بالفعل؟',
    'noAccount': 'ليس لديك حساب؟',
    'checkEmailTitle': 'تحقق من بريدك الإلكتروني',
    'checkEmailBody':
        'أرسلنا لك رابط تأكيد. فعّل بريدك الإلكتروني لتفعيل حسابك.',
    'home': 'الرئيسية',
    'discover': 'استكشف',
    'create': 'إنشاء',
    'notifications': 'الإشعارات',
    'messages': 'الرسائل',
    'profile': 'الملف الشخصي',
    'whatsOnYourMind': 'بماذا تفكر؟',
    'addLocation': 'إضافة موقع',
    'addFeeling': 'إضافة شعور / نشاط',
    'publish': 'نشر',
    'postCreated': 'تم نشر المنشور',
    'editPost': 'تعديل المنشور',
    'deletePost': 'حذف المنشور',
    'deletePostConfirm': 'حذف هذا المنشور نهائيًا؟',
    'reportPost': 'الإبلاغ عن المنشور',
    'sharePost': 'مشاركة المنشور',
    'savePost': 'حفظ المنشور',
    'unsavePost': 'إزالة من المحفوظات',
    'like': 'إعجاب',
    'comment': 'تعليق',
    'share': 'مشاركة',
    'save': 'حفظ',
    'edit': 'تعديل',
    'delete': 'حذف',
    'report': 'إبلاغ',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'ok': 'حسنًا',
    'retry': 'إعادة المحاولة',
    'comments': 'التعليقات',
    'writeComment': 'اكتب تعليقًا…',
    'reply': 'رد',
    'noCommentsYet': 'لا توجد تعليقات بعد. كن الأول!',
    'followers': 'المتابعون',
    'following': 'أتابعهم',
    'friends': 'الأصدقاء',
    'posts': 'المنشورات',
    'media': 'الوسائط',
    'editProfile': 'تعديل الملف الشخصي',
    'bio': 'نبذة',
    'saveChanges': 'حفظ التغييرات',
    'changeAvatar': 'تغيير الصورة',
    'changeCover': 'تغيير الغلاف',
    'myPosts': 'المنشورات',
    'savedPostsTab': 'المحفوظات',
    'follow': 'متابعة',
    'unfollow': 'إلغاء المتابعة',
    'friendRequest': 'إضافة صديق',
    'accept': 'قبول',
    'reject': 'رفض',
    'removeFriend': 'إزالة صديق',
    'removeFriendConfirm': 'إزالة هذا الصديق؟',
    'requests': 'طلبات الصداقة',
    'noRequests': 'لا توجد طلبات معلقة.',
    'search': 'بحث',
    'searchHint': 'ابحث عن أشخاص أو أسماء مستخدمة أو منشورات…',
    'noResults': 'لا توجد نتائج',
    'people': 'الأشخاص',
    'stories': 'القصص',
    'addStory': 'إضافة قصة',
    'storyTextHint': 'اكتب قصتك…',
    'storyViewers': 'مشاهدو القصة',
    'views': 'مشاهدات',
    'settings': 'الإعدادات',
    'privacy': 'الخصوصية',
    'profileVisibility': 'ظهور الملف الشخصي',
    'whoCanFollow': 'من يمكنه متابعتي',
    'whoCanMessage': 'من يمكنه مراسلتي',
    'whoCanRequest': 'من يمكنه إرسال طلب صداقة',
    'showOnlineStatus': 'إظهار حالة الاتصال',
    'visibilityEveryone': 'الجميع',
    'visibilityFollowers': 'المتابعون',
    'visibilityFriends': 'الأصدقاء',
    'visibilityNobody': 'لا أحد',
    'language': 'اللغة',
    'arabic': 'العربية',
    'english': 'English',
    'block': 'حظر',
    'blocked': 'محظور',
    'blockConfirm': 'حظر هذا المستخدم؟ لن يتمكن من التفاعل معك.',
    'unblock': 'إلغاء الحظر',
    'reportAccount': 'الإبلاغ عن الحساب',
    'reportReason': 'السبب',
    'reasonSpam': 'محتوى مزعج',
    'reasonHarassment': 'تحرش',
    'reasonInappropriate': 'محتوى غير لائق',
    'reasonOther': 'أخرى',
    'optionalDescription': 'وصف (اختياري)',
    'reportSent': 'تم إرسال البلاغ. شكرًا لك.',
    'aboutApp': 'معلومات التطبيق',
    'aboutAppSubtitle': 'نبذة عن NEXORA ومميزاته ورؤيته',
    'aboutIntro':
        'NEXORA هو تطبيق اجتماعي حديث يهدف إلى توفير مساحة رقمية سهلة ومريحة للتواصل، مشاركة المنشورات، اكتشاف المحتوى، والتفاعل مع الآخرين في مكان واحد.',
    'aboutFeaturesTitle': '✨ ماذا يقدم NEXORA؟',
    'aboutFeatureProfile': '👤 إنشاء وإدارة الملف الشخصي.',
    'aboutFeaturePosts': '📝 نشر المنشورات ومشاركة المحتوى.',
    'aboutFeatureLikes': '❤️ التفاعل مع المنشورات والإعجاب بها.',
    'aboutFeatureComments': '💬 التعليقات والردود والتفاعل مع المستخدمين.',
    'aboutFeatureFriends': '👥 متابعة الأصدقاء والتواصل معهم.',
    'aboutFeatureSearch': '🔎 البحث عن المستخدمين واكتشاف الحسابات.',
    'aboutFeatureNotifications': '🔔 الإشعارات لمتابعة التفاعلات والأنشطة.',
    'aboutFeatureSecurity':
        '🔒 أنظمة حماية وصلاحيات للحفاظ على أمان الحسابات والمحتوى.',
    'aboutFeatureSettings': '⚙️ إعدادات متقدمة لإدارة الحساب والخصوصية.',
    'aboutVisionTitle': '🎯 رؤيتنا',
    'aboutVisionBody':
        'نسعى في NEXORA إلى تقديم تجربة اجتماعية بسيطة وحديثة تجمع التواصل والمحتوى والتفاعل في منصة واحدة، مع الاهتمام بسهولة الاستخدام والأمان واستقرار التطبيق.',
    'aboutDevelopmentTitle': '👨‍💻 تطوير التطبيق',
    'aboutDeveloper': 'تطوير وإشراف: الحقلي إتقان',
    'aboutFounder': 'مؤسس المنصة: الأستاذ عبدالرحمن الحقلي',
    'aboutVersionTitle': '📱 الإصدار',
    'aboutCurrentVersion': 'الإصدار الحالي: {version}',
    'aboutCopyright': '© جميع الحقوق محفوظة — NEXORA | الحقلي إتقان',
    'adminPanel': 'لوحة الإدارة',
    'totalUsers': 'إجمالي المستخدمين',
    'activeUsers': 'المستخدمون النشطون',
    'totalPosts': 'المنشورات',
    'totalComments': 'التعليقات',
    'pendingReports': 'البلاغات المعلقة',
    'suspendedAccounts': 'الحسابات الموقوفة',
    'storageUsed': 'كائنات التخزين',
    'recentActivity': 'النشاط الأخير',
    'reviewReport': 'تمييز كمراجَع',
    'dismissReport': 'تجاهل',
    'suspendAccount': 'إيقاف الحساب',
    'restoreAccount': 'استعادة الحساب',
    'reviewedReports': 'المراجَعة',
    'errorGeneric': 'حدث خطأ، حاول مرة أخرى.',
    'errorNetwork': 'خطأ في الشبكة. تحقق من اتصالك وحاول مرة أخرى.',
    'errorAuth': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
    'errorOffline': 'أنت غير متصل. لن تتم مزامنة التغييرات حتى عودة الاتصال.',
    'typeMessage': 'اكتب رسالة…',
    'online': 'متصل',
    'edited': 'معدّلة',
    'deleteMessageConfirm': 'حذف هذه الرسالة؟',
    'notificationsEmpty': 'لا توجد إشعارات بعد.',
    'feedEmpty': 'خلاصتك فارغة. تابع أشخاصًا لرؤية منشوراتهم!',
    'newFollower': 'بدأ بمتابعتك',
    'acceptedYourRequest': 'قبل طلب صداقتك',
    'likedYourPost': 'أعجب بمنشورك',
    'commentedOnYourPost': 'علّق على منشورك',
    'repliedToYourComment': 'رد على تعليقك',
    'sharedYourPost': 'شارك منشورك',
    'sentYouMessage': 'أرسل إليك رسالة',
    'viewedYourStory': 'شاهد قصتك',
    'sentYouFriendRequest': 'أرسل إليك طلب صداقة',
    'justNow': 'الآن',
    'minutesAgo': 'قبل {n} د',
    'hoursAgo': 'قبل {n} س',
    'daysAgo': 'قبل {n} يوم',
    'configNeeded': 'مطلوب إعداد',
    'configNeededBody':
        'لم يُبنَ هذا التطبيق مع بيانات Supabase. أعد البناء بتمرير SUPABASE_URL و SUPABASE_ANON_KEY عبر --dart-define. راجع ملف SETUP.md في جذر المشروع.',
    'updateAvailable': 'يتوفر تحديث جديد',
    'updateAvailableBody':
        'أصبح الإصدار {version} من NEXORA متاحًا. حدّث الآن للاستفادة من التحسينات الجديدة.',
    'updateNow': 'تحديث',
    'updateLater': 'لاحقًا',
    'updateChooseMethod': 'كيف تفضّل التحديث؟',
    'updateInApp': 'التحديث داخل التطبيق',
    'updateInAppSubtitle': 'تنزيل الملف وفتحه في مثبت Android',
    'updateInBrowser': 'التحديث عبر المتصفح',
    'updateInBrowserSubtitle': 'فتح صفحة الإصدار في متصفح خارجي',
    'updateDownloading': 'جارٍ تنزيل تحديث NEXORA…',
    'updateInstallPermissionTitle': 'السماح بتثبيت التحديث',
    'updateInstallPermissionBody':
        'اسمح لـ NEXORA بتثبيت التطبيقات من إعدادات Android، ثم عُد واضغط «متابعة التثبيت». سيطلب Android تأكيد التثبيت النهائي.',
    'updateContinueInstall': 'متابعة التثبيت',
    'updateErrorTitle': 'تعذر إكمال التحديث',
    'updateDownloadFailed':
        'تعذر تنزيل ملف التحديث أو التحقق من سلامته. حاول مرة أخرى أو استخدم المتصفح.',
    'updateLatest': 'أنت تستخدم أحدث إصدار متاح.',
    'checkForUpdates': 'التحقق من وجود تحديث',
    'checkForUpdatesSubtitle': 'تحقق يدويًا من أحدث إصدار للتطبيق',
    'updateRepositoryNotConfigured':
        'سيُفعّل فحص التحديثات بعد ربط مستودع GitHub عند البناء.',
    'updateCheckFailed':
        'تعذر التحقق من التحديث. تحقق من اتصال الإنترنت وحاول مرة أخرى.',
  };

  String _t(String key, [Map<String, Object>? args]) {
    var s = (locale.languageCode == 'ar' ? _ar : _en)[key] ?? _en[key] ?? key;
    if (args != null) {
      args.forEach((k, v) {
        s = s.replaceAll(
          '{' + k + '}',
          v is num ? NumberFormat.decimalPattern().format(v) : v.toString(),
        );
      });
    }
    return s;
  }

  String get appTitle => _t('appTitle');
  String get tagline => _t('tagline');
  String get login => _t('login');
  String get register => _t('register');
  String get logout => _t('logout');
  String get email => _t('email');
  String get password => _t('password');
  String get firstName => _t('firstName');
  String get lastName => _t('lastName');
  String get username => _t('username');
  String get forgotPassword => _t('forgotPassword');
  String get resetPassword => _t('resetPassword');
  String get sendResetLink => _t('sendResetLink');
  String get backToLogin => _t('backToLogin');
  String get createAccount => _t('createAccount');
  String get haveAccount => _t('haveAccount');
  String get noAccount => _t('noAccount');
  String get checkEmailTitle => _t('checkEmailTitle');
  String get checkEmailBody => _t('checkEmailBody');
  String get home => _t('home');
  String get discover => _t('discover');
  String get create => _t('create');
  String get notifications => _t('notifications');
  String get messages => _t('messages');
  String get profile => _t('profile');
  String get whatsOnYourMind => _t('whatsOnYourMind');
  String get addLocation => _t('addLocation');
  String get addFeeling => _t('addFeeling');
  String get publish => _t('publish');
  String get postCreated => _t('postCreated');
  String get editPost => _t('editPost');
  String get deletePost => _t('deletePost');
  String get deletePostConfirm => _t('deletePostConfirm');
  String get reportPost => _t('reportPost');
  String get sharePost => _t('sharePost');
  String get savePost => _t('savePost');
  String get unsavePost => _t('unsavePost');
  String get like => _t('like');
  String get comment => _t('comment');
  String get share => _t('share');
  String get save => _t('save');
  String get edit => _t('edit');
  String get delete => _t('delete');
  String get report => _t('report');
  String get cancel => _t('cancel');
  String get confirm => _t('confirm');
  String get ok => _t('ok');
  String get retry => _t('retry');
  String get comments => _t('comments');
  String get writeComment => _t('writeComment');
  String get reply => _t('reply');
  String get noCommentsYet => _t('noCommentsYet');
  String get followers => _t('followers');
  String get following => _t('following');
  String get friends => _t('friends');
  String get posts => _t('posts');
  String get media => _t('media');
  String get editProfile => _t('editProfile');
  String get bio => _t('bio');
  String get saveChanges => _t('saveChanges');
  String get changeAvatar => _t('changeAvatar');
  String get changeCover => _t('changeCover');
  String get myPosts => _t('myPosts');
  String get savedPostsTab => _t('savedPostsTab');
  String get follow => _t('follow');
  String get unfollow => _t('unfollow');
  String get friendRequest => _t('friendRequest');
  String get accept => _t('accept');
  String get reject => _t('reject');
  String get removeFriend => _t('removeFriend');
  String get removeFriendConfirm => _t('removeFriendConfirm');
  String get requests => _t('requests');
  String get noRequests => _t('noRequests');
  String get search => _t('search');
  String get searchHint => _t('searchHint');
  String get noResults => _t('noResults');
  String get people => _t('people');
  String get stories => _t('stories');
  String get addStory => _t('addStory');
  String get storyTextHint => _t('storyTextHint');
  String get storyViewers => _t('storyViewers');
  String get views => _t('views');
  String get settings => _t('settings');
  String get privacy => _t('privacy');
  String get profileVisibility => _t('profileVisibility');
  String get whoCanFollow => _t('whoCanFollow');
  String get whoCanMessage => _t('whoCanMessage');
  String get whoCanRequest => _t('whoCanRequest');
  String get showOnlineStatus => _t('showOnlineStatus');
  String get visibilityEveryone => _t('visibilityEveryone');
  String get visibilityFollowers => _t('visibilityFollowers');
  String get visibilityFriends => _t('visibilityFriends');
  String get visibilityNobody => _t('visibilityNobody');
  String get language => _t('language');
  String get arabic => _t('arabic');
  String get english => _t('english');
  String get block => _t('block');
  String get blocked => _t('blocked');
  String get blockConfirm => _t('blockConfirm');
  String get unblock => _t('unblock');
  String get reportAccount => _t('reportAccount');
  String get reportReason => _t('reportReason');
  String get reasonSpam => _t('reasonSpam');
  String get reasonHarassment => _t('reasonHarassment');
  String get reasonInappropriate => _t('reasonInappropriate');
  String get reasonOther => _t('reasonOther');
  String get optionalDescription => _t('optionalDescription');
  String get reportSent => _t('reportSent');
  String get aboutApp => _t('aboutApp');
  String get aboutAppSubtitle => _t('aboutAppSubtitle');
  String get aboutIntro => _t('aboutIntro');
  String get aboutFeaturesTitle => _t('aboutFeaturesTitle');
  String get aboutFeatureProfile => _t('aboutFeatureProfile');
  String get aboutFeaturePosts => _t('aboutFeaturePosts');
  String get aboutFeatureLikes => _t('aboutFeatureLikes');
  String get aboutFeatureComments => _t('aboutFeatureComments');
  String get aboutFeatureFriends => _t('aboutFeatureFriends');
  String get aboutFeatureSearch => _t('aboutFeatureSearch');
  String get aboutFeatureNotifications => _t('aboutFeatureNotifications');
  String get aboutFeatureSecurity => _t('aboutFeatureSecurity');
  String get aboutFeatureSettings => _t('aboutFeatureSettings');
  String get aboutVisionTitle => _t('aboutVisionTitle');
  String get aboutVisionBody => _t('aboutVisionBody');
  String get aboutDevelopmentTitle => _t('aboutDevelopmentTitle');
  String get aboutDeveloper => _t('aboutDeveloper');
  String get aboutFounder => _t('aboutFounder');
  String get aboutVersionTitle => _t('aboutVersionTitle');
  String aboutCurrentVersion(String version) =>
      _t('aboutCurrentVersion', {'version': version});
  String get aboutCopyright => _t('aboutCopyright');
  String get adminPanel => _t('adminPanel');
  String get totalUsers => _t('totalUsers');
  String get activeUsers => _t('activeUsers');
  String get totalPosts => _t('totalPosts');
  String get totalComments => _t('totalComments');
  String get pendingReports => _t('pendingReports');
  String get suspendedAccounts => _t('suspendedAccounts');
  String get storageUsed => _t('storageUsed');
  String get recentActivity => _t('recentActivity');
  String get reviewReport => _t('reviewReport');
  String get dismissReport => _t('dismissReport');
  String get suspendAccount => _t('suspendAccount');
  String get restoreAccount => _t('restoreAccount');
  String get reviewedReports => _t('reviewedReports');
  String get errorGeneric => _t('errorGeneric');
  String get errorNetwork => _t('errorNetwork');
  String get errorAuth => _t('errorAuth');
  String get errorOffline => _t('errorOffline');
  String get typeMessage => _t('typeMessage');
  String get online => _t('online');
  String get edited => _t('edited');
  String get deleteMessageConfirm => _t('deleteMessageConfirm');
  String get notificationsEmpty => _t('notificationsEmpty');
  String get feedEmpty => _t('feedEmpty');
  String get newFollower => _t('newFollower');
  String get acceptedYourRequest => _t('acceptedYourRequest');
  String get likedYourPost => _t('likedYourPost');
  String get commentedOnYourPost => _t('commentedOnYourPost');
  String get repliedToYourComment => _t('repliedToYourComment');
  String get sharedYourPost => _t('sharedYourPost');
  String get sentYouMessage => _t('sentYouMessage');
  String get viewedYourStory => _t('viewedYourStory');
  String get sentYouFriendRequest => _t('sentYouFriendRequest');
  String get justNow => _t('justNow');
  String minutesAgo(int n) => _t('minutesAgo', {'n': n});
  String hoursAgo(int n) => _t('hoursAgo', {'n': n});
  String daysAgo(int n) => _t('daysAgo', {'n': n});
  String get configNeeded => _t('configNeeded');
  String get configNeededBody => _t('configNeededBody');
  String get updateAvailable => _t('updateAvailable');
  String updateAvailableBody(String version) =>
      _t('updateAvailableBody', {'version': version});
  String get updateNow => _t('updateNow');
  String get updateLater => _t('updateLater');
  String get updateChooseMethod => _t('updateChooseMethod');
  String get updateInApp => _t('updateInApp');
  String get updateInAppSubtitle => _t('updateInAppSubtitle');
  String get updateInBrowser => _t('updateInBrowser');
  String get updateInBrowserSubtitle => _t('updateInBrowserSubtitle');
  String get updateDownloading => _t('updateDownloading');
  String get updateInstallPermissionTitle => _t('updateInstallPermissionTitle');
  String get updateInstallPermissionBody => _t('updateInstallPermissionBody');
  String get updateContinueInstall => _t('updateContinueInstall');
  String get updateErrorTitle => _t('updateErrorTitle');
  String get updateDownloadFailed => _t('updateDownloadFailed');
  String get updateLatest => _t('updateLatest');
  String get checkForUpdates => _t('checkForUpdates');
  String get checkForUpdatesSubtitle => _t('checkForUpdatesSubtitle');
  String get updateRepositoryNotConfigured =>
      _t('updateRepositoryNotConfigured');
  String get updateCheckFailed => _t('updateCheckFailed');
}

class _NexLocDelegates {
  static const List<LocalizationsDelegate<dynamic>> all = [
    AppLocalizationsDelegate(),
    _FallbackMaterialDelegate(),
    _FallbackCupertinoDelegate(),
    _FallbackWidgetsDelegate(),
  ];
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  @override
  bool isSupported(Locale l) => ['en', 'ar'].contains(l.languageCode);
  @override
  Future<AppLocalizations> load(Locale l) async => AppLocalizations(l);
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class _FallbackMaterialDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialDelegate();
  @override
  bool isSupported(Locale l) => true;
  @override
  Future<MaterialLocalizations> load(Locale l) async =>
      _NexMaterialLocalizations(l);
  @override
  bool shouldReload(_FallbackMaterialDelegate old) => false;
}

class _NexMaterialLocalizations extends DefaultMaterialLocalizations {
  final Locale locale;
  _NexMaterialLocalizations(this.locale);
  @override
  ui.TextDirection get textDirection =>
      locale.languageCode == 'ar' ? ui.TextDirection.rtl : ui.TextDirection.ltr;
}

class _FallbackCupertinoDelegate extends LocalizationsDelegate<Object> {
  const _FallbackCupertinoDelegate();
  @override
  bool isSupported(Locale l) => true;
  @override
  Future<Object> load(Locale l) async => Object();
  @override
  bool shouldReload(_FallbackCupertinoDelegate old) => false;
}

class _FallbackWidgetsDelegate extends LocalizationsDelegate<Object> {
  const _FallbackWidgetsDelegate();
  @override
  bool isSupported(Locale l) => true;
  @override
  Future<Object> load(Locale l) async => Object();
  @override
  bool shouldReload(_FallbackWidgetsDelegate old) => false;
}
