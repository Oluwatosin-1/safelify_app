import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityReport {
  CommunityReport({
    this.id,
    this.title,
    this.file = '',
    this.createdOn,
    this.userId,
    this.name,
    this.image,
    this.video, // Add the video field
    this.commentCount,
    this.catId, // Field for category ID
    this.timestamp, // Timestamp field for storing creation time
    this.category, // Category name
    required this.city, // City is required
  });

  String? id;
  String? title;
  String file;
  String? createdOn;
  String? userId;
  String? name;
  String? image;
  String? video; // Video field
  int? commentCount;
  String city;
  String? catId; // Category ID
  String? category; // Category name
  Timestamp? timestamp; // Timestamp field for creation time

  factory CommunityReport.fromJson(Map<String, dynamic> json) {
    return CommunityReport(
      id: json["id"] as String?,
      title: json["title"] as String?,
      file: json["file"] as String? ?? '',
      createdOn: json["created_on"] as String?,
      userId: json["user_id"] as String?,
      name: json["name"] as String?,
      image: json["image"] as String?,
      video: json["video"] as String?, // Deserialize video field
      commentCount: json["commentCount"] as int?,
      city: json['city'] as String? ?? '',
      catId: json['cat_id'] as String?, // Fetch catId if available
      category: json['category'] as String?, // Fetch category name if available
      timestamp: json['timestamp'] as Timestamp?, // Fetch timestamp if available
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "file": file,
      "video": video, // Serialize video field
      "created_on": createdOn,
      "user_id": userId,
      "name": name,
      "image": image,
      "commentCount": commentCount,
      "city": city,
      "cat_id": catId, // Serialize category ID
      "category": category, // Serialize category name
      "timestamp": timestamp, // Serialize timestamp
    };
  }

  // Static method to create a list of CommunityReport from JSON data
  static List<CommunityReport> listFromMap(List<dynamic> json) {
    return List<CommunityReport>.from(
      json.map(
            (x) => CommunityReport.fromJson(x),
      ),
    );
  }
}
