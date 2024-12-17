import 'package:flutter/material.dart';
import 'package:tropicos_plants_app/detail_screen.dart';
import 'package:tropicos_plants_app/model/detail_plant_name.dart';

class PlantNameGridBookmarked extends StatelessWidget {
  final int gridCount;
  final Function loadBookmarkedPlantList;
  final List<String> bookmarkedNameIds;
  final List<DetailPlantName> bookmarkedPlantNames;
  final Map<dynamic, dynamic> imageUrls;
  final bool isLoading;
  const PlantNameGridBookmarked({
    super.key,
    required this.gridCount,
    required this.loadBookmarkedPlantList,
    required this.bookmarkedNameIds,
    required this.bookmarkedPlantNames,
    required this.imageUrls,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (bookmarkedNameIds.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_remove_outlined,
              size: 144, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          const Text('No Bookmarked Plant Names'),
        ],
      );
    } else if (bookmarkedPlantNames.length < bookmarkedNameIds.length) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: gridCount,
              mainAxisSpacing: gridCount == 4 ? 8 : 16,
              crossAxisSpacing: gridCount == 4 ? 8 : 16,
              padding: const EdgeInsets.all(8),
              children: bookmarkedPlantNames.asMap().entries.map((entry) {
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        nameId:
                            bookmarkedPlantNames[entry.key].nameId.toString(),
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
                                        imageUrls[bookmarkedNameIds[entry.key]]
                                                    .toString()
                                                    .length >
                                                4
                                            ? Image.network(
                                                imageUrls[bookmarkedNameIds[
                                                        entry.key]]
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
                                        bookmarkedPlantNames[entry.key]
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
                                        bookmarkedPlantNames[entry.key]
                                                .family ??
                                            '-',
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
                                        bookmarkedPlantNames[entry.key]
                                                .author ??
                                            '-',
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
                                        'Rank',
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
                                        bookmarkedPlantNames[entry.key].rank ??
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
        ],
      );
    }
  }
}
