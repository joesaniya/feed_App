int _int(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
bool _bool(Object? value) => value == true || value == 1 || value == 'true';
String _string(Object? value) => value?.toString() ?? '';
String? _optionalString(Object? value) => value is String ? value : null;
List<Object?> _list(Object? value) => value is List ? value : const [];

Map<String, dynamic>? _map(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

DateTime? _dateTime(Object? value) =>
    DateTime.tryParse(_string(value))?.toLocal();

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
      const [
        'mp4',
        'mov',
        'm4v',
        'webm',
        'avi',
      ].contains(fileType.toLowerCase()) ||
      fileUrl.contains('.m3u8');
  String get previewUrl => isVideo ? thumbnail : fileUrl;

  factory PostFile.fromJson(Map<String, dynamic> json) => PostFile(
    id: _string(json['id']),
    fileType: _string(json['file_type']),
    fileUrl: _string(json['file_url']),
    thumbnail: _string(json['thumbnail']),
  );
}

class PostUser {
  final String id;
  final String username;

  PostUser({required this.id, required this.username});

  factory PostUser.fromJson(Map<String, dynamic>? json) =>
      PostUser(id: _string(json?['id']), username: _string(json?['username']));
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
    firstName: _string(json?['first_name']).trim(),
    lastName: _string(json?['last_name']).trim(),
    profilePicture: _optionalString(json?['profile_picture']),
  );
}

class PostLocation {
  final String name;
  final String address;

  PostLocation({required this.name, required this.address});

  static PostLocation? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PostLocation(
      name: _string(json['name']),
      address: _string(json['address']),
    );
  }
}

class PostType {
  final String name;
  final String slug;

  PostType({required this.name, required this.slug});

  static PostType? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return PostType(name: _string(json['name']), slug: _string(json['slug']));
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
    final user = _map(json['user']);
    final profile = PostProfile.fromJson(_map(json['profile']));
    return RepostedBy(
      userId: _string(user?['id']),
      username: _string(user?['username']),
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
    final categories = _list(json['post_type_category']);
    final subCategories = _list(json['post_type_sub_category']);

    return PostModel(
      id: _string(json['id']),
      userId: _string(json['user_id']),
      content: _string(json['content']),
      feeling: _optionalString(json['feeling']),
      createdAt: _dateTime(json['createdAt']),
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
      user: PostUser.fromJson(_map(json['user'])),
      profile: PostProfile.fromJson(_map(json['profile'])),
      postType: PostType.fromJson(_map(json['post_type'])),
      location: PostLocation.fromJson(_map(json['location'])),
      files: _list(json['files'])
          .map(_map)
          .whereType<Map<String, dynamic>>()
          .map(PostFile.fromJson)
          .toList(),
      categoryName: categories.isNotEmpty
          ? _optionalString(_map(categories.first)?['name'])
          : null,
      subCategoryName: subCategories.isNotEmpty
          ? _optionalString(_map(subCategories.first)?['name'])
          : null,
      repostedBy: RepostedBy.fromJson(_map(json['reposted_by_user'])),
      repostedTime: _dateTime(json['reposted_time']),
    );
  }
}

class PostsPage {
  final int totalCount;
  final List<PostModel> posts;

  PostsPage({required this.totalCount, required this.posts});

  factory PostsPage.fromJson(Map<String, dynamic> json) {
    final inner = _map(_map(json['data'])?['data']);
    final rows = inner?['rows'];
    return PostsPage(
      totalCount: _int(inner?['count']),
      posts: (rows is List ? rows : const [])
          .map(_map)
          .whereType<Map<String, dynamic>>()
          .map(PostModel.fromJson)
          .toList(),
    );
  }
}
