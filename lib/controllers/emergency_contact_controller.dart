import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nb_utils/nb_utils.dart';
import '../model/admin_contact.dart';
import '../model/emergency_contact.dart';
import '../utils/global_helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart'; // Add this for post-frame callback

class EmergencyContactController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isContactBeingAdded = false.obs;
  final RxBool _isSearching = false.obs;
  bool get isSearching => _isSearching.value;

  RxList<Contact> contacts = RxList([]);
  RxList<Contact> filteredContacts = RxList([]);
  Rx<AdminContacts?> adminContacts = Rx(null);
  Rx<List<Contact>> searchedContacts = Rx([]);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    // Defer fetchEmergencyContacts to ensure UI is ready
    SchedulerBinding.instance.addPostFrameCallback((_) {
      fetchEmergencyContacts();
    });
  }

  // Fetch contacts specific to the current user
  Future<void> fetchEmergencyContacts() async {
    isLoading(true);
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        log('User not authenticated. Cannot fetch emergency contacts.');
        // Avoid showing snackbar in onInit; log instead or handle later
        return;
      }

      var snapshot = await _firestore
          .collection('emergencyContacts')
          .where('userId', isEqualTo: userId)
          .get();

      contacts.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return Contact.fromMap({
          'id': doc.id,
          'name': data['name'] ?? '',
          'contact': data['contact'] ?? '',
          'email': data['email'] ?? '',
          'address': data['address'] ?? '',
          'type': data['type'] ?? '',
          'image': data['image'] ?? '',
          'city_id': data['city_id'] ?? '',
          'city': data['city'] ?? '',
          'website': data['website'] ?? '',
        });
      }).toList();
      filteredContacts.value = contacts;
    } catch (e) {
      log('Error fetching emergency contacts: $e');
      // Defer snackbar display to ensure context is available
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          showMightySnackBar(message: "Failed to fetch contacts.");
        } else {
          log('Cannot show snackbar: Context is null');
        }
      });
    } finally {
      isLoading(false);
    }
  }

  // Filter contacts by type (Family, Friends, Work)
  void filterContactsByType(String type) {
    filteredContacts.value = (type.isEmpty || type == "All")
        ? contacts
        : contacts.where((contact) => contact.type == type).toList();
  }

  Future<void> addContact({
    required String name,
    required String number,
    required String address,
    required String email,
    required String type,
  }) async {
    isContactBeingAdded(true);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (Get.context != null) {
          showMightySnackBar(message: "User not authenticated.");
        }
        return;
      }

      if (_validateContactFields(name, number, email, address)) {
        final contactData = {
          'name': name,
          'contact': number,
          'address': address,
          'email': email,
          'type': type,
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('emergencyContacts').add(contactData);
        Get.back(); // Close the popup after successful addition
        if (Get.context != null) {
          showMightySnackBar(message: "Contact added successfully.");
        }
        await fetchEmergencyContacts(); // Refresh the contacts list
      }
    } catch (e) {
      log("Error adding contact: ${e.toString()}");
      if (Get.context != null) {
        showMightySnackBar(message: "Failed to add contact. Please try again.");
      }
    } finally {
      isContactBeingAdded(false);
    }
  }

  // Validate contact fields
  bool _validateContactFields(String name, String number, String email, String address) {
    if (name.isEmpty || number.isEmpty || email.isEmpty || address.isEmpty) {
      if (Get.context != null) {
        showMightySnackBar(message: "All fields are required.");
      }
      return false;
    }
    return true;
  }

  // Update an existing contact
  Future<void> updateContact({
    required String name,
    required String number,
    required String id,
    required String address,
    required String email,
    required String type,
  }) async {
    isContactBeingAdded(true);
    try {
      await _firestore.collection('emergencyContacts').doc(id).update({
        'name': name,
        'contact': number,
        'address': address,
        'email': email,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.back();
      if (Get.context != null) {
        showMightySnackBar(message: "Contact updated successfully.");
      }
      await fetchEmergencyContacts(); // Refresh contacts list
    } catch (e) {
      log('Error updating contact: $e');
      if (Get.context != null) {
        showMightySnackBar(message: "Failed to update contact.");
      }
    } finally {
      isContactBeingAdded(false);
    }
  }

  // Delete a contact
  Future<void> deleteContact(String id) async {
    isContactBeingAdded(true);
    try {
      await _firestore.collection('emergencyContacts').doc(id).delete();
      if (Get.context != null) {
        showMightySnackBar(message: "Contact deleted successfully.");
      }
      await fetchEmergencyContacts(); // Refresh contacts list
    } catch (e) {
      log('Error deleting contact: $e');
      if (Get.context != null) {
        showMightySnackBar(message: "Failed to delete contact.");
      }
    } finally {
      isContactBeingAdded(false);
    }
  }

  // Search for contacts in the adminContacts list
  void search(String query) {
    if (kDebugMode) {
      log(query);
    }
    if (query.isEmpty) {
      searchedContacts.value = adminContacts.value?.contacts ?? [];
      _isSearching(false);
    } else {
      searchedContacts.value = adminContacts.value?.contacts
          .where((contact) => contact
          .toMap()
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList() ??
          [];
      _isSearching(true);
    }
    if (kDebugMode) {
      log(searchedContacts.value.length);
    }
  }

  Future<void> fetchAdminContacts(String type, [String city = '']) async {
    isLoading(true);
    try {
      var snapshot = await _firestore
          .collection('contacts')
          .where('type', isEqualTo: type)
          .get();

      if (snapshot.docs.isEmpty) {
        adminContacts.value = AdminContacts(cities: [], contacts: []);
        return;
      }

      adminContacts.value = AdminContacts(
        cities: [], // Update this if you have city data
        contacts: snapshot.docs.map((doc) {
          final data = doc.data();
          return Contact.fromMap({
            'id': doc.id,
            'name': data['name'] ?? '',
            'contact': data['contact'] ?? '',
            'email': data['email'] ?? '',
            'address': data['address'] ?? '',
            'type': data['type'] ?? '',
            'image': data['image'] ?? '',
            'city_id': data['city_id'] ?? '',
            'city': data['city'] ?? '',
            'website': data['website'] ?? '',
          });
        }).toList(),
      );

      if (city.isNotEmpty) {
        adminContacts.value!.contacts = adminContacts.value!.contacts
            .where((contact) => contact.city == city)
            .toList();
      }
    } catch (e) {
      log('Error fetching admin contacts: $e');
      if (Get.context != null) {
        showMightySnackBar(message: "Failed to fetch admin contacts.");
      }
    } finally {
      isLoading(false);
    }
  }
}

// Conversion helper function for `EmergencyContact`
EmergencyContact convertToEmergencyContact(Contact contact) {
  return EmergencyContact(
    id: contact.id,
    name: contact.name,
    contact: contact.contact,
    email: contact.email,
    address: contact.address,
    type: contact.type,
    image: contact.image,
  );
}