import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../storage/secure_storage.dart';
import '../models/blog_post.dart';
import '../models/author_blog.dart';
import '../models/author_comment.dart';
import '../models/conversation.dart';
import '../models/conversation_message.dart';
import '../models/destination.dart';
import '../models/hotel.dart';
import '../models/admin_comment.dart';
import '../models/blog_engagement.dart';
import '../models/blog_counts.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class UserProfile {
  final int? id;
  final String? name;
  final String? email;
  final String? role;

  const UserProfile({this.id, this.name, this.email, this.role});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
    );
  }
}

class AuthResult {
  final String token;
  final UserProfile user;

  const AuthResult({required this.token, required this.user});
}

class ReactionResult {
  final String target;
  final int? blogId;
  final int? commentId;
  final int likeCount;
  final int ecoCount;
  final String type;
  final bool active;

  const ReactionResult({
    required this.target,
    required this.blogId,
    required this.commentId,
    required this.likeCount,
    required this.ecoCount,
    required this.type,
    required this.active,
  });

  factory ReactionResult.fromJson(Map<String, dynamic> json) {
    return ReactionResult(
      target: json['target']?.toString() ?? '',
      blogId: _toIntOrNull(json['blog_id']),
      commentId: _toIntOrNull(json['comment_id']),
      likeCount: _toInt(json['likeCount']),
      ecoCount: _toInt(json['ecoCount']),
      type: json['type']?.toString() ?? '',
      active: json['active'] == true,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class ApiService {
  // Use 10.0.2.2 for Android emulator, or localhost for iOS/Web. Replace with production URL when deploying.
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  final http.Client _client;
  final SecureStorage _storage;

  ApiService({http.Client? client, SecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const SecureStorage();

  Future<Map<String, String>> _buildHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{..._jsonHeaders};
    if (!includeAuth) return headers;

    final token = await _storage.readToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  void _debugResponse(String label, Uri url, http.Response response) {
    final body = response.body;
    final snippet = body.length > 300 ? body.substring(0, 300) : body;
    // ignore: avoid_print
    print('[$label] ${response.statusCode} ${url.toString()}');
    // ignore: avoid_print
    print('[$label] body: $snippet');
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await _client
          .post(
            url,
            headers: _jsonHeaders,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      _debugResponse('login', url, response);

      final decoded = _decodeBody(response.body);
      final body = _asMap(decoded);
      if (response.statusCode == 200) {
        final token = body['token']?.toString();
        final userJson = body['user'];
        if (token == null || userJson is! Map) {
          throw const ApiException('Invalid login response.');
        }
        final user = UserProfile.fromJson(userJson.cast<String, dynamic>());
        final role = user.role ?? 'user';
        await _storage.saveAuth(token: token, role: role);
        return AuthResult(token: token, user: user);
      }

      throw _buildApiError(statusCode: response.statusCode, decoded: body);
    } on SocketException {
      throw const ApiException('Network error. Check your connection.');
    } on TimeoutException {
      throw const ApiException('Request timed out. Try again.');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await _client
          .post(
            url,
            headers: _jsonHeaders,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(const Duration(seconds: 15));

      _debugResponse('register', url, response);

      final decoded = _decodeBody(response.body);
      final body = _asMap(decoded);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw _buildApiError(statusCode: response.statusCode, decoded: body);
    } on SocketException {
      throw const ApiException('Network error. Check your connection.');
    } on TimeoutException {
      throw const ApiException('Request timed out. Try again.');
    }
  }

  Future<UserProfile> getCurrentUser({String? token}) async {
    final authToken = token ?? await _storage.readToken();
    if (authToken == null || authToken.isEmpty) {
      throw const ApiException('Missing auth token.', statusCode: 401);
    }

    final url = Uri.parse('$baseUrl/user');
    try {
      final response = await _client
          .get(
            url,
            headers: {..._jsonHeaders, 'Authorization': 'Bearer $authToken'},
          )
          .timeout(const Duration(seconds: 15));

      _debugResponse('user', url, response);

      final decoded = _decodeBody(response.body);
      final body = _asMap(decoded);
      if (response.statusCode == 200) {
        final userJson = body['user'];
        if (userJson is Map) {
          return UserProfile.fromJson(userJson.cast<String, dynamic>());
        }
        throw const ApiException('Invalid user response.');
      }

      throw _buildApiError(statusCode: response.statusCode, decoded: body);
    } on SocketException {
      throw const ApiException('Network error. Check your connection.');
    } on TimeoutException {
      throw const ApiException('Request timed out. Try again.');
    }
  }

  Future<UserProfile> fetchProfile() async {
    final url = Uri.parse('$baseUrl/profile');
    try {
      final response = await _client
          .get(url, headers: await _buildHeaders())
          .timeout(const Duration(seconds: 15));

      _debugResponse('profile', url, response);

      if (response.statusCode == 200) {
        final decoded = _decodeBody(response.body);
        final body = _asMap(decoded);
        return UserProfile.fromJson(body);
      }

      throw _buildApiError(
        statusCode: response.statusCode,
        decoded: _decodeBody(response.body),
      );
    } on SocketException {
      throw const ApiException('Network error. Check your connection.');
    } on TimeoutException {
      throw const ApiException('Request timed out. Try again.');
    }
  }

  Future<UserProfile> updateProfile({
    required String name,
    required String email,
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/profile');
    try {
      final response = await _client
          .patch(
            url,
            headers: await _buildHeaders(),
            body: jsonEncode({
              'name': name,
              'email': email,
              if (currentPassword != null && currentPassword.isNotEmpty)
                'current_password': currentPassword,
              if (password != null && password.isNotEmpty) 'password': password,
              if (passwordConfirmation != null &&
                  passwordConfirmation.isNotEmpty)
                'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(const Duration(seconds: 15));

      _debugResponse('profile:update', url, response);

      if (response.statusCode == 200) {
        final decoded = _decodeBody(response.body);
        final body = _asMap(decoded);
        return UserProfile.fromJson(body);
      }

      throw _buildApiError(
        statusCode: response.statusCode,
        decoded: _decodeBody(response.body),
      );
    } on SocketException {
      throw const ApiException('Network error. Check your connection.');
    } on TimeoutException {
      throw const ApiException('Request timed out. Try again.');
    }
  }

  Future<List<Destination>> fetchDestinations() async {
    final url = Uri.parse('$baseUrl/destinations');
    final response = await _client.get(url, headers: await _buildHeaders());
    _debugResponse('destinations', url, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final List data = _extractList(decoded, 'destinations');
      return data
          .map((item) => Destination.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(
        'Failed to load destinations.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Destination> fetchDestinationDetail(int id) async {
    final url = Uri.parse('$baseUrl/destinations/$id');
    final response = await _client.get(url, headers: await _buildHeaders());
    _debugResponse('destination:$id', url, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final data = _extractItem(decoded);
      return Destination.fromJson(data);
    } else {
      throw ApiException(
        'Failed to load destination.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Destination> fetchDestination(int id) {
    return fetchDestinationDetail(id);
  }

  Future<List<Hotel>> fetchHotels() async {
    final url = Uri.parse('$baseUrl/hotels');
    final response = await _client.get(url, headers: await _buildHeaders());
    _debugResponse('hotels', url, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final List data = _extractList(decoded, 'hotels');
      return data
          .map((item) => Hotel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(
        'Failed to load hotels.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Hotel> fetchHotelDetail(int id) async {
    final url = Uri.parse('$baseUrl/hotels/$id');
    final response = await _client.get(url, headers: await _buildHeaders());
    _debugResponse('hotel:$id', url, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final data = _extractItem(decoded);
      return Hotel.fromJson(data);
    } else {
      throw ApiException(
        'Failed to load hotel.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Hotel> fetchHotel(int id) {
    return fetchHotelDetail(id);
  }

  Future<List<BlogPost>> fetchBlogs() async {
    final url = Uri.parse('$baseUrl/blogs');
    final response = await _client.get(url, headers: await _buildHeaders());
    _debugResponse('blogs', url, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final List data = _extractList(decoded, 'blogs');
      return data
          .map((item) => BlogPost.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(
        'Failed to load blog posts.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<AuthorBlog>> fetchAuthorBlogs() async {
    final url = Uri.parse('$baseUrl/author/blogs');
    final response = await _client.get(url, headers: await _buildHeaders());
    _debugResponse('author:blogs', url, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final List data = _extractList(decoded, 'author blogs');
      return data
          .map((item) => AuthorBlog.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<List<AuthorComment>> fetchAuthorComments() async {
    final url = Uri.parse('$baseUrl/author/comments');
    final response = await _client.get(url, headers: await _buildHeaders());
    _debugResponse('author:comments', url, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final List data = _extractList(decoded, 'author comments');
      return data
          .map((item) => AuthorComment.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<List<Conversation>> fetchConversations({
    String? search,
    String? status,
  }) async {
    final url = Uri.parse('$baseUrl/conversations').replace(
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );
    final response = await _client.get(url, headers: await _buildHeaders());
    _debugResponse('conversations', url, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final List data = _extractList(decoded, 'conversations');
      return data
          .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<List<ConversationMessage>> fetchConversationMessages(int id) async {
    final url = Uri.parse('$baseUrl/conversations/$id');
    final response = await _client.get(url, headers: await _buildHeaders());
    _debugResponse('conversation:$id', url, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      List list;
      if (decoded is Map && decoded['messages'] is List) {
        list = decoded['messages'] as List;
      } else if (decoded is Map &&
          decoded['data'] is Map &&
          (decoded['data'] as Map)['messages'] is List) {
        list = (decoded['data'] as Map)['messages'] as List;
      } else {
        list = _extractList(decoded, 'conversation messages');
      }
      return list
          .map(
            (item) =>
                ConversationMessage.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<ConversationMessage> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    final url = Uri.parse('$baseUrl/messages');
    final response = await _client.post(
      url,
      headers: await _buildHeaders(),
      body: jsonEncode({'conversation_id': conversationId, 'content': content}),
    );
    _debugResponse('message:create', url, response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = _decodeBody(response.body);
      final body = _extractItem(decoded);
      return ConversationMessage.fromJson(body);
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<List<Destination>> fetchAdminDestinations({String? search}) async {
    final uri = Uri.parse('$baseUrl/admin/destinations').replace(
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final response = await _client.get(uri, headers: await _buildHeaders());
    _debugResponse('admin:destinations', uri, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final List data = _extractList(decoded, 'admin destinations');
      return data
          .map((item) => Destination.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(
        'Failed to load destinations.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Destination> createAdminDestination({
    required String name,
    required String region,
    required String type,
    required String shortDescription,
    required String imageUrl,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/destinations');
    final response = await _client.post(
      uri,
      headers: await _buildHeaders(),
      body: jsonEncode({
        'name': name,
        'region': region,
        'type': type,
        'short_description': shortDescription,
        'image_url': imageUrl,
      }),
    );
    _debugResponse('admin:destination:create', uri, response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = _decodeBody(response.body);
      final data = _extractItem(decoded);
      return Destination.fromJson(data);
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<void> deleteAdminDestination(int id) async {
    final uri = Uri.parse('$baseUrl/admin/destinations/$id');
    final response = await _client.delete(uri, headers: await _buildHeaders());
    _debugResponse('admin:destination:delete', uri, response);
    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<Destination> updateAdminDestination({
    required int id,
    required String name,
    required String region,
    required String type,
    required String shortDescription,
    required String imageUrl,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/destinations/$id');
    final response = await _client.patch(
      uri,
      headers: await _buildHeaders(),
      body: jsonEncode({
        'name': name,
        'region': region,
        'type': type,
        'short_description': shortDescription,
        'image_url': imageUrl,
      }),
    );
    _debugResponse('admin:destination:update', uri, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final data = _extractItem(decoded);
      return Destination.fromJson(data);
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<int> fetchAdminDestinationsTotal() async {
    final uri = Uri.parse('$baseUrl/admin/destinations');
    final response = await _client.get(uri, headers: await _buildHeaders());
    _debugResponse('admin:destinations:total', uri, response);
    if (response.statusCode == 200) {
      return _extractTotal(_decodeBody(response.body));
    }
    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<List<Hotel>> fetchAdminHotels({String? search}) async {
    final uri = Uri.parse('$baseUrl/admin/hotels').replace(
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final response = await _client.get(uri, headers: await _buildHeaders());
    _debugResponse('admin:hotels', uri, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final List data = _extractList(decoded, 'admin hotels');
      return data
          .map((item) => Hotel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(
        'Failed to load hotels.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Hotel> createAdminHotel({
    required String name,
    required String city,
    required String ecoLevel,
    required String priceRange,
    required String description,
    required String imageUrl,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/hotels');
    final response = await _client.post(
      uri,
      headers: await _buildHeaders(),
      body: jsonEncode({
        'name': name,
        'city': city,
        'eco_level': ecoLevel,
        'price_range': priceRange,
        'description': description,
        'image_url': imageUrl,
      }),
    );
    _debugResponse('admin:hotel:create', uri, response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = _decodeBody(response.body);
      final data = _extractItem(decoded);
      return Hotel.fromJson(data);
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<void> deleteAdminHotel(int id) async {
    final uri = Uri.parse('$baseUrl/admin/hotels/$id');
    final response = await _client.delete(uri, headers: await _buildHeaders());
    _debugResponse('admin:hotel:delete', uri, response);
    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<Hotel> updateAdminHotel({
    required int id,
    required String name,
    required String city,
    required String ecoLevel,
    required String priceRange,
    required String description,
    required String imageUrl,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/hotels/$id');
    final response = await _client.patch(
      uri,
      headers: await _buildHeaders(),
      body: jsonEncode({
        'name': name,
        'city': city,
        'eco_level': ecoLevel,
        'price_range': priceRange,
        'description': description,
        'image_url': imageUrl,
      }),
    );
    _debugResponse('admin:hotel:update', uri, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final data = _extractItem(decoded);
      return Hotel.fromJson(data);
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<int> fetchAdminHotelsTotal() async {
    final uri = Uri.parse('$baseUrl/admin/hotels');
    final response = await _client.get(uri, headers: await _buildHeaders());
    _debugResponse('admin:hotels:total', uri, response);
    if (response.statusCode == 200) {
      return _extractTotal(_decodeBody(response.body));
    }
    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<List<AdminComment>> fetchAdminComments({
    String? search,
    String? status,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/comments').replace(
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );
    final response = await _client.get(uri, headers: await _buildHeaders());
    _debugResponse('admin:comments', uri, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final List data = _extractList(decoded, 'admin comments');
      return data
          .map((item) => AdminComment.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(
        'Failed to load comments.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<AdminComment> approveAdminComment(int id) async {
    final uri = Uri.parse('$baseUrl/admin/comments/$id/approve');
    final response = await _client.patch(uri, headers: await _buildHeaders());
    _debugResponse('admin:comments:approve', uri, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final body = _asMap(decoded);
      return AdminComment.fromJson(body);
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<void> deleteAdminComment(int id) async {
    final uri = Uri.parse('$baseUrl/admin/comments/$id');
    final response = await _client.delete(uri, headers: await _buildHeaders());
    _debugResponse('admin:comments:delete', uri, response);
    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<int> fetchAdminCommentsTotal() async {
    final uri = Uri.parse('$baseUrl/admin/comments');
    final response = await _client.get(uri, headers: await _buildHeaders());
    _debugResponse('admin:comments:total', uri, response);
    if (response.statusCode == 200) {
      return _extractTotal(_decodeBody(response.body));
    }
    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<int> fetchAdminUsersTotal() async {
    final uri = Uri.parse('$baseUrl/admin/users');
    final response = await _client.get(uri, headers: await _buildHeaders());
    _debugResponse('admin:users:total', uri, response);
    if (response.statusCode == 200) {
      return _extractTotal(_decodeBody(response.body));
    }
    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<List<UserProfile>> fetchAdminUsers({String? search}) async {
    final uri = Uri.parse('$baseUrl/admin/users').replace(
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final response = await _client.get(uri, headers: await _buildHeaders());
    _debugResponse('admin:users', uri, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final List data = _extractList(decoded, 'admin users');
      return data
          .map((item) => UserProfile.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<UserProfile> updateAdminUserRole({
    required int userId,
    required String role,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/users/$userId/role');
    final response = await _client.patch(
      uri,
      headers: await _buildHeaders(),
      body: jsonEncode({'role': role}),
    );
    _debugResponse('admin:users:role', uri, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final body = _extractItem(decoded);
      return UserProfile.fromJson(body);
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<void> deleteAdminUser(int userId) async {
    final uri = Uri.parse('$baseUrl/admin/users/$userId');
    final response = await _client.delete(uri, headers: await _buildHeaders());
    _debugResponse('admin:users:delete', uri, response);
    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<BlogPost> fetchBlogDetail(int id) async {
    final url = Uri.parse('$baseUrl/blogs/$id');
    final response = await _client.get(url, headers: await _buildHeaders());
    _debugResponse('blog:$id', url, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final data = _extractItem(decoded);
      return BlogPost.fromJson(data);
    } else {
      throw ApiException(
        'Failed to load blog post.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<BlogPost> fetchBlogPost(int id) {
    return fetchBlogDetail(id);
  }

  Future<BlogEngagement> fetchBlogEngagement(int blogId) async {
    final url = Uri.parse('$baseUrl/blogs/$blogId/engagement');
    final response = await _client.get(url, headers: await _buildHeaders());
    _debugResponse('blog:$blogId:engagement', url, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final body = _extractItem(decoded);
      return BlogEngagement.fromJson(body);
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<BlogCounts> fetchBlogCounts(int blogId) async {
    final url = Uri.parse('$baseUrl/blogs/$blogId/counts');
    final response = await _client.get(url, headers: await _buildHeaders());
    _debugResponse('blog:$blogId:counts', url, response);

    if (response.statusCode == 200) {
      final decoded = _decodeBody(response.body);
      final body = _extractItem(decoded);
      return BlogCounts.fromJson(body);
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<void> createComment({
    required int blogId,
    required String content,
    int? parentId,
  }) async {
    final url = Uri.parse('$baseUrl/comments');
    final response = await _client.post(
      url,
      headers: await _buildHeaders(),
      body: jsonEncode({
        'content': content,
        'blog_id': blogId,
        if (parentId != null) 'parent_id': parentId,
      }),
    );
    _debugResponse('comment:create', url, response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  Future<ReactionResult> toggleReaction({
    required String type,
    int? blogId,
    int? commentId,
  }) async {
    final url = Uri.parse('$baseUrl/reactions');
    final response = await _client.post(
      url,
      headers: await _buildHeaders(),
      body: jsonEncode({
        'type': type,
        if (blogId != null) 'blog_id': blogId,
        if (commentId != null) 'comment_id': commentId,
      }),
    );
    _debugResponse('reaction:toggle', url, response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = _decodeBody(response.body);
      final body = _asMap(decoded);
      return ReactionResult.fromJson(body);
    }

    throw _buildApiError(
      statusCode: response.statusCode,
      decoded: _decodeBody(response.body),
    );
  }

  List _extractList(dynamic decoded, String label) {
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['data'] is List) {
      return decoded['data'] as List;
    }
    if (decoded is Map && decoded['data'] is Map) {
      final inner = decoded['data'];
      if (inner is Map && inner['data'] is List) {
        return inner['data'] as List;
      }
    }
    if (decoded is Map && decoded['results'] is List) {
      return decoded['results'] as List;
    }
    throw ApiException('Unexpected $label response shape.');
  }

  int _extractTotal(dynamic decoded) {
    if (decoded is Map) {
      final nested = decoded['data'];
      if (nested is Map) {
        final nestedMeta = nested['meta'];
        if (nestedMeta is Map && nestedMeta['total'] != null) {
          return int.tryParse(nestedMeta['total'].toString()) ?? 0;
        }
        if (nested['total'] != null) {
          return int.tryParse(nested['total'].toString()) ?? 0;
        }
        if (nested['data'] is List) {
          return (nested['data'] as List).length;
        }
      }
      final meta = decoded['meta'];
      if (meta is Map && meta['total'] != null) {
        return int.tryParse(meta['total'].toString()) ?? 0;
      }
      if (decoded['total'] != null) {
        return int.tryParse(decoded['total'].toString()) ?? 0;
      }
      final data = decoded['data'];
      if (data is List) {
        return data.length;
      }
    }
    if (decoded is List) return decoded.length;
    return 0;
  }

  Map<String, dynamic> _extractItem(dynamic decoded) {
    if (decoded is Map && decoded['data'] is Map) {
      return decoded['data'].cast<String, dynamic>();
    }
    if (decoded is Map) {
      return decoded.cast<String, dynamic>();
    }
    throw const ApiException('Unexpected response shape.');
  }

  dynamic _decodeBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Map<String, dynamic> _asMap(dynamic decoded) {
    if (decoded is Map) {
      return decoded.cast<String, dynamic>();
    }
    return <String, dynamic>{};
  }

  ApiException _buildApiError({
    required int statusCode,
    required dynamic decoded,
  }) {
    if (statusCode == 401) {
      return const ApiException('Unauthorized.', statusCode: 401);
    }
    if (statusCode == 422 && decoded is Map) {
      final errors = decoded['errors'];
      final message =
          _firstErrorMessage(errors) ??
          decoded['message']?.toString() ??
          'Validation error.';
      return ApiException(
        message,
        statusCode: statusCode,
        errors: errors is Map ? errors.cast<String, dynamic>() : null,
      );
    }
    if (decoded is Map && decoded['message'] != null) {
      return ApiException(
        decoded['message'].toString(),
        statusCode: statusCode,
      );
    }
    return ApiException(
      'Request failed ($statusCode).',
      statusCode: statusCode,
    );
  }

  String? _firstErrorMessage(dynamic errors) {
    if (errors is Map) {
      for (final entry in errors.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value != null) {
          return value.toString();
        }
      }
    }
    return null;
  }
}
