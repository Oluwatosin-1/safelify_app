import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:safelify/config.dart';
import 'package:safelify/main.dart';
import 'package:safelify/model/confirm_appointment_response_model.dart';
import 'package:safelify/model/stripe_pay_model.dart';
import 'package:safelify/network/bill_repository.dart';
import 'package:safelify/network/network_utils.dart';
import 'package:safelify/screens/doctor/fragments/appointment_fragment.dart';
import 'package:safelify/utils/colors.dart';
import 'package:safelify/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class StripeServices {
  static late ConfirmAppointmentResponseModel appointmentBookingData;
  bool isTest = false;
  static late Function(bool) paymentStatusBool;

  init({
    required ConfirmAppointmentResponseModel data,
    required bool isTest,
    required Function(bool) paymentStatusCallback,
  }) async {
    appointmentBookingData = data;
    paymentStatusBool = paymentStatusCallback;

    this.isTest = isTest;
    appStore.setLoading(true);

    // Safely assign stripe publishable key
    Stripe.publishableKey =
        data.orderData?.stripePublishableKey.validate() ?? '';
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';

    await Stripe.instance.applySettings().catchError((e) {
      toast(e.toString(), print: true);
      appStore.setLoading(false);
      throw e.toString();
    }).whenComplete(() {
      stripePay();
    });
  }

  //StripePayment
  void stripePay() async {
    num amount =
        appointmentBookingData.orderData?.amount ?? 0.0; // Handle null values
    String currencyCode =
        appointmentBookingData.orderData?.currencyCode.validate() ??
            'usd'; // Default to USD if null
    String stripeSecretKey =
        appointmentBookingData.orderData?.stripeSecretKey.validate() ?? '';

    // Convert amount to an integer in the smallest unit (e.g., cents for USD)
    int convertedAmount =
        (amount).round(); // This ensures no floating-point errors

    http.Request request =
        http.Request(HttpMethodType.POST.name, Uri.parse(STRIPE_URL));

    request.bodyFields = {
      'amount': '$convertedAmount',
      'currency': currencyCode,
      'description': APP_NAME_TAG_LINE,
      'automatic_payment_methods[enabled]': 'true',
      'shipping[name]': "Asif Younas",
      'shipping[address][line1]': "Khanewal",
      'shipping[address][postal_code]': "65000",
      'shipping[address][city]': "Khanewal",
      'shipping[address][state]': "PK",
      'shipping[address][country]': "PAK"
    };

    request.headers.addAll(buildHeaderTokens(extraKeys: {
      'isStripePayment': true,
      'stripeKeyPayment': stripeSecretKey,
      // 'Content-Type': 'application/x-www-form-urlencoded',
      // 'Content-Type': 'application/json'
    }));

    appStore.setLoading(true);

    await request.send().then((value) {
      http.Response.fromStream(value).then((response) async {
        print("========");
        print(response.body);
        print("========");
        if (response.statusCode.isSuccessful()) {
          StripePayModel res =
              StripePayModel.fromJson(await handleResponse(response));

          SetupPaymentSheetParameters setupPaymentSheetParameters =
              SetupPaymentSheetParameters(
            paymentIntentClientSecret: res.clientSecret.validate(),
            style: appThemeMode,
            appearance: PaymentSheetAppearance(
              colors: PaymentSheetAppearanceColors(primary: appPrimaryColor),
            ),
            applePay: const PaymentSheetApplePay(
                merchantCountryCode: STRIPE_MERCHANT_COUNTRY_CODE),
            googlePay: PaymentSheetGooglePay(
              merchantCountryCode: STRIPE_MERCHANT_COUNTRY_CODE,
              testEnv: isTest,
            ),
            merchantDisplayName: APP_NAME,
            customerId: userStore.userId.toString(),
            customerEphemeralKeySecret: null,
            setupIntentClientSecret: res.clientSecret.validate(),
            billingDetails: BillingDetails(
              name: userStore.userDisplayName,
              email: userStore.userEmail,
            ),
          );

          try {
            await Stripe.instance
                .initPaymentSheet(
                    paymentSheetParameters: setupPaymentSheetParameters)
                .then((value) async {
              await Stripe.instance.presentPaymentSheet().then((val) async {
                toast(
                    "Wait for a while, we're completing your appointment booking");
                savePaymentResponse(
                    paymentStatus: ConstantKeys.paymentCapturedKey);
              });
            });
          } catch (e) {
            toast(e.toString());
          }
        } else if (response.statusCode == 400) {
          savePaymentResponse(paymentStatus: ConstantKeys.paymentFailedKey);
          toast(locale.lblStripeTestCredential);
        } else {
          toast(parseStripeError(response.body), print: true);
        }
      });
    }).catchError((e) {
      savePaymentResponse(paymentStatus: ConstantKeys.paymentFailedKey);
      appStore.setLoading(false);
      toast(e.toString(), print: true);
      throw e.toString();
    });
  }

  savePaymentResponse({required String paymentStatus}) {
    Map<String, dynamic> request = {
      "status": paymentStatus,
      "appointment_id": appointmentBookingData.appointmentId,
    };

    appStore.setLoading(true);

    savePayment(paymentResponse: request).then((v) {
      appointmentStreamController.add(true);
      toast(locale.lblAppointmentBookedSuccessfully);
      appStore.setLoading(false);
      appStore.setPaymentMode('');
      paymentStatusBool.call(true);
      multiSelectStore.setTaxData(null);
    }).catchError((e) {
      appStore.setLoading(false);
      toast('Payment Failed');
    });
  }
}

StripeServices stripeServices = StripeServices();
