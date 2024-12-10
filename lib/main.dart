import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widgets/movie_card.dart';
import 'widgets/rating_stars.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: _isDarkMode ? Colors.white : Colors.black),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: _isDarkMode ? Colors.blueGrey : Colors.blue,
        ),
      ),
      home: MovieListScreen(onThemeChanged: _toggleTheme),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  final Function() onThemeChanged;

  MovieListScreen({required this.onThemeChanged});

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = false;

  Future<void> _searchMovies(String query) async {
    setState(() {
      _isLoading = true;
      _movies = [];
    });

    final response = await http.get(Uri.parse(
        'http://www.omdbapi.com/?apikey=369e99ad&s=$query'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['Response'] == 'True') {
        setState(() {
          _movies = jsonData['Search'].cast<Map<String, dynamic>>();
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ошибка поиска')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка сети')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie App'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.onThemeChanged,  // Переключаем тему
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Введите название фильма',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchMovies(_searchController.text),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  return MovieCard(
                    title: movie['Title'],
                    posterUrl: movie['Poster'] ?? 'https://via.placeholder.com/100x150',
                    year: movie['Year'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailsScreen(movieId: movie['imdbID']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class MovieDetailsScreen extends StatefulWidget {
  final String movieId;

  MovieDetailsScreen({required this.movieId});

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late Map<String, dynamic> _movieDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  Future<void> _fetchMovieDetails() async {
    final response = await http.get(
      Uri.parse('http://www.omdbapi.com/?apikey=369e99ad&i=${widget.movieId}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _movieDetails = data;
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить данные фильма')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Загрузка...' : _movieDetails['Title']),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                Image.network(
                  _movieDetails['Poster'] ?? 'https://via.placeholder.com/350x150',
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                ),
                SizedBox(height: 16),
                Text(
                  'Название: ${_movieDetails['Title']}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Год: ${_movieDetails['Year']}'),
                SizedBox(height: 8),
                Text('Жанр: ${_movieDetails['Genre'] ?? 'Не указан'}'),
                SizedBox(height: 8),
                Text(
                  'Рейтинг IMDb:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                RatingStars(
                  rating: double.tryParse(_movieDetails['imdbRating'] ?? '0') ?? 0,
                ),
                SizedBox(height: 16),
                Text(
                  'Описание:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(_movieDetails['Plot'] ?? 'Описание отсутствует'),
                SizedBox(height: 16),
              ],
            ),
    );
  }
}
