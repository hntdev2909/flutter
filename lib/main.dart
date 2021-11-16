// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

List<Category> postFromJson(String str) =>
    List<Category>.from(json.decode(str).map((x) => Category.fromMap(x)));

class Category {
  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.category,
    required this.language,
    required this.country,
  });

  String id;
  String name;
  String url;
  String description;
  String category;
  String language;
  String country;

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        url: json["url"],
        description: json["description"],
        language: json["language"],
        country: json["country"],
        category: json["category"],
      );
}

class Post {
  Post({
    required this.source,
    required this.title,
    required this.url,
    required this.publishedAt,
  });

  List<Source> source;
  String title;
  String url;
  String publishedAt;

  factory Post.fromMap(Map<String, dynamic> json) => Post(
        source: List<Source>.from(json["items"].map((x) => Source.fromJson(x))),
        title: json['title'],
        url: json['url'],
        publishedAt: json['publishedAt'],
      );
}

class Source {
  Source({
    required this.name,
  });

  String name;

  factory Source.fromJson(Map<String, dynamic> json) => Source(
        name: json["name"],
      );
}

Future<List<Category>> fetchCategory() async {
  final response = await http.get(Uri.parse(
      'https://newsapi.org/v2/top-headlines/sources?country=us&apiKey=c15ef07f6a704ccaa87ee1341110f892'));

  if (response.statusCode == 200) {
    final parsed = json.decode(response.body);
    return parsed['sources']
        .map<Category>((json) => Category.fromMap(json))
        .toList();
  } else {
    throw Exception('Failed to load category');
  }
}

Future<List<Post>> fetchPost(category) async {
  final response = await http.get(Uri.parse(
      'https://newsapi.org/v2/top-headlines?category=${category}&country=us&apiKey=c15ef07f6a704ccaa87ee1341110f892'));

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body);
    return parsed['articles'].map<Post>((json) => Post.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load album');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter News',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter News'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Category>> futureCategory;
  late Future<List<Post>> futurePost;
  String category = 'general';

  @override
  void initState() {
    super.initState();
    futureCategory = fetchCategory();
    futurePost = fetchPost('general');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        toolbarHeight: 30,
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          Flexible(
            child: FutureBuilder<List<Category>>(
              future: futureCategory,
              builder: (context, AsyncSnapshot<List<Category>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 5.0, right: 5.0),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) => GestureDetector(
                      onTap: () {
                        print(snapshot.data![index].category);
                        fetchPost(snapshot.data![index].category);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Image.network(
                                  "https://images.unsplash.com/photo-1520209759809-a9bcb6cb3241?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8aW1nfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80",
                                ),
                              ),
                            ),
                            Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${snapshot.data![index].name}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "Roboto",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 16.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Flexible(
            flex: 6,
            child: FutureBuilder<List<Category>>(
              future: futureCategory,
              builder: (context, AsyncSnapshot<List<Category>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) => Container(
                        child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Image.network(
                                  "https://source.unsplash.com/random/300x200?sig=${Random().nextInt(123)}",
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                "${snapshot.data![index].name}",
                              ),
                              subtitle: Text(
                                "${snapshot.data![index].description}",
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
