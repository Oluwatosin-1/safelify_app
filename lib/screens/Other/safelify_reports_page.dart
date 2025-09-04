import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../../widgets/mighty_button.dart';
import 'communitypostcard.dart';
import '../../config.dart';
import '../../controllers/report_controller.dart';
import '../../utils/colors.dart';
import '../../utils/global_helpers.dart';
import '../../widgets/migty_filter_field.dart';

class SafeLifyReports extends StatefulWidget {
  const SafeLifyReports({super.key});

  @override
  State<SafeLifyReports> createState() => _SafeLifyReportsState();
}

class _SafeLifyReportsState extends State<SafeLifyReports> {
  final ReportController _reportController = Get.put(ReportController())..fetchReportCategories();

  final RefreshController _refreshController = RefreshController();
  final RxBool _shouldShowOnlyMyPosts = false.obs;
  final RxBool _shouldShowFilters = false.obs;
  final RxString _selectedCategory = ''.obs;
  final RxString _selectedCity = ''.obs;

  @override
  void initState() {
    super.initState();
    _reportController.fetchCommunityReports(
        loadMine: _shouldShowOnlyMyPosts.value,
        catId: _selectedCategory.value,
        city: _selectedCity.value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Safelify Reports",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.red),
          ),
          actions: [
            InkWell(
              onTap: () {
                _shouldShowFilters.value = !_shouldShowFilters.value;
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor),
                ),
                child: Row(
                  children: [
                    const Text(
                      "Filters",
                      style: TextStyle(color: primaryColor),
                    ),
                    Obx(() {
                      return Icon(
                        !_shouldShowFilters.value
                            ? Icons.arrow_drop_down_rounded
                            : Icons.arrow_drop_up_outlined,
                        color: primaryColor,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Obx(() {
                return !_shouldShowFilters.value
                    ? const SizedBox()
                    : Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black54,
                            blurRadius: 6.0,
                            offset: Offset(0.0, 0.40))
                      ]),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        Obx(() {
                          return MightyFilterField(
                            initialValue: _selectedCategory.value,
                            labelText: 'Filter By Category',
                            hintText: "Select Category",
                            items: [
                              ..._reportController.categories.map((e) => {
                                'label': e.category,
                                'value': e.id,
                              })
                            ],
                            onChanged: (value) {
                              _selectedCategory.value = value;
                              _reportController.fetchCommunityReports(
                                  catId: _selectedCategory.value,
                                  city: _selectedCity.value);
                            },
                          );
                        }),
                        Row(
                          children: [
                            Obx(() {
                              return Checkbox(
                                value: _shouldShowOnlyMyPosts.value,
                                fillColor:
                                WidgetStateProperty.resolveWith(
                                        (states) => primaryColor),
                                onChanged: (value) {
                                  _shouldShowOnlyMyPosts.value =
                                  !_shouldShowOnlyMyPosts.value;
                                  _reportController.fetchCommunityReports(
                                      loadMine:
                                      _shouldShowOnlyMyPosts.value,
                                      catId: _selectedCategory.value,
                                      city: _selectedCity.value);
                                },
                              );
                            }),
                            const Text("Show reports posted by me")
                          ],
                        ),
                        const SizedBox(height: kdPadding - 15),
                        MightyButton(
                          text: "Clear Filters",
                          onTap: () {
                            _selectedCategory.value = '';
                            _selectedCity.value = '';
                            _shouldShowOnlyMyPosts.value = false;
                            _shouldShowFilters.value = false;
                            _reportController.fetchCommunityReports(
                                loadMine: _shouldShowOnlyMyPosts.value,
                                catId: _selectedCategory.value,
                                city: _selectedCity.value);
                          },
                        ),
                        const SizedBox(height: kdPadding - 15),
                      ],
                    ),
                  ),
                );
              }),
              Center(
                child: SizedBox(
                  height: 620,
                  child: Obx(() {
                    return _reportController.isLoading.value
                        ? getLoading()
                        : _reportController.communityReports.isEmpty
                        ? Column(
                      children: [
                        const SizedBox(height: 120),
                        Image.asset(
                          'assets/images/empty.png',
                          width: 120,
                        ),
                        const SizedBox(height: kdPadding),
                        const Text("No reports found."),
                      ],
                    )
                        : SmartRefresher(
                      enablePullDown: true,
                      onRefresh: () {
                        _reportController.fetchCommunityReports(
                            loadMine: _shouldShowOnlyMyPosts.value,
                            catId: _selectedCategory.value,
                            city: _selectedCity.value);
                      },
                      controller: _refreshController,
                      child: ListView.builder(
                          padding: const EdgeInsets.all(kdPadding - 10),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: _reportController
                              .communityReports.length,
                          itemBuilder:
                              (BuildContext context, int index) {
                            if (index ==
                                _reportController
                                    .communityReports.length) {
                              return Column(
                                children: [
                                  CommunityPostCard(
                                      report: _reportController
                                          .communityReports[index]),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                        BorderRadius.circular(11)),
                                    height: 40,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.4,
                                    child: const Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "Add",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              );
                            }

                            return CommunityPostCard(
                                report: _reportController
                                    .communityReports[index]);
                          }),
                    );
                  }),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
