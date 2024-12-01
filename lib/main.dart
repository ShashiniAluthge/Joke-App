import 'package:flutter/material.dart';
import 'joke_service.dart';

void main() => runApp(const MyApp());

/// Entry point of the app, wraps the JokeListPage in a MaterialApp.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      title: 'Joke App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
      ),
      home: const JokeListPage(),
    );
  }
}

/// Main page of the app to display and fetch jokes.
class JokeListPage extends StatefulWidget {
  const JokeListPage({super.key});

  @override
  _JokeListPageState createState() => _JokeListPageState();
}

class _JokeListPageState extends State<JokeListPage> {
  final JokeService _jokeService = JokeService();
  List<Map<String, dynamic>> _jokesRaw = [];
  bool _isLoading = false;

  /// Fetches jokes from the service and updates the UI.
  Future<void> _fetchJokes() async {
    setState(() => _isLoading = true);
    try {
      _jokesRaw = await _jokeService.fetchJokesRaw(category: 'Programming');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch jokes: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Joke App',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade100, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              const SizedBox(height: 16),
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Get ready to laugh with random jokes!',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchJokes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Fetch Jokes',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.teal, // Changed color of activity indicator
                  ),
                )
                    : _buildJokeList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a list of jokes to display.
  Widget _buildJokeList() {
    if (_jokesRaw.isEmpty) {
      return const Center(
        child: Text(
          'No jokes fetched yet. Tap the button to get started!',
          style: TextStyle(fontSize: 16, color: Colors.teal),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(), // Smooth scrolling
      itemCount: _jokesRaw.length,
      itemBuilder: (context, index) {
        final joke = _jokesRaw[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Displaying the joke first
                  const Text(
                    'Joke:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    joke['setup'] != null
                        ? '${joke['setup']} - ${joke['delivery']}'
                        : (joke['joke'] ?? 'No joke available.'),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Divider(height: 20, color: Colors.teal),

                  // Displaying additional properties with updated styles
                  _buildPropertyRow('Joke Type:', joke['type']),
                  _buildPropertyRow('ID Range:', joke['idRange'] ?? 'N/A'),
                  _buildPropertyRow('Language:', joke['lang']),
                  _buildPropertyRow(
                    'Blacklist Flags:',
                    (joke['blacklistFlags'] as List<dynamic>?)?.join(", ") ?? 'None',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Helper function to build a row with styled title and content.
  Widget _buildPropertyRow(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87), // Normal text style
          children: [
            TextSpan(
              text: title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black, // Dark black for titles
              ),
            ),
            TextSpan(text: ' $content'),
          ],
        ),
      ),
    );
  }

}