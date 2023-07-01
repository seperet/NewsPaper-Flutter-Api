import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'package:bulten/pages/login_page.dart';
import 'package:bulten/settings_screen.dart';

class MyMobileBody extends StatefulWidget {
  const MyMobileBody({Key? key}) : super(key: key);

  @override
  _MyMobileBodyState createState() => _MyMobileBodyState();
}

class _MyMobileBodyState extends State<MyMobileBody> {
  bool isDarkModeEnabled = false;
  String selectedLanguage = 'English';
  String apiLanguage = 'en'; // API'den istenen dil kodu
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

      // Dil kodunu güncelle
      if (language == 'Türkçe') {
        apiLanguage = 'tr';
      } else {
        apiLanguage = 'en';
      }
    });

    // Yeni dili kullanarak haberleri yeniden yükle
    fetchPosts();
  }

  void fetchPosts() async {
    if (isFetching) return; // Yeni haberler yükleniyorsa, tekrar yükleme

    setState(() {
      isFetching = true;
    });

    var apiKey = 'Api Key';
    var url = Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=us&language=$apiLanguage&page=$page&apiKey=$apiKey');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var newPosts = data['articles'];
      setState(() {
        posts.addAll(newPosts);
        page++; // Sayfa numarasını artır
        isFetching = false;
      });

      // Haber başlıklarını çevir
      translatePostTitles();
    } else {
      print('Failed to fetch posts. Error code: ${response.statusCode}');
      setState(() {
        isFetching = false;
      });
    }
  }

  void translatePostTitles() async {
    var translatorApiKey = 'Api Key';
    var endpoint = Uri.parse(
        'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0');

    for (var post in posts) {
      var title = post['title'];

      var response = await http.post(
        endpoint,
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': translatorApiKey,
        },
        body: jsonEncode([
          {
            'text': title,
          },
        ]),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var translations = data[0]['translations'];
        var translatedTitle = translations[0]['text'];

        setState(() {
          post['title'] = translatedTitle;
        });
      } else {
        print(
            'Failed to translate post title. Error code: ${response.statusCode}');
      }
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
          child: ListView.builder(
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

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    String url = posts[index]['url'] ?? '';
                    launch(url);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        imageUrl != ''
                            ? Image.network(
                                imageUrl,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : Container(),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                description,
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                sourceName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
