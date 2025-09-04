// import 'dart:convert';
// import 'dart:developer';
// import 'package:http/http.dart' as http;

// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:get/get.dart';

// import '../screens/packages/verify_payment_page.dart';
// import '../config/config.dart';
// import '../model/plan.dart';
// import '../utils/api_helper.dart';
// import '../utils/global_helpers.dart';
// import 'auth_controller.dart';

// class PaymentController extends GetxController {
//   RxBool isLoading = false.obs;

//   RxList<Plan> plans = RxList();
//   RxMap<String, dynamic> subscription = RxMap();

//   RxString mySubscription = ''.obs;

//   fetchPlans() async {
//     try {
//       isLoading(true);
//       var response = await ApiHelper().postDataAuthenticated('getPlans', {});
//       plans.value = Plan.listFromMap(response['data']);
//     } catch (e) {
//       printError(info: e.toString());
//       showMightySnackBar(message: e.toString());
//     } finally {
//       isLoading(false);
//     }
//   }

//   subscribeToPlan(String planId) async {
//     if (planId == '1') return;
//     try {
//       isLoading(true);

//       var response =
//           await ApiHelper().postDataAuthenticated('paystackSubscription', {
//         'plan_id': planId,
//       });
//       subscription.value = RxMap.from(response);
//       Get.to(() => VerifyPaymentPage());
//     } catch (e) {
//       printError(info: e.toString());
//       showMightySnackBar(message: e.toString());
//     } finally {
//       isLoading(false);
//     }
//   }

//   verifyPayment() async {
//     try {
//       isLoading(true);
//       var response = await ApiHelper()
//           .getData('verify?reference=${subscription['reference']}', {});
//       showMightySnackBar(message: response['message']);
//       subscription.value = {};
//       await this.fetchMyPlan();
//     } catch (e) {
//       printError(info: e.toString());
//       showMightySnackBar(message: e.toString());
//     } finally {
//       isLoading(false);
//     }
//   }

//   verifyStripePayment(String planId, String paymentId) async {
//     try {
//       isLoading(true);
//       var response =
//           await ApiHelper().postDataAuthenticated('verifyStripePayment', {
//         'plan_id': planId,
//         'payment_id': paymentId,
//       });
//       showMightySnackBar(message: response['message']);
//       subscription.value = {};
//       await this.fetchMyPlan();
//     } catch (e) {
//       printError(info: e.toString());
//       showMightySnackBar(message: e.toString());
//     } finally {
//       isLoading(false);
//     }
//   }

//   fetchMyPlan() async {
//     try {
//       isLoading(true);
//       var response = await ApiHelper().postDataAuthenticated('viewYourPlan');
//       if (response['data'].length != 0)
//         mySubscription.value = response['data'][0]['plan_title'];
//     } catch (e) {
//       printError(info: e.toString());
//       showMightySnackBar(message: e.toString());
//     } finally {
//       isLoading(false);
//     }
//   }

//   Future<PaymentIntent?> stripePayment(String amount) async {
//     AuthController _authController = Get.find();

//     Uri url = Uri.parse('https://api.stripe.com/v1/payment_intents');

//     http.Response response = await http.post(
//       url,
//       headers: {
//         "Authorization": "Bearer $kStripeKey",
//         "Content-Type": "application/x-www-form-urlencoded"
//       },
//       body: {
//         'amount': '${amount}00',
//         'currency': 'usd',
//         'description': 'International Plan',
//         'receipt_email': _authController.user.value!.email,
//       },
//     );

//     log(response.body);

//     if (response.statusCode == 200) {
//       var data = jsonDecode(response.body);

//       return initPaymentSheet(data['client_secret']);
//     } else {
//       return null;
//     }
//   }

//   //init payment sheet
//   Future<PaymentIntent?> initPaymentSheet(String clientSecret) async {
//     try {
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: clientSecret,
//           style: ThemeMode.dark,
//           appearance: const PaymentSheetAppearance(
//             colors: PaymentSheetAppearanceColors(
//               primary: Colors.black,
//             ),
//           ),
//           merchantDisplayName: 'Safelify',
//         ),
//       );

//       await Stripe.instance.presentPaymentSheet();

//       PaymentIntent intent =
//           await Stripe.instance.retrievePaymentIntent(clientSecret);

//       log(intent.toJson().toString());

//       if (intent.status == PaymentIntentsStatus.Succeeded) {
//         showMightySnackBar(message: 'Payment successful');
//         return intent;
//       } else {
//         return null;
//       }
//     } catch (e) {
//       log(e);
//       if (e is StripeException) {
//         StripeException stripeEx = e;
//         showMightySnackBar(
//             message: stripeEx.error.localizedMessage ?? 'Payment Error');
//       }
//       return null;
//     }
//   }
// }
