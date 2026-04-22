class LabTestModel {

  const LabTestModel({
    required this.id,
    required this.testName,
    required this.result,
    required this.testDate,
  });

  factory LabTestModel.fromJson(Map<String, dynamic> json) {
    return LabTestModel(
      id: json['id'] as String? ?? '',
      testName: json['testName'] as String? ?? '',
      result: json['result'] as String? ?? '',
      testDate: json['testDate'] as String? ?? '',
    );
  }
  final String id;
  final String testName;
  final String result;
  final String testDate;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testName': testName,
      'result': result,
      'testDate': testDate,
    };
  }
}
