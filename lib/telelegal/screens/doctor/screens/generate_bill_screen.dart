import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:safelify/telelegal/components/loader_widget.dart';
import 'package:safelify/telelegal/components/multi_select_service_component.dart';
import 'package:safelify/telelegal/components/price_widget.dart';
import 'package:safelify/main.dart';
import 'package:safelify/telelegal/model/encounter_model.dart';
import 'package:safelify/telelegal/model/patient_bill_model.dart';
import 'package:safelify/telelegal/model/tax_model.dart';
import 'package:safelify/telelegal/network/bill_repository.dart';
import 'package:safelify/telelegal/screens/doctor/screens/add_bill_item_screen.dart';
import 'package:safelify/telelegal/utils/app_common.dart';
import 'package:safelify/telelegal/utils/colors.dart';
import 'package:safelify/telelegal/utils/common.dart';
import 'package:safelify/telelegal/utils/constants.dart';
import 'package:safelify/telelegal/utils/extensions/widget_extentions.dart';
import 'package:nb_utils/nb_utils.dart';

class GenerateBillScreen extends StatefulWidget {
  EncounterModel data;

  GenerateBillScreen({required this.data});

  @override
  _GenerateBillScreenState createState() => _GenerateBillScreenState();
}

class _GenerateBillScreenState extends State<GenerateBillScreen> {
  Future<PatientBillModule?>? future;

  late EncounterModel patientEncounterData;

  TextEditingController totalCont = TextEditingController();
  TextEditingController subTotalCont = TextEditingController();
  TextEditingController discountCont = TextEditingController(text: '0');
  TextEditingController payableCont = TextEditingController();

  double payableText = 0;
  int? paymentStatusValue;

  PatientBillModule? patientBillData;

  bool forEncounterFromList = false;

  bool showValidation = false;

  List<BillItem> billItemData = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    patientEncounterData = widget.data;

