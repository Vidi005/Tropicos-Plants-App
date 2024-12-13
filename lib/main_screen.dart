import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tropicos_plants_app/model/plant_names.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tropicos_plants_app/plant_name_list.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late http.Client httpClient;
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

  @override
  initState() {
    super.initState();
    httpClient = http.Client();
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
        setState(() => imageUrls[nameId] = data[0]['ThumbnailUrl'] ?? '');
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

  cancelFetching() {
    httpClient.close();
    httpClient = http.Client();
    setState(() => imageUrls.clear());
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
                onPressed: () {},
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
            bottom: const TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
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
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth <= 600) {
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
                              PopupMenuButton(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
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
                                items: pageSizes.map((pageSize) {
                                  return DropdownMenuItem(
                                    value: pageSize,
                                    child: Text('$pageSize'),
                                  );
                                }).toList(),
                                value: pageSize,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
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
                            fetchPlantImages: fetchPlantImages,
                            goToPreviousPage: goToPreviousPage,
                            goToNextPage: goToNextPage,
                            goToFirstPage: goToFirstPage,
                            goToLastPage: goToLastPage,
                          ),
                        ),
                      ],
                    ),
                    const Column(),
                  ],
                );
              } else {
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
                              PopupMenuButton(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
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
                                items: pageSizes.map((pageSize) {
                                  return DropdownMenuItem(
                                    value: pageSize,
                                    child: Text('$pageSize'),
                                  );
                                }).toList(),
                                value: pageSize,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
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
                            fetchPlantImages: fetchPlantImages,
                            goToPreviousPage: goToPreviousPage,
                            goToNextPage: goToNextPage,
                            goToFirstPage: goToFirstPage,
                            goToLastPage: goToLastPage,
                          ),
                        ),
                      ],
                    ),
                    const Column(),
                  ],
                );
              }
            },
          )),
    );
  }

  @override
  void dispose() {
    plantNames.clear();
    imageUrls.clear();
    httpClient.close();
    debounceTimer?.cancel();
    super.dispose();
  }
}
