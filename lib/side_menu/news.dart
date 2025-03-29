import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> newsList = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final response = await http.get(Uri.parse('https://flask-newsapi-render.onrender.com/'));

    if (response.statusCode == 200) {
      List<dynamic> allNews = json.decode(response.body);

      // Filter articles: urlToImage should not be null or empty, and image must be valid
      List<dynamic> filteredNews = [];
      for (var news in allNews) {
        if (news['urlToImage'] != null && news['urlToImage'].isNotEmpty) {
          bool isValid = await isValidImage(news['urlToImage']);
          if (isValid) {
            filteredNews.add(news);
          }
        }
      }

      setState(() {
        newsList = filteredNews;
      });
    } else {
      print("Error fetching news: ${response.statusCode}");
    }
  }

  // Function to check if an image URL is valid by making a HEAD request
  Future<bool> isValidImage(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200 && response.headers['content-type']?.startsWith('image') == true;
    } catch (e) {
      print("Invalid image: $url");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Latest News")),
      body: newsList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final news = newsList[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image at the top of the card
                      Image.network(
                        news['urlToImage'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news['title'] ?? "No Title",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              news['description'] ?? "No Description",
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            // Button to launch the news URL in browser.
                            ElevatedButton(
                              onPressed: () async {
                                final url = news['url'];
                                if (url != null && await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  print("Could not open $url");
                                }
                              },
                              child: Text("Read More"),
                            ),
                            SizedBox(height: 8),
                            // NOTE: Embedding an iframe directly in Flutter mobile is not supported.
                            // For Flutter web, you can use the HtmlElementView widget.
                            // Alternatively, consider using a package like webview_flutter to display web content.
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
