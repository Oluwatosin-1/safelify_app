import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:safelify/utils/images.dart';
import '../../config.dart';
import '../../controllers/emergency_contact_controller.dart';
import '../../model/emergency_contact.dart';
import '../../utils/colors.dart';
import '../../utils/global_helpers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'; // For handling phone number with country code

class EmergencyContactPage extends StatelessWidget {
  EmergencyContactPage({super.key});

  // Initialize the controller
  final EmergencyContactController _emergencyContactController = Get.put(EmergencyContactController());

  final RefreshController _refreshController = RefreshController();

  // List of filter options (assuming these are types of contacts)
  final List<String> filterOptions = ["All", "Family", "Friends", "Work"];

  // To keep track of selected filter
  final RxString selectedFilter = "All".obs;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            "Emergency Contact",
            style: TextStyle(
              color: Colors.red,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: Obx(() {
          return Column(
            children: [
              _buildFilterRow(),
              Expanded(
                child: _emergencyContactController.isLoading.value
                    ? getLoading()
                    : SmartRefresher(
                  controller: _refreshController,
                  onRefresh: () {
                    _emergencyContactController.fetchEmergencyContacts().then((_) {
                      _refreshController.refreshCompleted();
                    });
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(kdPadding - 10),
                    itemCount: _emergencyContactController.filteredContacts.isEmpty
                        ? 1
                        : _emergencyContactController.filteredContacts.length + 1, // +1 for add button
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      if (_emergencyContactController.filteredContacts.isEmpty) {
                        if (index == 0) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('No emergency contacts found.'),
                                const SizedBox(height: 20),
                                _buildAddContactButton(context),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      if (index == _emergencyContactController.filteredContacts.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: _buildAddContactButton(context),
                        );
                      }

                      var contact = convertToEmergencyContact(
                          _emergencyContactController.filteredContacts[index]);

                      return EmergencyContactCard(contact: contact);
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Build filter row
  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: filterOptions.map((option) {
          return _buildFilterOption(option, selectedFilter.value == option, () {
            selectedFilter.value = option;
            _emergencyContactController.filterContactsByType(option);
          });
        }).toList(),
      ),
    );
  }

  Widget _buildFilterOption(String text, bool isSelected, void Function() onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : const Color(0xffD9D9D9),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: isSelected ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }

  // Function to handle adding a contact button
  Widget _buildAddContactButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await showAddUpdateContactPopup(context: context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(11),
        ),
        height: 40,
        width: MediaQuery.of(context).size.width * 0.4,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 20, color: Colors.white),
            SizedBox(width: 5),
            Text("Add", style: TextStyle(fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

Future<void> showAddUpdateContactPopup({
  required BuildContext context,
  EmergencyContact? contact,
}) async {
  final GlobalKey<FormState> addContactForm = GlobalKey<FormState>();
  final TextEditingController contactNameEditingController = TextEditingController(text: contact?.name);
  final TextEditingController addressEditingController = TextEditingController(text: contact?.address);
  final TextEditingController emailEditingController = TextEditingController(text: contact?.email);
  final TextEditingController contactNumberEditingController = TextEditingController();

  String selectedContactType = contact?.type ?? 'Family';
  final List<String> contactTypes = ['Family', 'Friend', 'Work'];

  await showDialog(
    context: context,
    builder: (context) {
      final EmergencyContactController emergencyContactController = Get.find();

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          "${contact == null ? 'Add' : 'Edit'} Emergency Contact",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        content: Form(
          key: addContactForm,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: contactNameEditingController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? "Please enter contact name." : null,
                ),
                const SizedBox(height: 15),

                // Country Code and Phone Number
                InternationalPhoneNumberInput(
                  onInputChanged: (number) {
                    contactNumberEditingController.text = number.phoneNumber!;
                  },
                  initialValue: PhoneNumber(isoCode: 'US', phoneNumber: contact?.contact),
                  inputDecoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? "Please enter phone number." : null,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: emailEditingController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) => GetUtils.isEmail(value!.trim()) ? null : 'Invalid email address.',
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: addressEditingController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? "Please enter an address." : null,
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: selectedContactType,
                  items: contactTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) => selectedContactType = value!,
                  decoration: InputDecoration(
                    labelText: "Contact Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(() {
                        return emergencyContactController.isContactBeingAdded.value
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                          onPressed: () {
                            if (addContactForm.currentState!.validate()) {
                              if (contact == null) {
                                emergencyContactController.addContact(
                                  name: contactNameEditingController.text,
                                  number: contactNumberEditingController.text,
                                  address: addressEditingController.text,
                                  email: emailEditingController.text.trim(),
                                  type: selectedContactType,
                                );
                              } else {
                                emergencyContactController.updateContact(
                                  id: contact.id,
                                  name: contactNameEditingController.text,
                                  number: contactNumberEditingController.text,
                                  address: addressEditingController.text,
                                  email: emailEditingController.text.trim(),
                                  type: selectedContactType,
                                );
                              }
                            }
                          },
                          child: Text(contact == null ? 'Add' : 'Edit'),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// EmergencyContactCard widget
class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard({
    super.key,
    required this.contact,
  });

  final EmergencyContact contact;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: contact.image != null && contact.image!.isNotEmpty
                  ? NetworkImage(contact.image!)
                  : const AssetImage(ic_patient3) as ImageProvider,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    contact.contact,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    contact.address,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  GestureDetector(
                    onTap: () {
                      _launchEmail(contact.email);
                    },
                    child: Text(
                      contact.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    showAddUpdateContactPopup(context: context, contact: contact);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    Get.find<EmergencyContactController>().deleteContact(contact.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String? email) async {
    if (email != null && email.isNotEmpty) {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (Get.context != null) {
          showMightySnackBar(message: 'Could not launch email client');
        }
      }
    }
  }
}