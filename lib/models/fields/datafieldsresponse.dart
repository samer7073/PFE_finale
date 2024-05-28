import 'fileData.dart';

class DataFieldRespone {
  final List<DataFields> data;
  DataFieldRespone(this.data);

  // Factory constructor for easier data parsing from JSON
  factory DataFieldRespone.fromJson(List<dynamic> json) {
    final List<DataFields> dataList = json.map((item) => DataFields.fromJson(item)).toList();
    return DataFieldRespone(dataList);
  }
}
