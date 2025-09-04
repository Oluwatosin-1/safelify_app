import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/get_comments.dart';
import '../utils/global_helpers.dart';

class CommentsController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Comment> comments = RxList([]);
  RxInt commentCount = 0.obs; // Observable count for comments
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchCommentWithUser(String commentId) async {
    try {
      final commentSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .doc(commentId)
          .get();

      if (!commentSnapshot.exists) {
        return {}; // Handle non-existent comment gracefully
      }

      final userId = commentSnapshot['userId'];
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Retrieve and safely handle `postedTime`
      final postedTime = commentSnapshot.data()?['postedTime'] != null
          ? commentSnapshot['postedTime'].toDate()
          : null;

      return {
        'username': "${userSnapshot['first_name']} ${userSnapshot['last_name']}",
        'body': commentSnapshot['body'],
        'postedTime': postedTime,
        'userId': userId,
        'commentId': commentSnapshot.id,
      };
    } catch (e) {
      print("Error fetching comment with user: $e");
      return {}; // Return empty map if error
    }
  }

  // Fetch comments for a specific report
  Future<void> getComments(String reportId) async {
    isLoading(true);
    try {
      // Fetch comments from the 'comments' subcollection of the report
      QuerySnapshot commentSnapshot = await _firestore
          .collection('reports')
          .doc(reportId)
          .collection('comments')
          .orderBy('timestamp', descending: true) // Order by latest first
          .get();

      // Convert to a list of Comment models
      comments.value = commentSnapshot.docs.map((doc) {
        return Comment(
          id: doc.id,
          body: doc['body'] ?? '',
          postedTime: (doc['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(), // Convert to DateTime
          userId: doc['userId'] ?? 'Unknown',
        );
      }).toList();

      // Update comment count
      commentCount.value = comments.length;

      if (comments.isEmpty) {
        showMightySnackBar(message: 'No comments found.');
      }
    } catch (e) {
      showMightySnackBar(message: 'Error fetching comments: $e');
    } finally {
      isLoading(false);
    }
  }

  // Add a new comment
  Future<void> addComment(String body, String reportId) async {
    isLoading(true);
    try {
      var newComment = {
        'body': body,
        'timestamp': FieldValue.serverTimestamp(), // Server timestamp for accuracy
        'userId': 'sampleUserId', // Replace with actual userId
      };

      // Add comment to the 'comments' subcollection
      await _firestore
          .collection('reports')
          .doc(reportId)
          .collection('comments')
          .add(newComment);

      showMightySnackBar(message: 'Comment added successfully.');
      // Refresh the comment list after adding
      await getComments(reportId);
    } catch (e) {
      showMightySnackBar(message: 'Error adding comment: $e');
    } finally {
      isLoading(false);
    }
  }

  // Update an existing comment
  Future<void> updateComment(String id, String body, String reportId) async {
    isLoading(true);
    try {
      var commentRef = _firestore
          .collection('reports')
          .doc(reportId)
          .collection('comments')
          .doc(id);

      await commentRef.update({
        'body': body,
        'timestamp': FieldValue.serverTimestamp(), // Optional: update timestamp
      });

      // Update the local list
      int index = comments.indexWhere((comment) => comment.id == id);
      if (index != -1) {
        comments[index].body = body;
        comments.refresh();
      }

      showMightySnackBar(message: 'Comment updated successfully.');
    } catch (e) {
      showMightySnackBar(message: 'Error updating comment: $e');
    } finally {
      isLoading(false);
    }
  }

  // Delete a comment
  Future<void> deleteComment(String id, String reportId) async {
    isLoading(true);
    try {
      await _firestore
          .collection('reports')
          .doc(reportId)
          .collection('comments')
          .doc(id)
          .delete();

      // Remove the comment from the local list
      comments.removeWhere((comment) => comment.id == id);
      comments.refresh();

      // Update comment count
      commentCount.value = comments.length;

      showMightySnackBar(message: 'Comment deleted successfully.');
    } catch (e) {
      showMightySnackBar(message: 'Error deleting comment: $e');
    } finally {
      isLoading(false);
    }
  }

  // Return the current comment count
  int get currentCommentCount => commentCount.value;
}
