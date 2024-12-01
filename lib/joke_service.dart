import 'package:dio/dio.dart';

class JokeService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://v2.jokeapi.dev/joke';

  /// Fetch jokes with detailed properties.
  Future<List<Map<String, dynamic>>> fetchJokesRaw({
    required String category,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/$category',
        queryParameters: {
          'amount': 10, // Fetch 10 jokes
          'lang': 'en', // Language set to English
          'type': 'single,twopart', // Include both single and two-part jokes
          'blacklistFlags': 'nsfw,religious,political,racist,sexist,explicit', // Blacklist inappropriate content
        },
      );

      // Check if the response contains jokes
      if (response.data['jokes'] != null) {
        return (response.data['jokes'] as List).map((joke) {
          return {
            'category': joke['category'],
            'type': joke['type'],
            'joke': joke['joke'], // For single jokes
            'setup': joke['setup'], // For two-part jokes
            'delivery': joke['delivery'], // For two-part jokes
            'lang': joke['lang'],
            'idRange': joke['idRange'],
            'contains': joke['contains'],
            'blacklistFlags': joke['blacklistFlags'],
            'amount': response.data['amount'],
          };
        }).toList();
      } else {
        // If no jokes are returned
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch jokes: $e');
    }
  }
}
