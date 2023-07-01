import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'package:bulten/pages/login_page.dart';
import 'package:bulten/settings_screen.dart';

class MyDesktopBody extends StatefulWidget {
  const MyDesktopBody({Key? key}) : super(key: key);

  @override
  _MyDesktopBodyState createState() => _MyDesktopBodyState();
}

class _MyDesktopBodyState extends State<MyDesktopBody> {
  bool isDarkModeEnabled = false;
  String selectedLanguage = 'English';
  List<dynamic> posts = [];
  int page = 1; // Sayfa numarası
  bool isFetching =
      false; // Yeni haberlerin yüklenip yüklenmediğini kontrol etmek için

  void navigateToLoginPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          onTap: () {},
        ),
      ),
    );
  }

  void navigateToSettingsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(),
      ),
    );
  }

  void toggleDarkMode() {
    setState(() {
      isDarkModeEnabled = !isDarkModeEnabled;
    });
  }

  void openLanguageSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Language Selection'),
          content: Text('Please select your language'),
          actions: [
            ElevatedButton(
              onPressed: () {
                changeLanguage('English');
                Navigator.pop(context);
              },
              child: Text('English'),
            ),
            ElevatedButton(
              onPressed: () {
                changeLanguage('Türkçe');
                Navigator.pop(context);
              },
              child: Text('Türkçe'),
            ),
          ],
        );
      },
    );
  }

  void changeLanguage(String language) {
    setState(() {
      selectedLanguage = language;
    });

    // Dil değiştirme mantığı
    // Örneğin, uygulamadaki dil ayarlarını güncelleme
  }

  void fetchPosts() async {
    if (isFetching) return; // Yeni haberler yükleniyorsa, tekrar yükleme

    setState(() {
      isFetching = true;
    });

    var apiKey = 'Api Key';
    var url = Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=us&page=$page&apiKey=$apiKey');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var newPosts = data['articles'];
      setState(() {
        posts.addAll(newPosts);
        page++; // Sayfa numarasını artır
        isFetching = false;
      });
    } else {
      print('Failed to fetch posts. Error code: ${response.statusCode}');
      setState(() {
        isFetching = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        isDarkModeEnabled ? Colors.black : Color.fromRGBO(117, 117, 117, 1);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(selectedLanguage == 'English' ? 'Newsletter' : 'Bülten'),
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.cog,
              color: Colors.white,
            ),
            onPressed: () {
              navigateToSettingsPage(context);
            },
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.userCircle,
              color: Colors.white,
            ),
            onPressed: () {
              navigateToLoginPage(context);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.dark_mode,
              color: isDarkModeEnabled ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              toggleDarkMode();
            },
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.language,
              color: Colors.white,
            ),
            onPressed: () {
              openLanguageSelection();
            },
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.sync,
              color: Colors.white,
            ),
            onPressed: () {
              fetchPosts();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!isFetching &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              fetchPosts(); // Sayfa sonuna gelindiğinde yeni haberleri yükle
            }
            return true;
          },
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // İki sütunlu grid
              crossAxisSpacing: 8, // Yatay boşluk
              mainAxisSpacing: 8, // Dikey boşluk
            ),
            itemCount: posts.length + 1,
            itemBuilder: (context, index) {
              if (index == posts.length) {
                // Yükleniyor göstergesini göster
                return Container(
                  padding: EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                );
              }

              String imageUrl = posts[index]['urlToImage'] ?? '';
              String title = posts[index]['title'] ?? '';
              String description = posts[index]['description'] ?? '';
              String sourceName = posts[index]['source']['name'] ?? '';

              return GestureDetector(
                onTap: () {
                  String url = posts[index]['url'] ?? '';
                  launch(url);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(189, 189, 189, 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                )
                              : Container(),
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Source: $sourceName',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
