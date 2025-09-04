import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/comments_controller.dart';
import '../../controllers/report_controller.dart';
import '../../model/get_community_reports_model.dart';

class CommunityPostCard extends StatefulWidget {
  const CommunityPostCard({
    super.key,
    required this.report,
  });

  final CommunityReport report;

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  final CommentsController _commentsController = Get.find();
  final ReportController _reportController = Get.find();
  final AuthController _authController = Get.find();
  String? firstName;
  String? lastName;
  String? categoryName;
  String? createdOn;
  int commentCount = 0; // Holds the dynamic comment count
  late VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    if (widget.report.userId != null) fetchUserName(widget.report.userId!);
    if (widget.report.catId != null) fetchCategoryName(widget.report.catId!);
    formatTimestamp(widget.report.timestamp);

    // Fetch and set comment count
    fetchCommentCount(widget.report.id!).then((count) {
      setState(() {
        commentCount = count;
      });
    });

    if (widget.report.video?.trim().isNotEmpty ?? false) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.report.video!),
      )..initialize().then((_) {
          setState(() {}); // Refresh to display the first video frame
        });
    } else {
      _videoController = null; // No video controller for non-video content
    }
  }

  @override
  void dispose() {
    _videoController?.dispose(); // Dispose video controller if exists
    super.dispose();
  }

  Future<void> fetchUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          firstName = userDoc['first_name'] ?? 'Unknown';
          lastName = userDoc['last_name'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  Future<void> fetchCategoryName(String catId) async {
    try {
      DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
          .collection('reportCategories')
          .doc(catId)
          .get();

      if (categoryDoc.exists) {
        setState(() {
          categoryName = categoryDoc['category'] ?? 'Unknown Category';
        });
      }
    } catch (e) {
      print("Error fetching category name: $e");
    }
  }

  void formatTimestamp(Timestamp? timestamp) {
    if (timestamp != null) {
      final DateTime date = timestamp.toDate();
      setState(() {
        createdOn = "${date.day}/${date.month}/${date.year}";
      });
    } else {
      setState(() {
        createdOn = "N/A";
      });
    }
  }

  Future<int> fetchCommentCount(String reportId) async {
    try {
      QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('report_id', isEqualTo: reportId)
          .get();
      return commentsSnapshot.docs.length; // Return the count of documents
    } catch (e) {
      print("Error fetching comment count: $e");
      return 0; // Return 0 on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.report.video?.trim().isNotEmpty ?? false)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MediaViewer(
                        mediaUrl: widget.report.video!,
                        isVideo: true,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: 100,
                  height: 80,
                  child: _videoController != null &&
                          _videoController!.value.isInitialized
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_videoController!), // Video thumbnail
                            const Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 50,
                            ),
                          ],
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
              )
            else if (widget.report.image?.trim().isNotEmpty ?? false)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MediaViewer(
                        mediaUrl: widget.report.image!,
                        isVideo: false,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  widget.report.image!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(), // If no image or video file, display nothing
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Display the name, category, and createdOn date
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${firstName ?? 'Unknown'} ${lastName ?? ''}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w400, color: Colors.black),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        createdOn ?? 'N/A',
                        style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 8,
                            color: Colors.black),
                        maxLines: 1,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Display category name
                  Text(
                    categoryName ?? 'Unknown Category',
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Title with a dialog to show full report details
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Report",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.report.title ?? "No title",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.report.city, // City info
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Close"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      widget.report.title ?? "No title",
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                  const Spacer(),

                  // Comments, share, and corroborate/flag actions
                  GestureDetector(
                    onTap: _showCommentDialogue,
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/chat.png',
                          height: 12,
                          width: 12,
                        ),
                        const SizedBox(width: 5),
                        Obx(() {
                          return Text(
                            "${_commentsController.comments.length}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.black),
                          );
                        }),
                        const SizedBox(width: 15),
                        InkWell(
                          onTap: () {
                            // Handle sharing logic here
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icons/share.png',
                                  height: 12,
                                  width: 12,
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  "Share",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            // Corroborate or Flag actions
            Obx(() {
              return _commentsController.isLoading.value
                  ? const SizedBox()
                  : PopupMenuButton(
                      padding: EdgeInsets.zero,
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            enabled: !_reportController.isCorroborating.value,
                            onTap: () {
                              _reportController.corroborate(
                                  id: widget.report.id!, status: "Flag");
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.flag_outlined),
                                SizedBox(width: 10),
                                Text("Flag as inappropriate"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            enabled: !_reportController.isCorroborating.value,
                            onTap: () {
                              _reportController.corroborate(
                                  id: widget.report.id!, status: "Corroborate");
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.check_outlined),
                                SizedBox(width: 10),
                                Text("Corroborate"),
                              ],
                            ),
                          ),
                        ];
                      },
                    );
            })
          ],
        ),
      ),
    );
  }

  _showCommentDialogue() async {
    await _commentsController.getComments(widget.report.id!);

    final userDetails = await _authController.userDetails;
    final userId = userDetails?['id']; // Fetch the current userId

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController commentEditingController =
            TextEditingController();

        return Obx(() {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Padding(
              padding: const EdgeInsets.all(
                  20.0), // Adjust padding for a spacious feel
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Make dialog adapt to content size
                children: [
                  // Dialog Title
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Comments',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ),
                      // Close Button
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  const Divider(thickness: 1),

                  const SizedBox(height: 10),

                  // Comments List
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _commentsController.comments.length,
                      itemBuilder: (BuildContext context, int index) {
                        var comment = _commentsController.comments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                comment.body ?? "No comment body",
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                comment.postedTime != null
                                    ? DateFormat('yyyy-MM-dd – kk:mm')
                                        .format(comment.postedTime!)
                                    : 'Unknown time',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              trailing: comment.userId == userId
                                  ? IconButton(
                                      onPressed: () {
                                        _commentsController.deleteComment(
                                            comment.id!, widget.report.id!);
                                      },
                                      icon: const Icon(Icons.delete,
                                          color: Colors.redAccent),
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(thickness: 1, height: 20),

                  // Comment Input Field and Send Button
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom:
                            8.0), // Ensure input field and button are neatly spaced
                    child: Row(
                      children: [
                        // Text Input Field
                        Expanded(
                          child: TextField(
                            controller: commentEditingController,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              hintStyle: TextStyle(
                                  color: Colors.grey[400]), // Light hint color
                              filled: true,
                              fillColor: Colors
                                  .grey[200], // Light background for input
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Send Button
                        IconButton(
                          icon:
                              const Icon(Icons.send, color: Colors.blueAccent),
                          onPressed: () {
                            if (commentEditingController.text
                                .trim()
                                .isNotEmpty) {
                              _commentsController.addComment(
                                commentEditingController.text,
                                widget.report.id!,
                              );
                              commentEditingController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class MediaViewer extends StatefulWidget {
  final String mediaUrl;
  final bool isVideo;

  const MediaViewer({super.key, required this.mediaUrl, required this.isVideo});

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  late VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();

    if (widget.isVideo) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl))
        ..initialize().then((_) {
          setState(() {}); // Refresh to display video
          _controller?.play(); // Auto-play the video
        });
    } else {
      _controller = null; // No video controller needed for images
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose video controller if exists
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Close viewer
          },
        ),
      ),
      body: Center(
        child: widget.isVideo
            ? _controller != null && _controller!.value.isInitialized
                ? Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _controller!.value.isPlaying
                                ? _controller?.pause()
                                : _controller?.play();
                          });
                        },
                        child: SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller!.value.size.width,
                              height: _controller!.value.size.height,
                              child: VideoPlayer(_controller!),
                            ),
                          ),
                        ),
                      ),
                      _buildVideoControls(),
                    ],
                  )
                : const Center(
                    child:
                        CircularProgressIndicator(), // Show loading indicator
                  )
            : SizedBox.expand(
                child: Image.network(
                  widget.mediaUrl,
                  fit: BoxFit.cover, // Cover entire screen
                ),
              ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                _controller?.seekTo(
                  _controller!.value.position - const Duration(seconds: 10),
                );
              },
              icon: const Icon(Icons.replay_10, color: Colors.white, size: 30),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller?.pause()
                      : _controller?.play();
                });
              },
              icon: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
            IconButton(
              onPressed: () {
                _controller?.seekTo(
                  _controller!.value.position + const Duration(seconds: 10),
                );
              },
              icon: const Icon(Icons.forward_10, color: Colors.white, size: 30),
            ),
          ],
        ),
        const SizedBox(height: 20),
        VideoProgressIndicator(
          _controller!,
          allowScrubbing: true,
          colors: VideoProgressColors(
            playedColor: Colors.red,
            bufferedColor: Colors.white.withOpacity(0.5),
            backgroundColor: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
