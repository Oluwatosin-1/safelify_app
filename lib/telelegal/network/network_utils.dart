import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:safelify/telelegal/config.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/model/base_response.dart';
import 'package:safelify/telelegal/network/auth_repository.dart';
import 'package:safelify/telelegal/utils/common.dart';
import 'package:safelify/telelegal/utils/constants.dart';
import 'package:safelify/telelegal/utils/constants/app_constants.dart';
import 'package:safelify/telelegal/utils/constants/user_detail_keys.dart';
import 'package:safelify/telelegal/utils/woo_commerce/query_string.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:crypto/crypto.dart' as crypto;

Map<String, String> buildHeaderTokens(
    {Map? extraKeys,
    bool requiredNonce = false,
    bool requiredToken = true,
    bool isOAuth = false}) {
  if (extraKeys == null) {
    extraKeys = {};
    extraKeys.putIfAbsent(ConstantKeys.isStripePayKey, () => false);
  }
  Map<String, String> header = {
    HttpHeaders.cacheControlHeader: ApiHeaders.cacheControlHeader,
  };

  if (appStore.isLoggedIn &&
      extraKeys.containsKey(ConstantKeys.isStripePayKey) &&
      extraKeys[ConstantKeys.isStripePayKey]) {
    header.putIfAbsent(HttpHeaders.contentTypeHeader,
        () => ApiHeaders.contentTypeHeaderWWWForm);
    if (requiredToken)
      header.putIfAbsent(HttpHeaders.authorizationHeader,
          () => 'Bearer ${extraKeys![ConstantKeys.stripeKeyPaymentKey]}');
  } else {
    header.putIfAbsent(HttpHeaders.contentTypeHeader,
        () => ApiHeaders.contentTypeHeaderApplicationJson);
    header.putIfAbsent(HttpHeaders.acceptHeader, () => ApiHeaders.acceptHeader);
    if (isOAuth) {
      header.putIfAbsent(ApiHeaders.accessControlAllowHeader, () => '*');
      header.putIfAbsent(ApiHeaders.accessControlAllowOriginHeader, () => '*');
    }
    if (appStore.isLoggedIn && requiredToken) {
      header.putIfAbsent(
          HttpHeaders.cookieHeader.toString().capitalizeFirstLetter(),
          () => getStringAsync(ApiResponseKeys.cookieHeaderKey));
      header.putIfAbsent(
          ApiHeaders.headerNonceKey, () => getStringAsync(ApiHeaders.apiNonce));
    }
  }

  if (requiredNonce)
    header.putIfAbsent(ApiHeaders.headerStoreNonceKey,
        () => getStringAsync(ApiHeaders.wcNonceKey));
  header.putIfAbsent(
      ApiHeaders.appVersionKey, () => getStringAsync(AppKeys.appVersionKey));

  return header;
}

Uri buildBaseUrl(String endPoint,
    {String requestMethod = '', bool isOAuth = false}) {
  Uri url =
      Uri.parse(_getOAuthURL(requestMethod: requestMethod, endpoint: endPoint));

  if (endPoint.startsWith('http'))
    url = Uri.parse(
        _getOAuthURL(requestMethod: requestMethod, endpoint: endPoint));
  else if (isOAuth) {
    url = Uri.parse(
        _getOAuthURL(requestMethod: requestMethod, endpoint: endPoint));
  } else
    url = Uri.parse(
        _getOAuthURL(requestMethod: requestMethod, endpoint: endPoint));

  return url;
}

