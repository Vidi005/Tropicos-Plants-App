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
  Timer? debounceTimer;
  var searchQuery = '';
  var isSearching = false;
  var plantNames = <PlantNames>[];
  var sortOrder = 'ascending';
  var pageSize = 25;
  var startRow = 1;
  var page = 1;
  var totalPages = 1;

  searchPlantNames(query) {
    if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        startRow = 1;
        page = 1;
        searchQuery = query.toString().toLowerCase().trim();
        if (searchQuery.length >= 3) {
          fetchPlantNames(searchQuery, sortOrder, pageSize, startRow);
        } else {
          setState(() => plantNames.clear());
        }
      });
    });
  }

  sortPlantNames(order) {
    setState(() => sortOrder = order);
    fetchPlantNames(searchQuery, order, pageSize, startRow);
  }

  goToPreviousPage() {
    if (page > 1) {
      setState(() {
        startRow -= pageSize;
        page--;
      });
      fetchPlantNames(searchQuery, sortOrder, pageSize, startRow);
    }
  }

  goToNextPage() {
    if (page < totalPages) {
      setState(() {
        startRow += pageSize;
        page++;
      });
      fetchPlantNames(searchQuery, sortOrder, pageSize, startRow);
    }
  }

  goToFirstPage() {
    if (page > 1) {
      setState(() {
        startRow = 1;
        page = 1;
      });
      fetchPlantNames(searchQuery, sortOrder, pageSize, startRow);
    }
  }

  goToLastPage() {
    if (page < totalPages) {
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
      var response = await http.get(url);
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

  @override
  Widget build(BuildContext context) {
    const pageSizes = [10, 25, 50, 100];
    return Scaffold(
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
      ),
      body: Column(
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
                    shadowColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          )),
                    ),
                  ),
                ),
                PopupMenuButton(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
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
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'descending',
                      child: Text(
                        'Descending',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
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
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  onChanged: (value) {
                    setState(() {
                      pageSize = value as int;
                      startRow = 1;
                      page = 1;
                      fetchPlantNames(
                          searchQuery, sortOrder, value.toInt(), startRow);
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
              goToPreviousPage: goToPreviousPage,
              goToNextPage: goToNextPage,
              goToFirstPage: goToFirstPage,
              goToLastPage: goToLastPage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    debounceTimer?.cancel();
    super.dispose();
  }
}