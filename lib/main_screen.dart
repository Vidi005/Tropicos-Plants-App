import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tropicos_plants_app/about_page.dart';
import 'package:tropicos_plants_app/model/detail_plant_name.dart';
import 'package:tropicos_plants_app/model/plant_names.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tropicos_plants_app/plant_name_grid.dart';
import 'package:tropicos_plants_app/plant_name_list.dart';
import 'package:tropicos_plants_app/plant_name_list_bookmarked.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late http.Client httpClient;
  late http.Client httpClientBookmark;
  Timer? debounceTimer;
  var searchQuery = '';
  var isSearching = false;
  var plantNames = <PlantNames>[];
  var sortOrder = 'ascending';
  var pageSize = 25;
  var startRow = 1;
  var page = 1;
  var totalPages = 1;
  var imageUrls = {};
  var isLoading = false;
  var bookmarkedNameIds = <String>[];
  var bookmarkedPlantNames = <DetailPlantName>[];
  var bookmarkedImageUrls = {};

  @override
  initState() {
    super.initState();
    httpClient = http.Client();
    httpClientBookmark = http.Client();
    loadBookmarkedPlantList();
  }

  searchPlantNames(query) {
    cancelFetching();
    if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        startRow = 1;
        page = 1;
        searchQuery = query.toString().toLowerCase().trim();
        if (searchQuery.length >= 3) {
          httpClient = http.Client();
          fetchPlantNames(searchQuery, sortOrder, pageSize, startRow);
        } else {
          cancelFetching();
          plantNames.clear();
        }
      });
    });
  }

  sortPlantNames(order) {
    cancelFetching();
    setState(() => sortOrder = order);
    fetchPlantNames(searchQuery, order, pageSize, startRow);
  }

  goToPreviousPage() {
    if (page > 1) {
      cancelFetching();
      setState(() {
        startRow -= pageSize;
        page--;
      });
      fetchPlantNames(searchQuery, sortOrder, pageSize, startRow);
    }
  }

  goToNextPage() {
    if (page < totalPages) {
      cancelFetching();
      setState(() {
        startRow += pageSize;
        page++;
      });
      fetchPlantNames(searchQuery, sortOrder, pageSize, startRow);
    }
  }

  goToFirstPage() {
    if (page > 1) {
      cancelFetching();
      setState(() {
        startRow = 1;
        page = 1;
      });
      fetchPlantNames(searchQuery, sortOrder, pageSize, startRow);
    }
  }

  goToLastPage() {
    if (page < totalPages) {
      cancelFetching();
      setState(() {
        startRow = (totalPages - 1) * pageSize + 1;
        page = totalPages;
      });
      fetchPlantNames(searchQuery, sortOrder, pageSize, startRow);
    }
  }

  Future fetchPlantNames(query, order, pageSize, startRow) async {
    setState(() {
      plantNames.clear();
      isSearching = true;
    });
    try {
      var apiKey = dotenv.env['API_KEY'] ?? '';
      const baseUrl = 'https://services.tropicos.org/Name/Search';
      var url = Uri.parse(
          '$baseUrl?commonname=$query&sortorder=$order&pagesize=$pageSize&startrow=$startRow&apikey=$apiKey&format=json');
      var response =
          await httpClient.get(url).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data[0]['Error'] == null) {
          setState(() {
            plantNames.addAll((data as List)
                .map((item) => PlantNames.fromJson(item))
                .toList());
            totalPages = (data[0]['TotalRows'] / pageSize).ceil();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${response.statusCode}'),
            duration: const Duration(seconds: 3),
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 3),
        ));
      }
    } finally {
      setState(() => isSearching = false);
    }
  }

  Future fetchPlantImages(nameId) async {
    if (imageUrls.containsKey(nameId)) {
      return;
    }
    try {
      var apiKey = dotenv.env['API_KEY'] ?? '';
      const baseUrl = 'https://services.tropicos.org/Name';
      var url = Uri.parse('$baseUrl/$nameId/Images?apikey=$apiKey&format=json');
      var response = await httpClient.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          if (MediaQuery.of(context).size.width <= 640) {
            imageUrls[nameId] = data[0]['ThumbnailUrl'] ?? '';
          } else {
            imageUrls[nameId] = data[0]['DetailJpgUrl'] ?? '';
          }
        });
      }
    } catch (e) {
      return;
    }
  }

  Future fetchDetailPlantName(nameId) async {
    try {
      var apiKey = dotenv.env['API_KEY'] ?? '';
      const baseUrl = 'https://services.tropicos.org/Name/';
      var url = Uri.parse('$baseUrl$nameId?apikey=$apiKey&format=json');
      var response = await httpClientBookmark.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var detailPlantName = DetailPlantName.fromJson(data);
        setState(() => bookmarkedPlantNames.add(detailPlantName));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${response.statusCode}'),
            duration: const Duration(seconds: 3),
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 3),
        ));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future fetchBookmarkedPlantImages(nameId) async {
    if (bookmarkedImageUrls.containsKey(nameId)) {
      return;
    }
    try {
      var apiKey = dotenv.env['API_KEY'] ?? '';
      const baseUrl = 'https://services.tropicos.org/Name';
      var url = Uri.parse('$baseUrl/$nameId/Images?apikey=$apiKey&format=json');
      var response = await httpClientBookmark.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          if (MediaQuery.sizeOf(context).width <= 640) {
            bookmarkedImageUrls[nameId] = data[0]['ThumbnailUrl'] ?? '';
          } else {
            bookmarkedImageUrls[nameId] = data[0]['DetailJpgUrl'] ?? '';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }

  Future loadBookmarkedPlantList() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      bookmarkedNameIds = sharedPreferences.getStringList('savedNameIds') ?? [];
      if (bookmarkedNameIds.isNotEmpty) {
        isLoading = true;
      } else {
        isLoading = false;
      }
      httpClientBookmark.close();
      httpClientBookmark = http.Client();
      bookmarkedPlantNames.clear();
      bookmarkedImageUrls.clear();
    });
    for (var nameId in bookmarkedNameIds) {
      await fetchDetailPlantName(nameId)
          .then((_) => fetchBookmarkedPlantImages(nameId));
    }
  }

  cancelFetching() {
    httpClient.close();
    httpClient = http.Client();
    imageUrls.clear();
  }

  @override
  Widget build(BuildContext context) {
    const pageSizes = [10, 25, 50, 100];
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tropicos Plants App'),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shadowColor: Theme.of(context).shadowColor,
          actions: [
            IconButton.filled(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutPage())),
              icon: const Icon(
                Icons.info,
                color: Colors.white,
              ),
            ),
          ],
          leading: IconButton.filled(
            onPressed: () {},
            icon: Image.asset('images/app-icon.png', width: 24, height: 24),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
                Theme.of(context).appBarTheme.toolbarHeight ?? kToolbarHeight),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth <= 640) {
                  return const TabBar(
                    indicatorColor: Colors.white,
                    indicatorWeight: 4,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    unselectedLabelStyle:
                        TextStyle(fontWeight: FontWeight.normal),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list_alt),
                            SizedBox(width: 8),
                            Text('Name List'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_added),
                            SizedBox(width: 8),
                            Text('Bookmarked'),
                          ],
                        ),
                      ),
                    ],
                  );
                } else if (constraints.maxWidth <= 1024) {
                  return Container(
                    color: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: TabBar(
                      indicatorColor: Theme.of(context).colorScheme.secondary,
                      indicatorWeight: 4,
                      dividerColor: Theme.of(context).colorScheme.primary,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor:
                          Theme.of(context).colorScheme.primary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      unselectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.normal),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.list_alt),
                              const SizedBox(width: 16),
                              Text(
                                'Name List',
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.fontSize),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bookmark_added),
                              const SizedBox(width: 16),
                              Text(
                                'Bookmarked',
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.fontSize),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    color: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: TabBar(
                      indicatorColor: Theme.of(context).colorScheme.secondary,
                      indicatorWeight: 4,
                      dividerColor: Theme.of(context).colorScheme.primary,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor:
                          Theme.of(context).colorScheme.primary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      unselectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.normal),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.list_alt),
                              const SizedBox(width: 16),
                              Text(
                                'Name List',
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.fontSize),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bookmark_added),
                              const SizedBox(width: 16),
                              Text(
                                'Bookmarked',
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.fontSize),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 640) {
              return TabBarView(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Theme.of(context).colorScheme.onPrimary,
                        child: Row(
                          children: [
                            Expanded(
                              child: SearchBar(
                                onChanged: (value) => searchPlantNames(value),
                                hintText: 'Search Plant Names...',
                                onSubmitted: (value) => searchPlantNames(value),
                                shadowColor: const WidgetStatePropertyAll(
                                    Colors.transparent),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 1,
                                      )),
                                ),
                              ),
                            ),
                            PopupMenuButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              icon: Icon(
                                Icons.sort_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onSelected: (value) => sortPlantNames(value),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'ascending',
                                  child: Text(
                                    'Ascending',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'descending',
                                  child: Text(
                                    'Descending',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                ),
                              ],
                            ),
                            DropdownButton(
                              borderRadius: BorderRadius.circular(8),
                              items: pageSizes.map((pageSize) {
                                return DropdownMenuItem(
                                  value: pageSize,
                                  child: Text('$pageSize'),
                                );
                              }).toList(),
                              value: pageSize,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                              onChanged: (value) {
                                setState(() {
                                  pageSize = value as int;
                                  startRow = 1;
                                  page = 1;
                                  fetchPlantNames(searchQuery, sortOrder,
                                      value.toInt(), startRow);
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: PlantNameList(
                          isSearching: isSearching,
                          searchQuery: searchQuery,
                          plantNames: plantNames,
                          page: page,
                          totalPages: totalPages,
                          imageUrls: imageUrls,
                          loadBookmarkedPlantList: loadBookmarkedPlantList,
                          fetchPlantImages: fetchPlantImages,
                          goToPreviousPage: goToPreviousPage,
                          goToNextPage: goToNextPage,
                          goToFirstPage: goToFirstPage,
                          goToLastPage: goToLastPage,
                        ),
                      ),
                    ],
                  ),
                  PlantNameListBookmarked(
                    loadBookmarkedPlantList: loadBookmarkedPlantList,
                    isLoading: isLoading,
                    bookmarkedNameIds: bookmarkedNameIds.reversed.toList(),
                    bookmarkedPlantNames:
                        bookmarkedPlantNames.reversed.toList(),
                    imageUrls: bookmarkedImageUrls,
                  ),
                ],
              );
            } else if (constraints.maxWidth <= 1280) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                child: TabBarView(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]),
                          child: Row(
                            children: [
                              Expanded(
                                child: SearchBar(
                                  onChanged: (value) => searchPlantNames(value),
                                  hintText: 'Search Plant Names...',
                                  onSubmitted: (value) =>
                                      searchPlantNames(value),
                                  shadowColor: const WidgetStatePropertyAll(
                                      Colors.transparent),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 1,
                                        )),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Sort :',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.fontSize,
                                  ),
                                ),
                              ),
                              PopupMenuButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                icon: Icon(
                                  Icons.sort_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onSelected: (value) => sortPlantNames(value),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'ascending',
                                    child: Text(
                                      'Ascending',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.fontSize),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'descending',
                                    child: Text(
                                      'Descending',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.fontSize),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Entries :',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.fontSize,
                                  ),
                                ),
                              ),
                              DropdownButton(
                                borderRadius: BorderRadius.circular(8),
                                items: pageSizes.map((pageSize) {
                                  return DropdownMenuItem(
                                    value: pageSize,
                                    child: Text('$pageSize'),
                                  );
                                }).toList(),
                                value: pageSize,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.fontSize,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    pageSize = value as int;
                                    startRow = 1;
                                    page = 1;
                                    fetchPlantNames(searchQuery, sortOrder,
                                        value.toInt(), startRow);
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: PlantNameGrid(
                            gridCount: 4,
                            isSearching: isSearching,
                            searchQuery: searchQuery,
                            plantNames: plantNames,
                            page: page,
                            totalPages: totalPages,
                            imageUrls: imageUrls,
                            loadBookmarkedPlantList: loadBookmarkedPlantList,
                            fetchPlantImages: fetchPlantImages,
                            goToPreviousPage: goToPreviousPage,
                            goToNextPage: goToNextPage,
                            goToFirstPage: goToFirstPage,
                            goToLastPage: goToLastPage,
                          ),
                        ),
                      ],
                    ),
                    PlantNameListBookmarked(
                      loadBookmarkedPlantList: loadBookmarkedPlantList,
                      isLoading: isLoading,
                      bookmarkedNameIds: bookmarkedNameIds,
                      bookmarkedPlantNames: bookmarkedPlantNames,
                      imageUrls: bookmarkedImageUrls,
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 64, vertical: 4),
                child: TabBarView(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]),
                          child: Row(
                            children: [
                              Expanded(
                                child: SearchBar(
                                  onChanged: (value) => searchPlantNames(value),
                                  hintText: 'Search Plant Names...',
                                  onSubmitted: (value) =>
                                      searchPlantNames(value),
                                  shadowColor: const WidgetStatePropertyAll(
                                      Colors.transparent),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 1,
                                        )),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Sort :',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.fontSize,
                                  ),
                                ),
                              ),
                              PopupMenuButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                icon: Icon(
                                  Icons.sort_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onSelected: (value) => sortPlantNames(value),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'ascending',
                                    child: Text(
                                      'Ascending',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.fontSize),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'descending',
                                    child: Text(
                                      'Descending',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.fontSize),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Entries :',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.fontSize,
                                  ),
                                ),
                              ),
                              DropdownButton(
                                borderRadius: BorderRadius.circular(8),
                                items: pageSizes.map((pageSize) {
                                  return DropdownMenuItem(
                                    value: pageSize,
                                    child: Text('$pageSize'),
                                  );
                                }).toList(),
                                value: pageSize,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.fontSize,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    pageSize = value as int;
                                    startRow = 1;
                                    page = 1;
                                    fetchPlantNames(searchQuery, sortOrder,
                                        value.toInt(), startRow);
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: PlantNameGrid(
                            gridCount: 5,
                            isSearching: isSearching,
                            searchQuery: searchQuery,
                            plantNames: plantNames,
                            page: page,
                            totalPages: totalPages,
                            imageUrls: imageUrls,
                            loadBookmarkedPlantList: loadBookmarkedPlantList,
                            fetchPlantImages: fetchPlantImages,
                            goToPreviousPage: goToPreviousPage,
                            goToNextPage: goToNextPage,
                            goToFirstPage: goToFirstPage,
                            goToLastPage: goToLastPage,
                          ),
                        ),
                      ],
                    ),
                    PlantNameListBookmarked(
                      loadBookmarkedPlantList: loadBookmarkedPlantList,
                      isLoading: isLoading,
                      bookmarkedNameIds: bookmarkedNameIds,
                      bookmarkedPlantNames: bookmarkedPlantNames,
                      imageUrls: bookmarkedImageUrls,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    plantNames.clear();
    imageUrls.clear();
    bookmarkedPlantNames.clear();
    bookmarkedImageUrls.clear();
    httpClient.close();
    httpClientBookmark.close();
    debounceTimer?.cancel();
    super.dispose();
  }
}
