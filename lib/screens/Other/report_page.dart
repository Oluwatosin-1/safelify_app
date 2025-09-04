import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/app_controller.dart';
import '../../model/report_category.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/colors.dart';
import '../../utils/global_helpers.dart';
import '../../controllers/report_controller.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  Rx<File?> selectFile = Rx(null);
  final AuthController _authController = Get.put(AuthController());
  final ReportController _reportController = Get.put(ReportController());
  final GlobalKey<FormState> _form = GlobalKey();
  final TextEditingController _reportEditingController =
  TextEditingController();
  final TextEditingController _categoryEditingController =
  TextEditingController();
  final Rx<ReportCategory?> _selectedCategory = Rx(null);

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      await _reportController.fetchReportCategories();
    } catch (e) {
      showMightySnackBar(message: "Failed to fetch categories: $e");
    }
  }

  Future<String?> _getIdToken() async {
    return await _authController.getIdToken();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(
                centerTitle: true,
                title: const Text(
                  'Report',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                elevation: 0,
                backgroundColor: Colors.grey.shade100,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: primaryColor),
                  onPressed: () {
                    AppController appController = Get.find();
                    appController.currentBottomNavIndex.value = 0;
                  },
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 15,
                                  backgroundImage:
                                  AssetImage('assets/images/avatar.png'),
                                ),
                                const SizedBox(width: 6),
                                Obx(() {
                                  return Text(
                                    '${_authController.firstName.value} ${_authController.lastName.value}'
                                        .trim(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text("Category :"),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Obx(() {
                                    if (_reportController.categories.isEmpty) {
                                      return const Text("No categories available");
                                    }
                                    return DropdownButton<ReportCategory>(
                                      isExpanded: true,
                                      value: _selectedCategory.value,
                                      hint: const Text("Select a category"),
                                      items: _reportController.categories
                                          .map((category) {
                                        return DropdownMenuItem<ReportCategory>(
                                          value: category,
                                          child: Text(category.category),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        _selectedCategory.value = value;
                                      },
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.18,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  key: _form,
                                  child: TextFormField(
                                    controller: _reportEditingController,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Title is required';
                                      }
                                      return null;
                                    },
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter Text...',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (_form.currentState!.validate()) {
                                      String? idToken = await _getIdToken();
                                      if (idToken != null) {
                                        File? selectedFile = selectFile.value;

                                        if (selectedFile == null) {
                                          showMightySnackBar(
                                            message:
                                            'Please select an image or video file.',
                                          );
                                          return;
                                        }

                                        bool isVideo = selectedFile.path.endsWith('.mp4');

                                        _reportController.isLoading(true);
                                        try {
                                          await _reportController.addReport(
                                            imageFile: !isVideo
                                                ? selectedFile
                                                : null,
                                            videoFile: isVideo
                                                ? selectedFile
                                                : null,
                                            title: _reportEditingController.text,
                                            token: idToken,
                                            catId: _selectedCategory.value?.id ?? '',
                                            userId: _authController.user.value?.uid ?? '',
                                          );

                                          _reportEditingController.clear();
                                          selectFile.value = null;
                                          _selectedCategory.value = null;

                                          showMightySnackBar(
                                              message: 'Report submitted successfully');
                                        } catch (e) {
                                          showMightySnackBar(
                                              message: 'Failed to submit report: $e');
                                        } finally {
                                          _reportController.isLoading(false);
                                        }
                                      } else {
                                        showMightySnackBar(
                                            message: 'Failed to authenticate user.');
                                      }
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 8),
                                      child: Text(
                                        'Report',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () async {
                                    ImagePicker picker = ImagePicker();
                                    XFile? xFile = await picker.pickImage(
                                        source: ImageSource.gallery);
                                    if (xFile != null) {
                                      selectFile.value = File(xFile.path);
                                    }
                                  },
                                  child: selectFile.value != null &&
                                      !selectFile.value!.path.endsWith('.mp4')
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      selectFile.value!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                      : Container(
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () async {
                                    if (selectFile.value != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Retrying video selection...')),
                                      );
                                    }
                                    ImagePicker picker = ImagePicker();
                                    XFile? xFile = await picker.pickVideo(source: ImageSource.camera);
                                    if (xFile != null) {
                                      selectFile.value = File(xFile.path);
                                    }
                                  },

                                  child: selectFile.value != null &&
                                      selectFile.value!.path.endsWith('.mp4')
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: const Icon(
                                      Icons.refresh,
                                      color: Colors.orange,
                                    ),
                                  )
                                      : Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Icon(
                                        Icons.videocam_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: Obx(() {
                if (_authController.user.value?.email == 'tosin@skillsquared.com') {
                  return FloatingActionButton(
                    backgroundColor: Colors.green,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Add New Category'),
                            content: TextFormField(
                              controller: _categoryEditingController,
                              decoration: const InputDecoration(
                                labelText: 'Category Name',
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Add'),
                                onPressed: () async {
                                  await _reportController
                                      .addCategory(_categoryEditingController.text);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.add),
                  );
                } else {
                  return Container();
                }
              }),
            ),
            if (_reportController.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text(
                        'Uploading...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
