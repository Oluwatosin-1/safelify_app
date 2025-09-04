import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:safelify/main.dart';
import '../../config.dart';
import '../../model/admin_contact.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/emergency_contact_controller.dart';
import '../../telelegal/utils/colors.dart';
import '../../utils/global_helpers.dart';
import 'add_directories.dart';

class AdminContactsPage extends StatefulWidget {
  const AdminContactsPage({super.key, required this.contactType});

  final String contactType;

  @override
  State<AdminContactsPage> createState() => _AdminContactsPageState();
}

class _AdminContactsPageState extends State<AdminContactsPage> {
  final EmergencyContactController _emergencyContactController = Get.find();

  @override
  void initState() {
    _emergencyContactController.fetchAdminContacts(widget.contactType);
    super.initState();
  }

  final RefreshController _refreshController = RefreshController();
  RxString currentCity = ''.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          centerTitle: true,
          title: Text(
            widget.contactType == 'directories'
                ? locale.lblNationalDirectories
                : "${widget.contactType.capitalize} Contacts",
            style: const TextStyle(
              color: primaryColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          iconTheme: const IconThemeData(color: primaryColor),
        ),
        body: Column(
          children: [
            widget.contactType == 'directories'
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: kdPadding - 10),
                    child: TextFormField(
                      onChanged: (value) {
                        String val = value.trim().toLowerCase();
                        _emergencyContactController.search(val);
                      },
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        isDense: true,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    alignment: Alignment.centerRight,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Obx(() {
                        return PopupMenuButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            itemBuilder: (context) {
                              return _emergencyContactController
                                  .adminContacts.value!.cities
                                  .map(
                                    (e) => PopupMenuItem(
                                      onTap: () {
                                        if (currentCity.value == e.city) {
                                          currentCity.value = '';
                                          _emergencyContactController
                                              .fetchAdminContacts(
                                                  widget.contactType, e.city);
                                          return;
                                        }
                                        currentCity.value = e.city;
                                        _emergencyContactController
                                            .fetchAdminContacts(
                                                widget.contactType, e.city);
                                      },
                                      child: Text(e.city),
                                    ),
                                  )
                                  .toList();
                            },
                            child: Chip(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 10),
                              label: Text(currentCity.value.isEmpty
                                  ? "Cities"
                                  : currentCity.value),
                              labelStyle: const TextStyle(fontSize: 16),
                            ));
                      }),
                    ),
                  ),
            Obx(
              () {
                List<Contact> contacts = _emergencyContactController.isSearching
                    ? _emergencyContactController.searchedContacts.value
                    : _emergencyContactController
                            .adminContacts.value?.contacts ??
                        [];

                return _emergencyContactController.isLoading.value
                    ? getLoading()
                    : contacts.isEmpty
                        ? const Expanded(
                            child: Center(child: Text("No Contacts Found")))
                        : Expanded(
                            child: SmartRefresher(
                              controller: _refreshController,
                              onRefresh: () {
                                _emergencyContactController
                                    .fetchAdminContacts(widget.contactType);
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.all(kdPadding - 10),
                                itemCount: contacts.length,
                                itemBuilder: (context, index) {
                                  return EmergencyContactCard(
                                    contact: contacts[index],
                                  );
                                },
                              ),
                            ),
                          );
              },
            ),
          ],
        ), // Conditionally show the FAB if the logged-in user is "admin@safelify.org"
        floatingActionButton: _auth.currentUser?.email ==
                'tosin@skillsquared.com'
            ? FloatingActionButton(
                onPressed: () {
                  // Navigate to AddContactPage and pass the contactType
                  Get.to(() => AddContactPage(contactType: widget.contactType));
                },
                backgroundColor: primaryColor,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}

class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard({
    super.key,
    required this.contact,
  });
  final Contact contact;

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
            // Display the contact image from Firebase Storage URL
            CircleAvatar(
              radius: 25,
              backgroundImage: contact.image.isNotEmpty
                  ? FileImage(File(contact.image))
                      as ImageProvider // Use FileImage for local files
                  : const AssetImage('assets/images/avatar.png')
                      as ImageProvider, // Default image if no URL is provided
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.link_sharp,
                        size: 15,
                        color: Color(0xff434444),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (contact.website != null) {
                            launchUrl(Uri.parse(contact.website!));
                          }
                        },
                        child: Text(
                          contact.type == 'directories'
                              ? contact.website ?? 'N/A'
                              : 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (contact.email != 'Not Provided') {
                        launchUrl(Uri.parse('mailto:${contact.email}'));
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 15,
                          color: Color(0xff434444),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          contact.type == 'directories' ? contact.email : 'N/A',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              color: Colors.black54),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          contact.address,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              color: Color(0xff434444)),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.phone,
                          size: 15, color: Color(0xff434444)),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          if (contact.contact != null &&
                              contact.contact!.isNotEmpty) {
                            launchUrl(Uri.parse('tel:${contact.contact}'));
                          }
                        },
                        child: Text(
                          contact.contact,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse('tel:${contact.contact}'));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        shape: BoxShape.circle),
                    padding: const EdgeInsets.all(6.0),
                    child: Image.asset(
                      'assets/icons/phone.png',
                      height: 15,
                      width: 15,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
