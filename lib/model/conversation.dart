class Conversation {
  String conversationId;
  String ownerId;
  DateTime modified;
  String receiverId;
  String avatarOwner;
  String nameOwner;
  String avatarReceiver;
  String nameReceiver;
  String deviceId;
  String devicetype;
  bool isOwner;
  String isOnline;
  String message;
  String date;
  String? read;
  int? unreadCount;

  Conversation({
    required this.conversationId,
    required this.ownerId,
    required this.modified,
    required this.receiverId,
    required this.avatarOwner,
    required this.nameOwner,
    required this.avatarReceiver,
    required this.nameReceiver,
    required this.deviceId,
    required this.devicetype,
    required this.isOwner,
    required this.isOnline,
    required this.message,
    required this.date,
    this.read,
    this.unreadCount,
  });

  static List<Conversation> listFromMap(List<dynamic> json) {
    return List<Conversation>.from(
      json.map(
        (x) => Conversation.fromMap(x),
      ),
    );
  }

  factory Conversation.fromMap(Map<String, dynamic> json) => Conversation(
        conversationId: json["conversation_id"],
        ownerId: json["owner_id"],
        modified: DateTime.parse(json["modified"]),
        receiverId: json["receiver_id"],
        avatarOwner: json["avatar_owner"],
        nameOwner: json["name_owner"],
        avatarReceiver: json["avatar_receiver"],
        nameReceiver: json["name_receiver"],
        deviceId: json["device_id"],
        devicetype: json["devicetype"],
        isOwner: json["is_owner"],
        isOnline: json["is_online"],
        message: json["message"],
        date: json["date"],
        read: json["read"],
        unreadCount: json["UnreadCount"],
      );

  Map<String, dynamic> toMap() => {
        "conversation_id": conversationId,
        "owner_id": ownerId,
        "modified": modified.toIso8601String(),
        "receiver_id": receiverId,
        "avatar_owner": avatarOwner,
        "name_owner": nameOwner,
        "avatar_receiver": avatarReceiver,
        "name_receiver": nameReceiver,
        "device_id": deviceId,
        "devicetype": devicetype,
        "is_owner": isOwner,
        "is_online": isOnline,
        "message": message,
        "date": date,
        "read": read,
        "UnreadCount": unreadCount,
      };
}
