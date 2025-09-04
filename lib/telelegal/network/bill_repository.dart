import 'package:http/http.dart' as http;
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/model/base_response.dart';
import 'package:safelify/telelegal/model/bill_list_model.dart';
import 'package:safelify/telelegal/model/patient_bill_model.dart';
import 'package:safelify/telelegal/model/tax_model.dart';
import 'package:safelify/telelegal/network/network_utils.dart';
import 'package:safelify/telelegal/utils/app_common.dart';
import 'package:safelify/telelegal/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

Future<PatientBillModule> getBillDetailsAPI(
    {int? encounterId, int? billId}) async {
  List<String> params = [];

  if (encounterId != null)
    params.add('${ConstantKeys.encounterIdKey}=$encounterId');
  if (billId != null) params.add('${ConstantKeys.billIdKey}=$billId');
  http.Response response = await buildHttpResponse(getEndPoint(
      endPoint:
          '${ApiEndPoints.billEndPoint}/${EndPointKeys.billDetailEndPointKey}',
      params: params));
  return PatientBillModule.fromJson(await handleResponse(response));
}

Future<TaxModel> getTaxData(Map req) async {
  return TaxModel.fromJson(await handleResponse(await buildHttpResponse(
      '${ApiEndPoints.taxEndPoint}',
      request: req,
      method: HttpMethod.POST)));
}

Future<BaseResponses> addPatientBillAPI(Map request) async {
  return BaseResponses.fromJson(await handleResponse(await buildHttpResponse(
      '${ApiEndPoints.billEndPoint}/${EndPointKeys.addBillEndPointKey}',
      request: request,
      method: HttpMethod.POST)));
}

Future<List<BillListData>> getBillListApi({
  int? page,
  Function(bool)? lastPageCallback,
  required List<BillListData> billList,
}) async {
  if (!appStore.isConnectedToInternet) {
    return [];
  }
  List<String> param = [];

  BillListModel res = BillListModel.fromJson(
    await handleResponse(await buildHttpResponse(getEndPoint(
        endPoint:
            '${ApiEndPoints.billEndPoint}/${EndPointKeys.listEndPointKey}',
        page: page,
        params: param))),
  );

  if (page == 1) billList.clear();

  lastPageCallback?.call(res.billListData.validate().length != 10);

  billList.addAll(res.billListData.validate());

  appStore.setLoading(false);
  return billList;
}

//ORDERS

//RAZOR

Future<void> savePayment({required Map paymentResponse}) async {
  await handleResponse(await buildHttpResponse(ApiEndPoints.savePaymentEndPoint,
      request: paymentResponse, method: HttpMethod.POST));
}

Future<BaseResponses> deleteBillApi(String id) async {
  List<String> params = [];
  params.add('${ConstantKeys.billIdKey}=$id');
  return BaseResponses.fromJson(await handleResponse(await buildHttpResponse(
      getEndPoint(endPoint: ApiEndPoints.billDeleteEndPoint, params: params),
      method: HttpMethod.DELETE)));
}

//End Region
