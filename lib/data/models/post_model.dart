class PostModel {
  final String id;
  final String imageUrl;
  final int fireCount;
  final int heartCount;
  final int commentCount;
  final String username;

  PostModel({
    required this.id,
    required this.imageUrl,
    this.fireCount = 0,
    this.heartCount = 0,
    this.commentCount = 0,
    required this.username,
  });

  // Professionals use this to convert Firestore data into a Post object
  factory PostModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PostModel(
      id: id,
      imageUrl: data['imageUrl'] ?? '',
      fireCount: data['fireCount'] ?? 0,
      heartCount: data['heartCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      username: data['username'] ?? 'Anonymous',
    );
  }
}