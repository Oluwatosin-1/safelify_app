import 'package:flutter/cupertino.dart';
import 'package:safelify/utils/colors.dart';

const APP_NAME = 'SafeLify';
const APP_FIRST_NAME = 'Safe';
const APP_SECOND_NAME = 'Lify';
const APP_NAME_TAG_LINE = 'Clinic and Patient Management App';

// LIVE
const DOMAIN_URL = 'https://telehealthportal.safelify.org';

const BASE_URL = '$DOMAIN_URL/wp-json/';

const IQONIC_PACKAGE_NAME =
    "com.safelify.org"; // Do not change this Package Name.
const DEFAULT_LANGUAGE = 'en';
var COPY_RIGHT_TEXT =
    '© ${DateTime.now().year}. Made with ♡ by Safelify Design';

const TERMS_AND_CONDITION_URL = '';
const PRIVACY_POLICY_URL = '';
const SUPPORT_URL = '';
const CODE_CANYON_URL = '';
const MAIL_TO = 'admin@safelify.com';

const APPSTORE_APP_LINK = '';

const STRIPE_CURRENCY_CODE = 'USD';
const STRIPE_MERCHANT_COUNTRY_CODE = 'US';

const STRIPE_URL = 'https://api.stripe.com/v1/payment_intents';

// Pagination
const PER_PAGE = 20;
const kdBorderRadius = 30.0;
const kdPadding = 28.0;
Color kcSecondaryGradient = const Color(0xffFF6C69);
Color kcBackGroundGradient = const Color(0xffF5F5F5);
Color kcSecondaryColor = const Color.fromARGB(255, 99, 99, 99);
LinearGradient kcVerticalGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomRight,
  colors: [
    primaryColor,
    kcSecondaryGradient,
  ],
);
const kTermAndConditionsURL = 'https://admin.safelify.org/terms';
const kPrivacyPolicyURL = 'https://admin.safelify.org/privacy-policy';

const kAgoraAppID = '210d99c7fe914b75886c76e3b078c840';
const kAgoraChannel = 'one';
const kAgoraToken =
    '007eJxTYEj5Y/ew4IOSTcnUoJd756yYOOVgdJCk80pZ88Jymy9JbOsUGIwMDVIsLZPN01ItDU2SzE0tLMySzc1SjZMMzC2SLUwM1AL9UxoCGRkM6sSYGRkgEMRnZsjPS2VgAAACbh0D';

const kStripeKey =
    "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";
// const kStripeKey =
//     "sk_test_51NWLjDAYJ1N6q8Cs9jtrQbS7cg5vnAEEZSdvAFuhUbrmnGWyHgFvh8e9SAtkAG0S0jJ3CoDHWfN9lk8jjcB5MrUN00KqujvrXD";
// const kStripePubKey =
//     "pk_test_51NWLjDAYJ1N6q8Cs9Co7rqtlHiXCT0LPFxXmImz4kut7o4pZnTJMo4P49AQ1gWL2XlJo1qN2D9BPVbIM8mZB2Tf200Mzloi5Nc";
const kStripePubKey =
    "pk_live_51NWLjDAYJ1N6q8CsRGH0e6933jB06RGqOFeHW4XNbI1a7K65QOAUyw4S4Yl1UW1JNJXxvIuX0KZnhkajHrOBqo2b009ri5yNq2";