Future<Response> buildHttpResponse(
  String endPoint, {
  HttpMethod method = HttpMethod.GET,
  Map? request,
  bool isOauth = false,
  bool headerRequired = true,
  bool requiredNonce = false,
  bool requiredToken = true,
}) async {
  if (await isNetworkAvailable()) {
    var headers = buildHeaderTokens(
        requiredNonce: requiredNonce,
        requiredToken: requiredToken,
        isOAuth: isOauth);

    Uri url = buildBaseUrl(endPoint,
        requestMethod: method.toString(), isOAuth: isOauth);
    print("Base URL Tele $url");

    Response response;

    if (method == HttpMethod.POST) {
      response = await http.post(url,
          body: jsonEncode(request), headers: headerRequired ? headers : {});
    } else if (method == HttpMethod.DELETE) {
      response = await delete(url, headers: headerRequired ? headers : {});
    } else if (method == HttpMethod.PUT) {
      response = await put(url,
          body: jsonEncode(request), headers: headerRequired ? headers : {});
    } else if (method == HttpMethod.PATCH) {
      response = await put(url,
          body: jsonEncode(request), headers: headerRequired ? headers : {});
    } else {
      response = await get(url, headers: headerRequired ? headers : {});
    }

    apiPrint(
      url: url.toString(),
      endPoint: endPoint,
      headers: jsonEncode(headers),
      hasRequest: method == HttpMethod.POST || method == HttpMethod.PUT,
      request: jsonEncode(request),
      statusCode: response.statusCode,
      responseHeader: jsonEncode(response.headers),
      responseBody: response.body,
      methodtype: method.name,
    );

    if (appStore.isLoggedIn &&
        response.statusCode == 403 &&
        (jsonDecode(response.body)['code'] == "rest_cookie_invalid_nonce" ||
            jsonDecode(response.body)['message'] == "Cookie check failed")) {
      return await regenerateCookie().then((value) async {
        return await buildHttpResponse(
          endPoint,
          method: method,
          request: request,
          requiredNonce: requiredNonce,
          isOauth: isOauth,
          requiredToken: requiredToken,
          headerRequired: headerRequired,
        );
      }).catchError((e) {
        throw e.toString();
      });
    } else {
      return response;
    }
  } else {
    throw locale.lblNoInternetMsg;
  }
}

Future handleResponse(Response response) async {
  if (!await isNetworkAvailable()) {
    throw errorInternetNotAvailable;
  }
  if (response.statusCode == 403) {
    appStore.setLoading(false);
    BaseResponses responses = BaseResponses.fromJson(jsonDecode(response.body));

    if (responses.code == '[jwt_auth] incorrect_password') {
      toast(locale.lblIncorrectPwd);
    } else if (responses.message == "Cookie check failed") {
      regenerateCookie();
    } else if (responses.code == 'rest_forbidden') {
      toast(responses.message);
    } else if (responses.code.validate().contains('woocommerce_rest_cannot')) {
      toast(responses.message);
    } else {
      toast(responses.message);
      logout(isTokenExpired: true);
    }
  }

  if (response.statusCode == 500 || response.statusCode == 404) {
    if (appStore.isLoggedIn) {
      if (appStore.tempBaseUrl != BASE_URL) {
        appStore.setBaseUrl(BASE_URL, initialize: true);
        appStore.setDemoDoctor("", initialize: true);
        appStore.setDemoPatient("", initialize: true);
        appStore.setDemoReceptionist("", initialize: true);
        logout().catchError((e) {
          appStore.setLoading(false);

          throw e;
        });
      }
    } else {
      appStore.setBaseUrl(BASE_URL, initialize: true);
    }
  }

  if (response.statusCode.isSuccessful()) {
    if (response.request!.url.path.contains(EndPointKeys.loginEndPointKey) &&
        response.headers.containsKey(ApiResponseKeys.setCookieKey) &&
        !response.headers
            .containsKey(ApiHeaders.headerStoreNonceKey.toLowerCase())) {
      try {
        String cookie = response.headers[ApiResponseKeys.setCookieKey]
            .validate()
            .split(',')
            .map((e) => e.split(';').first)
            .firstWhere((str) => str.contains('wordpress_logged'));
        if (cookie.isNotEmpty)
          setValue(ApiResponseKeys.cookieHeaderKey, cookie, print: true);
      } catch (e) {
        log(e.toString());
      }
    }

    return jsonDecode(response.body);
  } else {
    try {
      var body = jsonDecode(response.body);

      if (body['message'].toString().validate().isNotEmpty) {
        throw parseHtmlString(body['message']);
      } else {
        throw errorSomethingWentWrong;
      }
    } on Exception {
      toast(errorSomethingWentWrong);
      throw errorSomethingWentWrong;
    }
  }
}