    if (patientEncounterData.paymentStatus != null) {
      paymentStatusValue = patientEncounterData.paymentStatus.toInt();
    }
    if (patientEncounterData.billId != null) {
      appStore.setLoading(true);
      future = getBillDetailsAPI(
        encounterId: patientEncounterData.encounterId.toInt(),
      ).then((value) async {
        appStore.setLoading(false);
        patientBillData = value;
        paymentStatusValue = value.paymentStatus == 'paid' ? 1 : 0;
        totalCont.text = value.totalAmount.validate().toString();
        payableCont.text = value.actualAmount.validate().toString();
        discountCont.text = value.discount.validate();
        if (value.billItems.validate().isNotEmpty) {
          billItemData.addAll(value.billItems.validate());
          getTaxDataApi(
              payment: paymentStatusValue =
                  value.paymentStatus == 'paid' ? 1 : 0);
        }

        return value;
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
        throw e;
      });
    }
  }

  void getTaxDataApi({int? payment}) {
    if (isProEnabled()) {
      Map<String, dynamic> request = {
        ConstantKeys.doctorIdKey: widget.data.doctorId,
        ConstantKeys.clinicIdKey: widget.data.clinicId,
      };

      List<ServiceRequestModel> selectedServiceRequest = [];

      request.putIfAbsent(
          ConstantKeys.visitTypeKey, () => selectedServiceRequest);
      billItemData.validate().validate().forEachIndexed((element, index) {
        selectedServiceRequest.add(ServiceRequestModel(
            serviceId: element.mappingTableId,
            quantity: element.qty.validate().toInt()));
      });

      request.putIfAbsent(
          ConstantKeys.visitTypeKey, () => selectedServiceRequest);
      appStore.setLoading(true);
      getTaxData(request).then((taxData) {
        multiSelectStore1.setTaxData(taxData);

        getTotal(payment: payment);
        setState(() {});

        appStore.setLoading(false);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
        throw e;
      });
    } else {
      getTotal(payment: payment, discount: '0');
      setState(() {});
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void saveFrom() {
    if (billItemData.isNotEmpty) {
      appStore.setLoading(true);
      Map<String, dynamic> request = {
        "id":
            "${patientEncounterData.billId == null ? "" : patientEncounterData.billId}",
        "encounter_id":
            "${patientEncounterData.encounterId == null ? "" : patientEncounterData.encounterId}",
        "appointment_id":
            "${patientEncounterData.appointmentId == null ? "" : patientEncounterData.appointmentId}",
        "total_amount": billItemData
            .sumByDouble((element) =>
                element.price.validate().toDouble() *
                element.qty.validate().toInt())
            .toString(),
        "discount": discountCont.text.validate().isEmptyOrNull
            ? '0'
            : discountCont.text.validate(),
        "actual_amount": "${payableCont.text.validate()}",
        "payment_status": paymentStatusValue == 0 ? "unpaid" : "paid",
        "billItems": billItemData,
      };

      addPatientBillAPI(request).then((value) {
        appStore.setLoading(false);
        toast(value.message);
        multiSelectStore.setTaxData(null);

        finish(context, paymentStatusValue == 1 ? "paid" : "unpaid");
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
        throw e;
      });

      appStore.setLoading(false);
    } else {
      toast(locale.lblAtLeastSelectOneBillItem);
    }
  }

  void getTotal({int? payment, String discount = '0'}) {
    payableText = 0;
    paymentStatusValue = payment ?? 0;

    subTotalCont.text = billItemData
        .sumByDouble((element) =>
            element.price.validate().toDouble() *
            element.qty.validate().toInt())
        .toString();
    payableText = double.parse(subTotalCont.text);
    setTotalPayable(v: discount.validate());
  }

  void setTotalPayable({String v = '0'}) {
    double discount = double.parse(v);
    subTotalCont.text =
        (double.parse(subTotalCont.text) - discount).toStringAsFixed(2);
    payableText -= discount;

    if (multiSelectStore.taxData != null) {
      payableCont.text =
          '${payableText + multiSelectStore.taxData!.totalTax.validate()}';
    } else
      payableCont.text = payableText.toStringAsFixed(2);

    setState(() {});
  }

  @override
  void dispose() {
    multiSelectStore.selectedService.clear();
    multiSelectStore.clearList();
    multiSelectStore.setTaxData(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: appBarWidget(
          locale.lblGenerateInvoice,
          textColor: Colors.white,
          systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
          actions: [
            TextIcon(
              text: locale.lblAddBillItem.toUpperCase(),
              textStyle: boldTextStyle(color: Colors.white),
              prefix: Icon(Icons.add, color: white, size: 18),
            ).paddingOnly(right: 16, left: 8).appOnTap(
              () async {
                selectService();
              },
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedScrollView(
              listAnimationType: ListAnimationType.None,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(locale.lblNote + " : " + locale.lblSwipeMassage,
                        style: secondaryTextStyle(
                            size: 10, color: appSecondaryColor))
                    .paddingLeft(4),
                8.height,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: boxDecorationDefault(
                    color:
                        appStore.isDarkModeOn ? cardDarkColor : selectedColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                  ),
                  child: Row(
                    children: [
                      Text(locale.lblSRNo,
                              style:
                                  boldTextStyle(size: 12, color: primaryColor),
                              textAlign: TextAlign.center)
                          .fit(fit: BoxFit.none)
                          .expand(),
                      Text("${locale.lblSERVICES}",
                              style:
                                  boldTextStyle(size: 12, color: primaryColor),
                              textAlign: TextAlign.start)
                          .fit(fit: BoxFit.none)
                          .expand(flex: 1),
                      Text("         " + locale.lblPRICE,
                              style:
                                  boldTextStyle(size: 12, color: primaryColor),
                              textAlign: TextAlign.end)
                          .fit(fit: BoxFit.none)
                          .expand(),
                      Text("      " + locale.lblQUANTITY,
                              style:
                                  boldTextStyle(size: 12, color: primaryColor),
                              textAlign: TextAlign.end)
                          .fit(fit: BoxFit.none)
                          .expand(),
                      Text("      " + locale.lblTOTAL,
                              style:
                                  boldTextStyle(size: 12, color: primaryColor),
                              textAlign: TextAlign.end)
                          .fit(fit: BoxFit.none)
                          .expand(flex: 1),
                    ],
                  ),
                ),
                if (patientEncounterData.billId == null && billItemData.isEmpty)
                  NoDataWidget(
                    retryText: locale.lblAddBillItem,
                    onRetry: () {
                      selectService();
                    },
                  )
                else
                  SnapHelperWidget(
                      future: future,
                      loadingWidget: Offstage(),
                      onSuccess: (data) {
                        return Container(
                          constraints: BoxConstraints(
                              maxHeight: context.height() * 0.46),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: boxDecorationDefault(
                            color: context.cardColor,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: billItemData.length,
                            itemBuilder: (context, index) {
                              BillItem data = billItemData[index];
                              int total = data.price.validate().toInt() *
                                  data.qty.validate().toInt();

                              return Slidable(
                                endActionPane: ActionPane(
                                  extentRatio: 0.2,
                                  motion: ScrollMotion(),
                                  children: [
                                    Icon(
                                      Icons.remove,
                                      color: Colors.grey,
                                      size: 16,
                                    ).paddingAll(4).appOnTap(() {
                                      int qn = data.qty.toInt();
                                      if (qn > 0) {
                                        qn--;
                                      }
                                      if (qn > 0) {
                                        data.qty = qn.toString();
                                      }
                                      if (qn == 0) {
                                        billItemData.remove(data);
                                      }
                                      if (billItemData.isNotEmpty)
                                        getTaxDataApi();

                                      setState(() {});
                                    }),
                                    Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 16,
                                    )
                                        .paddingSymmetric(
                                            horizontal: 8, vertical: 2)
                                        .appOnTap(
                                      () {
                                        billItemData.remove(data);
                                        paymentStatusValue = 0;
                                        if (billItemData.isNotEmpty)
                                          getTaxDataApi();
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Text('${index + 1}',
                                            style: primaryTextStyle(size: 12),
                                            textAlign: TextAlign.center)
                                        .expand(),
                                    Text(
                                      '${data.label.validate()}',
                                      style: primaryTextStyle(size: 12),
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ).expand(flex: 2),
                                    Text(
                                      '${appStore.currencyPrefix.validate(value: appStore.currency.validate())}${data.price.validate()}${appStore.currencyPostfix.validate(value: '')}',
                                      style: primaryTextStyle(size: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                    ).paddingRight(8).expand(),
                                    Text('${data.qty.validate()}',
                                            style: primaryTextStyle(size: 12),
                                            textAlign: TextAlign.center)
                                        .expand(),
                                    Text(
                                      '${appStore.currencyPrefix.validate(value: appStore.currency.validate())}$total${appStore.currencyPostfix.validate(value: '')}',
                                      style: primaryTextStyle(size: 12),
                                      textAlign: TextAlign.center,
                                    ).paddingRight(8).expand(flex: 1),
                                  ],
                                ),
                              ).onTap(() {
                                AddBillItemScreen(
                                  billItem: billItemData,
                                  callBack: () {
                                    setState(() {});
                                    getTaxDataApi();
                                  },
                                  clinicId: widget.data.clinicId,
                                  data: data,
                                  doctorId:
                                      patientEncounterData.doctorId.toInt(),
                                )
                                    .launch(context,
                                        pageRouteAnimation: pageAnimation,
                                        duration: pageAnimationDuration)
                                    .then((value) {
                                  getTotal();
                                  setState(() {});
                                });
                              });
                            },
                            separatorBuilder: (context, index) {
                              return Divider(color: viewLineColor);
                            },
                          ),
                        );
                      }),
                if (forEncounterFromList && billItemData.isNotEmpty)
                  Container(
                    constraints:
                        BoxConstraints(maxHeight: context.height() * 0.46),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: boxDecorationDefault(
                      color: context.cardColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8)),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: billItemData.length,
                      itemBuilder: (context, index) {
                        BillItem data = billItemData[index];
                        int total = data.price.validate().toInt() *
                            data.qty.validate().toInt();

                        return Slidable(
                          endActionPane: ActionPane(
                            extentRatio: 0.2,
                            motion: ScrollMotion(),
                            children: [
                              Icon(
                                Icons.remove,
                                color: Colors.grey,
                                size: 16,
                              ).paddingAll(4).appOnTap(() {
                                int qn = data.qty.toInt();
                                if (qn > 0) {
                                  qn--;
                                }
                                if (qn > 0) {
                                  data.qty = qn.toString();
                                }
                                if (qn == 0) {
                                  billItemData.remove(data);
                                }
                                if (billItemData.isNotEmpty) getTaxDataApi();
                              }),
                              Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 16,
                              )
                                  .paddingSymmetric(horizontal: 8, vertical: 2)
                                  .appOnTap(
                                () {
                                  billItemData.remove(data);
                                  paymentStatusValue = 0;
                                  setState(() {});
                                  if (billItemData.isNotEmpty) getTaxDataApi();
                                },
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text('${index + 1}',
                                      style: primaryTextStyle(size: 12),
                                      textAlign: TextAlign.center)
                                  .expand(),
                              Text(
                                '${data.label.validate()}',
                                style: primaryTextStyle(size: 12),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ).expand(flex: 2),
                              Text(
                                '${appStore.currencyPrefix.validate(value: appStore.currency.validate())}${data.price.validate()}${appStore.currencyPostfix.validate(value: '')}',
                                style: primaryTextStyle(size: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                              ).paddingRight(8).expand(),
                              Text('${data.qty.validate()}',
                                      style: primaryTextStyle(size: 12),
                                      textAlign: TextAlign.center)
                                  .expand(),
                              Text(
                                '${appStore.currencyPrefix.validate(value: appStore.currency.validate())}$total${appStore.currencyPostfix.validate(value: '')}',
                                style: primaryTextStyle(size: 12),
                                textAlign: TextAlign.center,
                              ).paddingRight(8).expand(flex: 1),
                            ],
                          ),
                        ).onTap(() {
                          AddBillItemScreen(
                            billItem: billItemData,
                            callBack: () {
                              getTaxDataApi();
                            },
                            clinicId: widget.data.clinicId,
                            data: data,
                            doctorId: patientEncounterData.doctorId.toInt(),
                          )
                              .launch(context,
                                  pageRouteAnimation: pageAnimation,
                                  duration: pageAnimationDuration)
                              .then((value) {
                            setState(() {});
                          });
                        });
                      },
                      separatorBuilder: (context, index) {
                        return Divider(color: viewLineColor);
                      },
                    ),
                  )
              ],
            ).paddingAll(16),
            Positioned(
              bottom: 90,
              right: 16,
              left: 16,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    width: context.width(),
                    decoration: boxDecorationDefault(
                      borderRadius: radius(),
                      color: context.cardColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(locale.lblPrice, style: secondaryTextStyle())
                                .expand(),
                            FittedBox(
                              child: PriceWidget(
                                price: (billItemData
                                        .sumByDouble((element) =>
                                            element.price
                                                .validate()
                                                .toDouble() *
                                            element.qty.validate().toInt())
                                        .toDouble())
                                    .toStringAsFixed(2),
                                textStyle: primaryTextStyle(size: 14),
                              ),
                            )
                          ],
                        ),
                        16.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(locale.lblDiscount,
                                    style: secondaryTextStyle())
                                .expand(flex: 2),
                            AppTextField(
                              controller: discountCont,
                              textFieldType: TextFieldType.NUMBER,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.end,
                              decoration: inputDecoration(
                                      context: context,
                                      labelText: '',
                                      contentPadding: EdgeInsets.zero,
                                      boxConstraints: BoxConstraints(
                                          maxHeight: 40, maxWidth: 80))
                                  .copyWith(
                                      filled: true,
                                      fillColor:
                                          context.scaffoldBackgroundColor,
                                      contentPadding:
                                          EdgeInsets.only(right: 8)),
                              onChanged: (p0) {
                                if (billItemData
                                        .sumByDouble((element) =>
                                            element.price
                                                .validate()
                                                .toDouble() *
                                            element.qty.validate().toInt())
                                        .toDouble() <
                                    double.parse(p0.validate())) {
                                  setState(() {
                                    showValidation = true;
                                  });
                                } else {
                                  setState(() {
                                    showValidation = false;
                                  });
                                  getTotal(discount: p0.validate(value: '0'));
                                }
                              },
                              onFieldSubmitted: (p0) {
                                if (billItemData
                                        .sumByDouble((element) =>
                                            element.price
                                                .validate()
                                                .toDouble() *
                                            element.qty.validate().toInt())
                                        .toDouble() <
                                    double.parse(p0.validate())) {
                                  setState(() {
                                    showValidation = true;
                                  });
                                } else {
                                  setState(() {
                                    showValidation = false;
                                  });
                                  getTotal(discount: p0.validate(value: '0'));
                                }
                              },
                              validator: (value) {},
                            ),
                          ],
                        ),
                        if (showValidation)
                          Align(
                            child: Text(
                              'Discount can not be greater than total Service Charge',
                              style: secondaryTextStyle(
                                  color: errorTextColor, size: 10),
                            ).paddingSymmetric(vertical: 2),
                            alignment: AlignmentDirectional.centerEnd,
                          ),
                        if (multiSelectStore.taxData != null) 16.height,
                        if (multiSelectStore.taxData != null)
                          Row(
                            children: [
                              Text(locale.lblSubTotal,
                                      style: secondaryTextStyle())
                                  .expand(),
                              FittedBox(
                                child: PriceWidget(
                                  price: subTotalCont.text
                                      .toDouble()
                                      .toStringAsFixed(2),
                                  textStyle: primaryTextStyle(size: 14),
                                ),
                              )
                            ],
                          ),
                        16.height,
                        Divider(),
                        if (multiSelectStore.taxData != null &&
                            multiSelectStore.taxData!.taxList
                                .validate()
                                .isNotEmpty)
                          Row(
                            children: [
                              Text(locale.lblTax,
                                      style: boldTextStyle(size: 12))
                                  .expand(),
                              16.width,
                              Text(
                                locale.lblTaxRate,
                                style: boldTextStyle(size: 12),
                                textAlign: TextAlign.center,
                              ).expand(flex: 2),
                              16.width,
                              Text(
                                locale.lblCharges,
                                style: boldTextStyle(size: 12),
                                textAlign: TextAlign.end,
                              ).expand(),
                            ],
                          ),
                        if (multiSelectStore.taxData != null &&
                            multiSelectStore.taxData!.taxList
                                .validate()
                                .isNotEmpty)
                          16.height,
                        if (multiSelectStore.taxData != null &&
                            multiSelectStore.taxData!.taxList
                                .validate()
                                .isNotEmpty)
                          ...multiSelectStore.taxData!.taxList
                              .validate()
                              .map<Widget>((data) {
                            return Row(
                              children: [
                                Text(
                                  data.taxName
                                      .validate()
                                      .replaceAll(RegExp(r'[^a-zA-Z]'), ''),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: secondaryTextStyle(size: 12),
                                ).expand(),
                                if (data.taxName.validate().contains('%'))
                                  Text(
                                    data.taxRate
                                        .validate()
                                        .toString()
                                        .suffixText(value: '%'),
                                    style: primaryTextStyle(size: 14),
                                    textAlign: TextAlign.center,
                                  ).expand(flex: 2)
                                else
                                  PriceWidget(
                                    price: data.taxRate
                                        .validate()
                                        .toStringAsFixed(2),
                                    textStyle: primaryTextStyle(size: 14),
                                    textAlign: TextAlign.center,
                                  ).paddingLeft(4).expand(flex: 2),
                                PriceWidget(
                                  price: data.charges
                                      .validate()
                                      .toStringAsFixed(2),
                                  textStyle: primaryTextStyle(size: 14),
                                  textAlign: TextAlign.end,
                                ).paddingLeft(4).expand(),
                              ],
                            );
                          }).toList(),
                        if (multiSelectStore.taxData != null &&
                            multiSelectStore.taxData!.taxList
                                .validate()
                                .isNotEmpty)
                          Divider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(locale.lblPayableAmount,
                                style: secondaryTextStyle()),
                            Spacer(),
                            Text(
                                "${appStore.currencyPrefix.validate(value: appStore.currency.validate(value: ''))}${payableCont.text.validate().toDouble().toStringAsFixed(2)}${appStore.currencyPostfix.validate(value: '')}",
                                style: boldTextStyle(),
                                textAlign: TextAlign.right),
                          ],
                        ),
                        16.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(locale.lblPaymentStatus,
                                style: secondaryTextStyle()),
                            Spacer(),
                            TextIcon(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      padding: EdgeInsets.all(16),
                                      color: context.scaffoldBackgroundColor,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 5,
                                            width: 40,
                                            decoration: boxDecorationDefault(
                                                color: context.primaryColor,
                                                borderRadius: radius()),
                                          ).center(),
                                          32.height,
                                          Text(locale.lblPaymentStatus,
                                              style: boldTextStyle()),
                                          16.height,
                                          Column(
                                            children: [
                                              RadioListTile(
                                                value: 1,
                                                contentPadding: EdgeInsets.zero,
                                                groupValue: paymentStatusValue,
                                                title: Text(locale.lblPaid),
                                                selectedTileColor:
                                                    context.cardColor,
                                                onChanged: (int? newValue) {
                                                  paymentStatusValue =
                                                      newValue.validate();
                                                  setState(() {});
                                                  finish(context);
                                                },
                                                activeColor: primaryColor,
                                                selected: true,
                                              ),
                                              RadioListTile(
                                                value: 0,
                                                contentPadding: EdgeInsets.zero,
                                                groupValue: paymentStatusValue,
                                                selectedTileColor:
                                                    context.cardColor,
                                                title: Text(locale.lblUnPaid),
                                                onChanged: (int? newValue) {
                                                  paymentStatusValue =
                                                      newValue.validate();
                                                  setState(() {});

                                                  finish(context);
                                                },
                                                activeColor: primaryColor,
                                                selected: true,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              spacing: 0,
                              suffix: Icon(Icons.arrow_drop_down_outlined,
                                  color: primaryColor),
                              textStyle: boldTextStyle(
                                  color: paymentStatusValue != null
                                      ? primaryColor
                                      : textPrimaryColorGlobal,
                                  size: 14),
                              text: paymentStatusValue != null
                                  ? paymentStatusValue == 0
                                      ? locale.lblUnPaid
                                      : locale.lblPaid
                                  : '${locale.lblSelect} ${locale.lblPaymentStatus}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 16,
                right: 16,
                left: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      color: context.scaffoldBackgroundColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      shapeBorder: RoundedRectangleBorder(
                          side: BorderSide(color: context.primaryColor),
                          borderRadius: radius()),
                      onTap: () {
                        finish(context);
                      },
                      child: Text(locale.lblCancel.toUpperCase(),
                          style: boldTextStyle(color: context.primaryColor)),
                    ),
                    16.width,
                    AppButton(
                      color: appStore.isDarkModeOn
                          ? cardDarkColor
                          : appSecondaryColor,
                      child: Text(locale.lblSave.toUpperCase(),
                          style: boldTextStyle(color: Colors.white)),
                      onTap: () async {
                        if (paymentStatusValue != null) {
                          if (appStore.isLoading) return;
                          appStore.setLoading(true);

                          saveFrom();
                        } else {
                          toast(locale.lblPleaseSelectPaymentStatus);
                        }
                      },
                    ).expand(flex: 3),
                  ],
                )),
            Observer(builder: (context) {
              return LoaderWidget().visible(appStore.isLoading).center();
            })
          ],
        ),
      );
    });
  }

  void selectService() {
    MultiSelectServiceComponent(
      isForBill: true,
      doctorId: isDoctor()
          ? userStore.userId
          : widget.data.doctorId.toInt() ??
              patientBillData!.patientEncounter?.doctorId.toInt(),
      selectedServicesId: billItemData.isNotEmpty
          ? billItemData.map((e) => e.itemId.validate()).toList()
          : [],
      clinicId: isReceptionist()
          ? userStore.userClinicId.toInt()
          : widget.data.clinicId.toInt() ??
              patientBillData!.patientEncounter?.clinicId.toInt(),
    )
        .launch(context,
            pageRouteAnimation: pageAnimation, duration: pageAnimationDuration)
        .then((value) {
      if (multiSelectStore.selectedService.validate().isNotEmpty) {
        multiSelectStore.selectedService.forEach((serviceData) {
          int index = billItemData
              .indexWhere((element) => element.itemId == serviceData.id);
          if (index < 0)
            billItemData.add(
              BillItem(
                id: "",
                label: serviceData.name.validate(),
                billId: patientEncounterData.billId.validate().toString(),
                itemId: serviceData.id.validate(),
                qty: "1",
                price: serviceData.charges,
                mappingTableId: serviceData.mappingTableId,
              ),
            );
          else {}
        });
        multiSelectStore.setTaxData(null);
        if (widget.data.billId == null) forEncounterFromList = true;
        getTaxDataApi();
        setState(() {});
      } else {
        multiSelectStore.setTaxData(null);
        forEncounterFromList = true;
        billItemData.clear();
        setState(() {});
      }
    });
  }
}
