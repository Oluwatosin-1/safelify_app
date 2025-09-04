import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddContactPage extends StatefulWidget {
  final String contactType;

  const AddContactPage({super.key, required this.contactType});

  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  File? _selectedImage; // Selected image file
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // For showing loading indicator

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Directory Contact" , style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFFd0150f),
        elevation: 4, // Adds a shadow effect for a professional look
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFd0150f)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Directory Contact Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Name Field
              _buildTextFormField(
                controller: _nameController,
                labelText: 'Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Email Field
              _buildTextFormField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Address Field
              _buildTextFormField(
                controller: _addressController,
                labelText: 'Address',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              // Address Field
              _buildTextFormField(
                controller: _phoneController,
                labelText: 'Phone Number',
                icon: Icons.phone,
              ),
              const SizedBox(height: 16),
              // City Field
              _buildTextFormField(
                controller: _cityController,
                labelText: 'City',
                icon: Icons.location_city,
              ),
              const SizedBox(height: 16),
              // Website Field
              _buildTextFormField(
                controller: _websiteController,
                labelText: 'Website',
                icon: Icons.web,
              ),
              const SizedBox(height: 20),
              // Image Picker
              _buildImagePicker(),
              const SizedBox(height: 30),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      // Save the contact to Firestore
                      await FirebaseFirestore.instance
                          .collection('contacts')
                          .add({
                        'name': _nameController.text,
                        'email': _emailController.text,
                        'address': _addressController.text,
                        'contact': _phoneController.text,
                        'city': _cityController.text,
                        'website': _websiteController.text,
                        'image': _selectedImage?.path,
                        'type': widget.contactType,
                        'created_at': Timestamp.now(),
                      });
                      setState(() {
                        _isLoading = false;
                      });
                      Get.back();
                    }
                  },
                  icon: const Icon(Icons.save, color:Colors.white ),
                  label: const Text('Add Contact', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd0150f),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: const Color(0xFFd0150f)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0xFFd0150f)),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildImagePicker() {
    return Row(
      children: [
        // Circular image or placeholder
        _selectedImage != null
            ? CircleAvatar(
          radius: 50,
          backgroundImage: FileImage(_selectedImage!),
        )
            : CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.image, size: 40, color: Colors.white70),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo, color: Colors.white,),
          label: const Text("Select Image", style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFd0150f),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