String _getOAuthURL({required String requestMethod, required String endpoint}) {
  var consumerKey = getStringAsync(UserDetailKeys.consumerKey);
  var consumerSecret = getStringAsync(UserDetailKeys.consumerSecretKey);

  var tokenSecret = "";
  var url = BASE_URL + endpoint;
  print("DEFAULT $url");

  var containsQueryParams = url.contains("?");

  if (url.startsWith("https")) {
    return url +
        (containsQueryParams == true
            ? "&consumer_key=" +
                consumerKey +
                "&consumer_secret=" +
                consumerSecret
            : "?consumer_key=" +
                consumerKey +
                "&consumer_secret=" +
                consumerSecret);
  } else {
    var rand = new Random();
    var codeUnits = new List.generate(10, (index) {
      return rand.nextInt(26) + 97;
    });

    var nonce = new String.fromCharCodes(codeUnits);
    int timestamp = new DateTime.now().millisecondsSinceEpoch ~/ 1000;

    var method = requestMethod;
    var parameters = "oauth_consumer_key=$consumerKey" +
        "&oauth_nonce=$nonce" +
        "&oauth_signature_method=HMAC-SHA1&oauth_timestamp=$timestamp" +
        "&oauth_version=1.0&";

    if (containsQueryParams == true) {
      parameters = parameters + url.split("?")[1];
    } else {
      parameters = parameters.substring(0, parameters.length - 1);
    }

    Map<dynamic, dynamic> params = QueryString.parse(parameters);
    Map<dynamic, dynamic> treeMap = new SplayTreeMap<dynamic, dynamic>();
    treeMap.addAll(params);

    String parameterString = "";

    for (var key in treeMap.keys) {
      parameterString = parameterString +
          Uri.encodeQueryComponent(key) +
          "=" +
          treeMap[key] +
          "&";
    }

    parameterString = parameterString.substring(0, parameterString.length - 1);

    var baseString = method +
        "&" +
        Uri.encodeQueryComponent(
            containsQueryParams == true ? url.split("?")[0] : url) +
        "&" +
        Uri.encodeQueryComponent(parameterString);

    var signingKey = consumerSecret + "&" + tokenSecret;
    var hmacSha1 =
        new crypto.Hmac(crypto.sha1, utf8.encode(signingKey)); // HMAC-SHA1
    var signature = hmacSha1.convert(utf8.encode(baseString));

    var finalSignature = base64Encode(signature.bytes);

    var requestUrl = "";

    if (containsQueryParams == true) {
      requestUrl = url.split("?")[0] +
          "?" +
          parameterString +
          "&oauth_signature=" +
          Uri.encodeQueryComponent(finalSignature);
    } else {
      requestUrl = url +
          "?" +
          parameterString +
          "&oauth_signature=" +
          Uri.encodeQueryComponent(finalSignature);
    }

    return requestUrl;
  }
}

//region Common
enum HttpMethod { GET, POST, DELETE, PUT, PATCH }

class TokenException implements Exception {
  final String message;

  const TokenException([this.message = ""]);

  String toString() => "FormatException: $message";
}
//endregion

Future<MultipartRequest> getMultiPartRequest(String endPoint) async {
  log('Url $BASE_URL$endPoint');
  return MultipartRequest('POST', Uri.parse('$BASE_URL$endPoint'));
}

Future<dynamic> sendMultiPartRequest(MultipartRequest multiPartRequest,
    {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  http.Response response =
      await http.Response.fromStream(await multiPartRequest.send());

  apiPrint(
    url: multiPartRequest.url.toString(),
    headers: jsonEncode(multiPartRequest.headers),
    request: jsonEncode(multiPartRequest.fields),
    hasRequest: true,
    statusCode: response.statusCode,
    responseBody: response.body,
    methodtype: "MultiPart",
  );

  if (response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      onSuccess?.call(jsonDecode(response.body));
    } else {
      onSuccess?.call(response.body);
    }
  } else {
    onError?.call(jsonDecode(response.body)['message'].toString().isNotEmpty
        ? jsonDecode(response.body)['message']
        : errorSomethingWentWrong);
  }
}

