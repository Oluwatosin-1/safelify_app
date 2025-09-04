class Comment {
  Comment({
    this.id,
    this.body,
    this.userId,
    this.postedTime,
    this.reportId,
    this.name,
    this.image,
  });

  String? id;
  String? body;
  String? userId;
  DateTime? postedTime; // Keep as DateTime
  String? reportId;
  String? name;
  String? image;

  static List<Comment> listFromMap(List<dynamic> json) {
    return List<Comment>.from(
      json.map(
            (x) => Comment.fromMap(x),
      ),
    );
  }

  factory Comment.fromMap(Map<String, dynamic> json) => Comment(
    id: json["id"],
    body: json["body"],
    userId: json["user_id"],
    postedTime: json["posted_time"] != null
        ? DateTime.parse(json["posted_time"])
        : null, // Use nullable DateTime
    reportId: json["report_id"],
    name: json["name"],
    image: json["image"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "body": body,
    "user_id": userId,
    "posted_time": postedTime?.toIso8601String(), // Handle null safely
    "report_id": reportId,
    "name": name,
    "image": image,
  };
}
