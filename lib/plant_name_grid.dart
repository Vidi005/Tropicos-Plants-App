import 'package:flutter/material.dart';
import 'package:tropicos_plants_app/detail_screen.dart';
import 'package:tropicos_plants_app/model/plant_names.dart';

class PlantNameGrid extends StatelessWidget {
  final int gridCount;
  final bool isSearching;
  final String searchQuery;
  final int page;
  final int totalPages;
  final Function loadBookmarkedPlantList;
  final Function fetchPlantImages;
  final Function goToPreviousPage;
  final Function goToNextPage;
  final Function goToFirstPage;
  final Function goToLastPage;
  final List<PlantNames> plantNames;
  final Map<dynamic, dynamic> imageUrls;
  const PlantNameGrid({
    super.key,
    required this.gridCount,
    required this.isSearching,
    required this.searchQuery,
    required this.page,
    required this.totalPages,
    required this.loadBookmarkedPlantList,
    required this.fetchPlantImages,
    required this.goToPreviousPage,
    required this.goToNextPage,
    required this.goToFirstPage,
    required this.goToLastPage,
    required this.plantNames,
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
              size: 144, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            'No results found!',
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleMedium?.fontSize),
          ),
        ],
      );
    } else if (plantNames.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.manage_search_outlined,
              size: 144, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            'Type plant name to search',
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleMedium?.fontSize),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: gridCount,
              mainAxisSpacing: gridCount == 4 ? 8 : 16,
              crossAxisSpacing: gridCount == 4 ? 8 : 16,
              padding: const EdgeInsets.all(8),
              children: plantNames.asMap().entries.map((entry) {
                fetchPlantImages(plantNames[entry.key].nameId);
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        nameId: plantNames[entry.key].nameId.toString(),
                        loadBookmarkedPlantList: loadBookmarkedPlantList,
                      ),
                    ),
                  ),
                  child: Hero(
                    tag: entry.key,
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12)),
                                    child:
                                        imageUrls[plantNames[entry.key].nameId]
                                                    .toString()
                                                    .length >
                                                4
                                            ? Image.network(
                                                imageUrls[plantNames[entry.key]
                                                        .nameId]
                                                    .toString(),
                                                fit: BoxFit.fitHeight,
                                              )
                                            : const FittedBox(
                                                fit: BoxFit.fitHeight,
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface
                                              .withAlpha(192)),
                                      child: Text(
                                        plantNames[entry.key]
                                            .scientificName
                                            .toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.fontSize,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Table(
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
                                        plantNames[entry.key].family ?? '-',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        overflow: TextOverflow.ellipsis,
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
                                        plantNames[entry.key].author ?? '-',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        overflow: TextOverflow.ellipsis,
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
                                        plantNames[entry.key].displayDate ??
                                            '-',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                  ]),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
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
