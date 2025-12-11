class NetworkException implements Exception {
  final String message;
  NetworkException({required this.message});
}

class UnauthorizedException implements Exception {
  final String message;
  final int? statusCode;
  UnauthorizedException({required this.message, this.statusCode});
}

class BadRequestException implements Exception {
  final String message;
  final int? statusCode;
  BadRequestException({required this.message, this.statusCode});
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException({required this.message, this.statusCode});
}

class UnknownException implements Exception {
  final String message;
  final int? statusCode;
  UnknownException({required this.message, this.statusCode});
}
