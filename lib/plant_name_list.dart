import 'package:flutter/material.dart';
import 'package:tropicos_plants_app/detail_screen.dart';
import 'package:tropicos_plants_app/model/plant_names.dart';

class PlantNameList extends StatelessWidget {
  final bool isSearching;
  final String searchQuery;
  final int page;
  final int totalPages;
  final Function fetchPlantImages;
  final Function goToPreviousPage;
  final Function goToNextPage;
  final Function goToFirstPage;
  final Function goToLastPage;
  final List<PlantNames> plantNames;
  final Map<dynamic, dynamic> imageUrls;
  const PlantNameList({
    super.key,
    required this.plantNames,
    required this.searchQuery,
    required this.isSearching,
    required this.page,
    required this.totalPages,
    required this.fetchPlantImages,
    required this.goToPreviousPage,
    required this.goToNextPage,
    required this.goToFirstPage,
    required this.goToLastPage,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return const Center(child: CircularProgressIndicator());
    } else if (plantNames.isEmpty && searchQuery.length > 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_remove,
              size: 96, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          const Text('No results found!'),
        ],
      );
    } else if (plantNames.isEmpty) {
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
              itemCount: plantNames.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                fetchPlantImages(plantNames[index].nameId);
                return InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailScreen(plantNames: plantNames[index]))),
                  child: Hero(
                    tag: plantNames[index].nameId.toString(),
                    child: Card(
                      child: Row(children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                borderRadius: BorderRadius.circular(12)),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: imageUrls[plantNames[index].nameId]
                                          .toString()
                                          .length >
                                      4
                                  ? Image.network(
                                      imageUrls[plantNames[index].nameId]
                                          .toString(),
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
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
                                  plantNames[index].scientificName.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
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
                                            plantNames[index].family.toString(),
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
                                            plantNames[index].author.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        TableCell(
                                          child: Text(
                                            'Display Date',
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
                                            plantNames[index]
                                                .displayDate
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
                'Total: ${plantNames[0].totalRows} items',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  padding: const EdgeInsets.all(4),
                  onPressed: () => goToFirstPage(),
                  icon: const Icon(
                    Icons.first_page_outlined,
                    size: 24,
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.all(4),
                  onPressed: () => page > 1 ? goToPreviousPage() : null,
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    '$page / $totalPages',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.all(4),
                  onPressed: () => page < totalPages ? goToNextPage() : null,
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 24,
                  ),
                ),
                IconButton.filled(
                  padding: const EdgeInsets.all(4),
                  onPressed: () => goToLastPage(),
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
}
