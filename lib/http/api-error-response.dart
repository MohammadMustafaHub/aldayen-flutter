class ApiErrorResponse {
  final List<Map<String, List<String>>> errors;

  ApiErrorResponse({required this.errors});
  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    var errorsList = <Map<String, List<String>>>[];

    json.forEach((key, value) {
      errorsList.add({key: List<String>.from(value)});
    });

    return ApiErrorResponse(errors: errorsList);
  }

  bool containsErrorKey(String key) {
    return errors.any((error) => error.containsKey(key));
  }
}
