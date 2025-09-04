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