Future<dynamic> sendMultiPartRequestNew(
    MultipartRequest multiPartRequest) async {
  http.Response response =
      await http.Response.fromStream(await multiPartRequest.send());

  apiPrint(
    url: multiPartRequest.url.toString(),
    headers: jsonEncode(multiPartRequest.headers),
    request: jsonEncode(multiPartRequest.fields),
    hasRequest: true,
    statusCode: response.statusCode,
    responseBody: response.body,
    methodtype: "MultiPart",
  );

  if (response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      return jsonDecode(response.body);
    } else {
      return response.body;
    }
  } else {
    throw jsonDecode(response.body)['message'].toString().isNotEmpty
        ? jsonDecode(response.body)['message']
        : errorSomethingWentWrong;
  }
}

Future<FirebaseRemoteConfig> setupFirebaseRemoteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration.zero, minimumFetchInterval: Duration.zero));
  await remoteConfig.fetch();
  await remoteConfig.fetchAndActivate();

  return remoteConfig;
}

Future<void> regenerateCookie() async {
  Map<String, dynamic> req = {
    'username': userStore.userEmail,
    'password': getStringAsync(PASSWORD),
  };

  await loginAPI(req);
}

void apiPrint(
    {String url = "",
    String endPoint = "",
    String headers = "",
    String request = "",
    int statusCode = 0,
    String responseBody = "",
    String methodtype = "",
    bool hasRequest = false,
    bool fullLog = false,
    String responseHeader = ''}) {
  // fullLog = statusCode.isSuccessful();
  if (fullLog) {
    debugPrint(
        "┌───────────────────────────────────────────────────────────────────────────────────────────────────────");
    debugPrint("\u001b[93m Url: \u001B[39m $url");
    debugPrint("\u001b[93m endPoint: \u001B[39m \u001B[1m$endPoint\u001B[22m");
    debugPrint("\u001b[93m header: \u001B[39m \u001b[96m$headers\u001B[39m");
    if (hasRequest) {
      debugPrint('\u001b[93m Request: \u001B[39m \u001b[95m$request\u001B[39m');
    }
    debugPrint(statusCode.isSuccessful() ? "\u001b[32m" : "\u001b[31m");
    debugPrint(
        "\u001b[93m Response header: \u001B[39m \u001b[96m$responseHeader\u001B[39m");
    debugPrint(
        '\u001b[93m MethodType ($methodtype) | StatusCode ($statusCode)\u001B[39m');
    debugPrint('Response : ');
    debugPrint('\x1B[32m${formatJson(responseBody)}\x1B[0m');
    debugPrint("\u001B[0m");
    debugPrint(
        "└───────────────────────────────────────────────────────────────────────────────────────────────────────");
  } else {
    debugPrint(
        "┌───────────────────────────────────────────────────────────────────────────────────────────────────────");
    debugPrint("\u001b[93m Url: \u001B[39m $url");
    debugPrint("\u001b[93m endPoint: \u001B[39m \u001B[1m$endPoint\u001B[22m");
    debugPrint(
        "\u001b[93m header: \u001B[39m \u001b[96m${headers.split(',').join(',\n')}\u001B[39m");
    if (hasRequest) {
      debugPrint('\u001b[93m Request: \u001B[39m \u001b[95m$request\u001B[39m');
    }
    debugPrint(statusCode.isSuccessful() ? "\u001b[32m" : "\u001b[31m");
    debugPrint(
        '\u001b[93m MethodType ($methodtype) | statusCode: ($statusCode)\u001B[39m');
    debugPrint(
        "\u001b[93m Response header: \u001B[39m \u001b[96m$responseHeader\u001B[39m");
    debugPrint('\u001b[93m Response \u001B[39m');
    debugPrint('$responseBody');
    debugPrint("\u001B[0m");
    debugPrint(
        "└───────────────────────────────────────────────────────────────────────────────────────────────────────");
  }
}

String formatJson(String jsonStr) {
  try {
    final dynamic parsedJson = jsonDecode(jsonStr);
    const formatter = JsonEncoder.withIndent('  ');
    return formatter.convert(parsedJson);
  } on Exception catch (e) {
    dev.log("\x1b[31m formatJson error ::-> ${e.toString()} \x1b[0m");
    return jsonStr;
  }
}

String parseStripeError(String response) {
  try {
    var body = jsonDecode(response);
    return parseHtmlString(body['error']['message']);
  } on Exception catch (e) {
    log(e);
    throw errorSomethingWentWrong;
  }
}
