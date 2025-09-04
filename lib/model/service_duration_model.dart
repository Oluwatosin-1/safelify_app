class DurationModel {
  String? label;
  int? value;

  DurationModel({this.value, this.label});
}

List<DurationModel> getServiceDuration({int interval=5}) {
  List<DurationModel> durationList = [];

  for (int i = interval; i <= 300; i += interval) {
    int hours = i ~/ 60;
    int minutes = i % 60;
    String label = hours > 0
        ? '${hours}hr ${minutes}min'
        : '${minutes} min';

    durationList.add(DurationModel(value: i, label: label));
  }

  return durationList;
}
