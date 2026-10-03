int _int(dynamic v) => (v as num?)?.toInt() ?? 0;
bool _bool(dynamic v) => v == true;

class PostFile {
  final String id;
  final String fileType;
  final String fileUrl;
  final String thumbnail;

  PostFile({
    required this.id,
    required this.fileType,
    required this.fileUrl,
    required this.thumbnail,
  });

  bool get isVideo =>
      const ['mp4', 'mov', 'm4v', 'webm', 'avi'].contains(fileType.toLowerCase()) ||
      fileUrl.contains('.m3u8');
String get previewUrl => isVideo ? thumbnail : fileUrl;

  factory PostFile.fromJson(Map<String, dynamic> json) => PostFile(
        id: json['id'] as String? ?? '',
        fileType: json['file_type'] as String? ?? '',
        fileUrl: json['file_url'] as String? ?? '',
        thumbnail: json['thumbnail'] as String? ?? '',
      );
}

class PostUser {
  final String id;
  final String username;

  PostUser({required this.id, required this.username});

  factory PostUser.fromJson(Map<String, dynamic>? json) => PostUser(
        id: json?['id'] as String? ?? '',
        username: json?['username'] as String? ?? '',
      );
}

class PostProfile {
  final String firstName;
  final String lastName;
  final String? profilePicture;

  PostProfile({
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory PostProfile.fromJson(Map<String, dynamic>? json) => PostProfile(
        firstName: (json?['first_name'] as String? ?? '').trim(),
        lastName: (json?['last_name'] as String? ?? '').trim(),
        profilePicture: json?['profile_picture'] as String?,
      );
}

class PostLocation {
  final String name;
  final String address;

  PostLocation({required this.name, required this.address});

  static PostLocation? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PostLocation(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }
}

class PostType {
  final String name;
  final String slug;

  PostType({required this.name, required this.slug});

  static PostType? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PostType(
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class RepostedBy {
  final String userId;
  final String username;
  final String fullName;

  RepostedBy({
    required this.userId,
    required this.username,
    required this.fullName,
  });

  static RepostedBy? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final user = json['user'] as Map<String, dynamic>?;
    final profile = PostProfile.fromJson(json['profile'] as Map<String, dynamic>?);
    return RepostedBy(
      userId: user?['id'] as String? ?? '',
      username: user?['username'] as String? ?? '',
      fullName: profile.fullName,
    );
  }
}

class PostModel {
  final String id;
  final String userId;
  final String content;
  final String? feeling;
  final DateTime? createdAt;

  final int likesCount;
  final int commentsCount;
  final int totalCommentCount;
  final int shareCount;
  final int repostCount;

  final bool isLiked;
  final bool isSaved;
  final bool isMyPost;
  final bool ifFollowing;
  final bool ifFriend;

  final PostUser user;
  final PostProfile profile;
  final PostType? postType;
  final PostLocation? location;
  final List<PostFile> files;

  final String? categoryName;
  final String? subCategoryName;

  final RepostedBy? repostedBy;
  final DateTime? repostedTime;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.user,
    required this.profile,
    this.feeling,
    this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.totalCommentCount = 0,
    this.shareCount = 0,
    this.repostCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.isMyPost = false,
    this.ifFollowing = false,
    this.ifFriend = false,
    this.postType,
    this.location,
    this.files = const [],
    this.categoryName,
    this.subCategoryName,
    this.repostedBy,
    this.repostedTime,
  });

  String get uniqueKey => '${id}_${repostedBy?.userId ?? 'orig'}';

  
  String get plainContent => content
      .replaceAll(RegExp(r'<[^>]*>'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final categories = json['post_type_category'] as List? ?? [];
    final subCategories = json['post_type_sub_category'] as List? ?? [];

    return PostModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      feeling: json['feeling'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal(),
      likesCount: _int(json['likes_count']),
      commentsCount: _int(json['comments_count']),
      totalCommentCount: _int(json['total_comment_count']),
      shareCount: _int(json['share_count']),
      repostCount: _int(json['repost_count']),
      isLiked: _bool(json['is_liked']),
      isSaved: _bool(json['is_saved']),
      isMyPost: _bool(json['is_my_post']),
      ifFollowing: _bool(json['if_following']),
      ifFriend: _bool(json['if_friend']),
      user: PostUser.fromJson(json['user'] as Map<String, dynamic>?),
      profile: PostProfile.fromJson(json['profile'] as Map<String, dynamic>?),
      postType: PostType.fromJson(json['post_type'] as Map<String, dynamic>?),
      location: PostLocation.fromJson(json['location'] as Map<String, dynamic>?),
      files: (json['files'] as List? ?? [])
          .map((e) => PostFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryName: categories.isNotEmpty
          ? (categories.first as Map<String, dynamic>)['name'] as String?
          : null,
      subCategoryName: subCategories.isNotEmpty
          ? (subCategories.first as Map<String, dynamic>)['name'] as String?
          : null,
      repostedBy:
          RepostedBy.fromJson(json['reposted_by_user'] as Map<String, dynamic>?),
      repostedTime: DateTime.tryParse(json['reposted_time'] as String? ?? '')?.toLocal(),
    );
  }
}


class PostsPage {
  final int totalCount;
  final List<PostModel> posts;

  PostsPage({required this.totalCount, required this.posts});

  factory PostsPage.fromJson(Map<String, dynamic> json) {
    final inner = (json['data'] as Map<String, dynamic>?)?['data']
            as Map<String, dynamic>? ??
        {};
    return PostsPage(
      totalCount: _int(inner['count']),
      posts: (inner['rows'] as List? ?? [])
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}