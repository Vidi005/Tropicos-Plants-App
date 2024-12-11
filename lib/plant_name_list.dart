import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tropicos_plants_app/model/plant_names.dart';
import 'package:http/http.dart' as http;

class PlantNameList extends StatefulWidget {
  final bool isSearching;
  final String searchQuery;
  final int page;
  final int totalPages;
  final Function goToPreviousPage;
  final Function goToNextPage;
  final Function goToFirstPage;
  final Function goToLastPage;
  final List<PlantNames> plantNames;
  const PlantNameList({
    super.key,
    required this.plantNames,
    required this.searchQuery,
    required this.isSearching,
    required this.page,
    required this.totalPages,
    required this.goToPreviousPage,
    required this.goToNextPage,
    required this.goToFirstPage,
    required this.goToLastPage,
  });

  @override
  State<PlantNameList> createState() => _PlantNameListState();
}

class _PlantNameListState extends State<PlantNameList> {
  late http.Client httpClient;
  var imageUrls = {};

  @override
  initState() {
    super.initState();
    httpClient = http.Client();
  }

  @override
  didUpdateWidget(PlantNameList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plantNames != widget.plantNames ||
        oldWidget.searchQuery != widget.searchQuery) {
      cancelFetchingPlantImages();
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

  cancelFetchingPlantImages() {
    httpClient.close();
    httpClient = http.Client();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSearching) {
      setState(() => imageUrls.clear());
      return const Center(child: CircularProgressIndicator());
    } else if (widget.plantNames.isEmpty && widget.searchQuery.length > 2) {
      setState(() => imageUrls.clear());
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_remove,
              size: 96, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          const Text('No results found!'),
        ],
      );
    } else if (widget.plantNames.isEmpty) {
      setState(() => imageUrls.clear());
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.manage_search_outlined,
              size: 96, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          const Text('Type plant name to search'),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.plantNames.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                fetchPlantImages(widget.plantNames[index].nameId);
                return InkWell(
                  onTap: () {},
                  child: Hero(
                    tag: widget.plantNames[index].nameId.toString(),
                    child: Card(
                      child: Row(children: [
                        Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            child: imageUrls[widget.plantNames[index].nameId]
                                        .toString()
                                        .length >
                                    4
                                ? Image.network(
                                    imageUrls[widget.plantNames[index].nameId]
                                        .toString(),
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.plantNames[index].scientificName
                                      .toString(),
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Table(
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.top,
                                    columnWidths: const {
                                      0: IntrinsicColumnWidth(),
                                      1: IntrinsicColumnWidth(),
                                      2: FlexColumnWidth(),
                                    },
                                    children: [
                                      TableRow(children: [
                                        TableCell(
                                          child: Text(
                                            'Family',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                        TableCell(
                                          child: Text(
                                            ' : ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        TableCell(
                                          child: Text(
                                            widget.plantNames[index].family
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        TableCell(
                                          child: Text(
                                            'Author',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                        TableCell(
                                          child: Text(
                                            ' : ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        TableCell(
                                          child: Text(
                                            widget.plantNames[index].author
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ),
                                      ]),
                                    ]),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                'Total: ${widget.plantNames[0].totalRows} items',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: () {
                    cancelFetchingPlantImages();
                    widget.goToFirstPage();
                  },
                  icon: const Icon(
                    Icons.first_page_outlined,
                    size: 24,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    cancelFetchingPlantImages();
                    widget.page > 1 ? widget.goToPreviousPage() : null;
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    '${widget.page} / ${widget.totalPages}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    cancelFetchingPlantImages();
                    widget.page < widget.totalPages
                        ? widget.goToNextPage()
                        : null;
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 24,
                  ),
                ),
                IconButton.filled(
                  onPressed: () {
                    cancelFetchingPlantImages();
                    widget.goToLastPage();
                  },
                  icon: const Icon(
                    Icons.last_page_outlined,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    httpClient.close();
    super.dispose();
  }
}
