class UnauthorisedError {
  final String error;
  UnauthorisedError({required this.error});
  factory UnauthorisedError.fromJason(Map<String, dynamic> json) =>
      UnauthorisedError(error: json['error']);
}
