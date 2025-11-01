class PaginatedResponse<T> {
  final List<T> data;
  final int page;
  final int pageSize;
  final int totalItems;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedResponse(
      data: (json['data'] as List<dynamic>).map((item) => item as T).toList(),
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalItems: json['totalItems'] as int,
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );
  }
}
