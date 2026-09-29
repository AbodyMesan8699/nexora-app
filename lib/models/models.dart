class Profile {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String? email;
  final String? avatarUrl;
  final String? coverUrl;
  final String? bio;
  final bool isVerified;
  final String accountStatus;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.email,
    this.avatarUrl,
    this.coverUrl,
    this.bio,
    this.isVerified = false,
    this.accountStatus = 'active',
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: j['id'] as String,
        firstName: (j['first_name'] ?? '') as String,
        lastName: (j['last_name'] ?? '') as String,
        username: (j['username'] ?? '') as String,
        email: j['email'] as String?,
        avatarUrl: j['avatar_url'] as String?,
        coverUrl: j['cover_url'] as String?,
        bio: j['bio'] as String?,
        isVerified: (j['is_verified'] ?? false) as bool,
        accountStatus: (j['account_status'] ?? 'active') as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class PostMedia {
  final String mediaUrl;
  final String mediaType;
  final String? thumbnailUrl;

  PostMedia({required this.mediaUrl, required this.mediaType, this.thumbnailUrl});

  factory PostMedia.fromJson(Map<String, dynamic> j) => PostMedia(
        mediaUrl: j['media_url'] as String,
        mediaType: (j['media_type'] ?? 'image') as String,
        thumbnailUrl: j['thumbnail_url'] as String?,
      );

  Map<String, dynamic> toJson() =>
      {'media_url': mediaUrl, 'media_type': mediaType, 'thumbnail_url': thumbnailUrl};
}

class Post {
  final String id;
  final String userId;
  final Profile user;
  final String content;
  final String? location;
  final String? feeling;
  final String visibility;
  final DateTime createdAt;
  final bool isLiked;
  final bool isSaved;
  final bool isMine;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final List<PostMedia> media;

  Post({
    required this.id,
    required this.userId,
    required this.user,
    required this.content,
    this.location,
    this.feeling,
    required this.visibility,
    required this.createdAt,
    this.isLiked = false,
    this.isSaved = false,
    this.isMine = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.media = const [],
  });

  factory Post.fromJson(Map<String, dynamic> j, String myId) {
    final userJson = j['profiles'] ?? j['user'] ?? {};
    return Post(
      id: j['id'] as String,
      userId: j['user_id'] as String,
      user: Profile.fromJson(Map<String, dynamic>.from(userJson as Map)),
      content: (j['content'] ?? '') as String,
      location: j['location'] as String?,
      feeling: j['feeling'] as String?,
      visibility: (j['visibility'] ?? 'public') as String,
      createdAt: DateTime.parse(j['created_at'] as String),
      isLiked: ((j['post_likes'] as List?) ?? const []).isNotEmpty,
      isSaved: ((j['saved_posts'] as List?) ?? const []).isNotEmpty,
      isMine: j['user_id'] == myId,
      likeCount: (j['like_count'] ?? ((j['post_likes'] as List?) ?? const []).length) as int,
      commentCount:
          (j['comment_count'] ?? ((j['comments'] as List?) ?? const []).length) as int,
      shareCount: (j['share_count'] ?? 0) as int,
      media: ((j['post_media'] as List?) ?? const [])
          .map((m) => PostMedia.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList(),
    );
  }
}

class Comment {
  final String id;
  final String postId;
  final String? parentId;
  final String userId;
  final Profile user;
  final String content;
  final DateTime createdAt;
  final bool isMine;
  final int likeCount;
  final bool isLiked;

  Comment({
    required this.id,
    required this.postId,
    this.parentId,
    required this.userId,
    required this.user,
    required this.content,
    required this.createdAt,
    this.isMine = false,
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> j, String myId) => Comment(
        id: j['id'] as String,
        postId: j['post_id'] as String,
        parentId: j['parent_id'] as String?,
        userId: j['user_id'] as String,
        user: Profile.fromJson(Map<String, dynamic>.from((j['profiles'] ?? {}) as Map)),
        content: (j['content'] ?? '') as String,
        createdAt: DateTime.parse(j['created_at'] as String),
        isMine: j['user_id'] == myId,
        likeCount: ((j['comment_likes'] as List?) ?? const []).length,
        isLiked: ((j['comment_likes'] as List?) ?? const [])
            .any((l) => (l as Map)['user_id'] == myId),
      );
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String messageType;
  final String? mediaUrl;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final bool isMine;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.mediaUrl,
    required this.createdAt,
    this.editedAt,
    this.deletedAt,
    this.isMine = false,
  });

  bool get isDeleted => deletedAt != null;

  factory Message.fromJson(Map<String, dynamic> j, String myId) => Message(
        id: j['id'] as String,
        conversationId: j['conversation_id'] as String,
        senderId: j['sender_id'] as String,
        content: (j['content'] ?? '') as String,
        messageType: (j['message_type'] ?? 'text') as String,
        mediaUrl: j['media_url'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        editedAt: j['edited_at'] == null ? null : DateTime.parse(j['edited_at'] as String),
        deletedAt: j['deleted_at'] == null ? null : DateTime.parse(j['deleted_at'] as String),
        isMine: j['sender_id'] == myId,
      );
}

class Conversation {
  final String id;
  final DateTime updatedAt;
  final List<Profile> others;
  final int unreadCount;
  final Message? lastMessage;

  Conversation({
    required this.id,
    required this.updatedAt,
    required this.others,
    this.unreadCount = 0,
    this.lastMessage,
  });

  String get title => others.map((p) => p.fullName).join(', ');

  factory Conversation.fromJson(
      Map<String, dynamic> j, String myId, List<Profile> members) {
    return Conversation(
      id: j['id'] as String,
      updatedAt: DateTime.parse(j['updated_at'] as String),
      others: members.where((m) => m.id != myId).toList(),
      unreadCount: 0,
      lastMessage: j['last_message'] == null
          ? null
          : Message.fromJson(Map<String, dynamic>.from(j['last_message'] as Map), myId),
    );
  }
}

class Story {
  final String id;
  final String userId;
  final Profile user;
  final String? mediaUrl;
  final String? mediaType;
  final String? content;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isMine;
  final bool seenByMe;

  Story({
    required this.id,
    required this.userId,
    required this.user,
    this.mediaUrl,
    this.mediaType,
    this.content,
    required this.createdAt,
    required this.expiresAt,
    this.isMine = false,
    this.seenByMe = false,
  });

  factory Story.fromJson(Map<String, dynamic> j, String myId) => Story(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        user: Profile.fromJson(Map<String, dynamic>.from((j['profiles'] ?? {}) as Map)),
        mediaUrl: j['media_url'] as String?,
        mediaType: j['media_type'] as String?,
        content: j['content'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        expiresAt: DateTime.parse(j['expires_at'] as String),
        isMine: j['user_id'] == myId,
        seenByMe: ((j['story_views'] as List?) ?? const []).isNotEmpty,
      );
}

class NexNotification {
  final String id;
  final String userId;
  final String? actorId;
  final Profile? actor;
  final String type;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  NexNotification({
    required this.id,
    required this.userId,
    this.actorId,
    this.actor,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NexNotification.fromJson(Map<String, dynamic> j) => NexNotification(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        actorId: j['actor_id'] as String?,
        actor: j['profiles'] == null
            ? null
            : Profile.fromJson(Map<String, dynamic>.from(j['profiles'] as Map)),
        type: j['type'] as String,
        referenceId: j['reference_id'] as String?,
        isRead: (j['is_read'] ?? false) as bool,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class FriendRequest {
  final String id;
  final Profile sender;
  final DateTime createdAt;

  FriendRequest({required this.id, required this.sender, required this.createdAt});

  factory FriendRequest.fromJson(Map<String, dynamic> j) => FriendRequest(
        id: j['id'] as String,
        sender: Profile.fromJson(Map<String, dynamic>.from((j['profiles'] ?? {}) as Map)),
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class UserSettings {
  final String userId;
  final String profileVisibility;
  final String messagePrivacy;
  final String followPrivacy;
  final bool onlineStatusVisible;

  UserSettings({
    required this.userId,
    this.profileVisibility = 'everyone',
    this.messagePrivacy = 'everyone',
    this.followPrivacy = 'everyone',
    this.onlineStatusVisible = true,
  });

  factory UserSettings.fromJson(Map<String, dynamic> j) => UserSettings(
        userId: j['user_id'] as String,
        profileVisibility: (j['profile_visibility'] ?? 'everyone') as String,
        messagePrivacy: (j['message_privacy'] ?? 'everyone') as String,
        followPrivacy: (j['follow_privacy'] ?? 'everyone') as String,
        onlineStatusVisible: (j['online_status_visible'] ?? true) as bool,
      );
}

class AdminStats {
  final int totalUsers, activeUsers, totalPosts, totalComments;
  final int pendingReports, suspendedAccounts, storageObjects, recentUsers;

  AdminStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalPosts,
    required this.totalComments,
    required this.pendingReports,
    required this.suspendedAccounts,
    required this.storageObjects,
    required this.recentUsers,
  });

  factory AdminStats.fromJson(Map<String, dynamic> j) => AdminStats(
        totalUsers: (j['total_users'] as num?)?.toInt() ?? 0,
        activeUsers: (j['active_users'] as num?)?.toInt() ?? 0,
        totalPosts: (j['total_posts'] as num?)?.toInt() ?? 0,
        totalComments: (j['total_comments'] as num?)?.toInt() ?? 0,
        pendingReports: (j['pending_reports'] as num?)?.toInt() ?? 0,
        suspendedAccounts: (j['suspended_accounts'] as num?)?.toInt() ?? 0,
        storageObjects: (j['storage_objects'] as num?)?.toInt() ?? 0,
        recentUsers: (j['recent_users'] as num?)?.toInt() ?? 0,
      );
}

class Report {
  final String id;
  final String targetType;
  final String targetId;
  final String reason;
  final String? description;
  final String status;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> j) => Report(
        id: j['id'] as String,
        targetType: j['target_type'] as String,
        targetId: j['target_id'] as String,
        reason: j['reason'] as String,
        description: j['description'] as String?,
        status: j['status'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
