import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:safelify/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../components/loader_widget.dart';
import '../../../../network/auth_repository.dart';
import '../../../../utils/common.dart';

class ViewPatientScreen extends StatefulWidget {
  final int? userId;

  ViewPatientScreen({this.userId});

  @override
  _ViewPatientScreenState createState() => _ViewPatientScreenState();
}

class _ViewPatientScreenState extends State<ViewPatientScreen> {
  DateTime? birthDate;
  String? bloodGroup;
  String? userLogin = "";

  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController contactNumberCont = TextEditingController();
  TextEditingController dOBCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();
  TextEditingController cityCont = TextEditingController();
  TextEditingController countryCont = TextEditingController();
  TextEditingController stateCont = TextEditingController();
  TextEditingController postalCodeCont = TextEditingController();
  TextEditingController genderCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    appStore.setLoading(true);

    await getSingleUserDetailAPI(widget.userId).then((value) {
      appStore.setLoading(false);
      firstNameCont.text = value.firstName.validate();
      lastNameCont.text = value.lastName.validate();
      emailCont.text = value.userEmail.validate();
      contactNumberCont.text = value.mobileNumber.validate();
      addressCont.text = value.address.validate();
      cityCont.text = value.city.validate();
      countryCont.text = value.country.validate();
      postalCodeCont.text = value.postalCode.validate();
      userLogin = value.userLogin.validate();
      genderCont.text = value.gender.validate();
      dOBCont.text = value.dob.validate();
      if (!value.dob.isEmptyOrNull) birthDate = DateTime.parse(value.dob.validate());
      if (!value.bloodGroup.isEmptyOrNull) bloodGroup = value.bloodGroup.validate();
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('View Patient Details', textColor: Colors.white),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Basic Information", style: boldTextStyle(size: 20)),
                Divider(),
                TextFormField(
                  controller: firstNameCont,
                  decoration: inputDecoration(context: context, labelText: 'First Name'),
                  readOnly: true,
                ),
                16.height,
                TextFormField(
                  controller: lastNameCont,
                  decoration: inputDecoration(context: context, labelText: 'Last Name'),
                  readOnly: true,
                ),
                16.height,
                TextFormField(
                  controller: emailCont,
                  decoration: inputDecoration(context: context, labelText: 'Email'),
                  readOnly: true,
                ),
                16.height,
                TextFormField(
                  controller: contactNumberCont,
                  decoration: inputDecoration(context: context, labelText: 'Contact Number'),
                  readOnly: true,
                ),
                16.height,
                TextFormField(
                  controller: dOBCont,
                  decoration: inputDecoration(context: context, labelText: 'Date of Birth'),
                  readOnly: true,
                ),
                16.height,
                TextFormField(
                  controller: genderCont,
                  decoration: inputDecoration(context: context, labelText: 'Gender'),
                  readOnly: true,
                ),
                16.height,
                Text("Address", style: boldTextStyle(size: 20)),
                Divider(),
                TextFormField(
                  controller: addressCont,
                  decoration: inputDecoration(context: context, labelText: 'Address'),
                  readOnly: true,
                ),
                16.height,
                TextFormField(
                  controller: cityCont,
                  decoration: inputDecoration(context: context, labelText: 'City'),
                  readOnly: true,
                ),
                16.height,
                TextFormField(
                  controller: countryCont,
                  decoration: inputDecoration(context: context, labelText: 'Country'),
                  readOnly: true,
                ),
                16.height,
                TextFormField(
                  controller: postalCodeCont,
                  decoration: inputDecoration(context: context, labelText: 'Postal Code'),
                  readOnly: true,
                ),
              ],
            ),
          ),
          Observer(
            builder: (_) => LoaderWidget().visible(appStore.isLoading),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Close'),
        ),
      ),
    );
  }
}
