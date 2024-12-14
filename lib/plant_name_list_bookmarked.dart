import 'package:flutter/material.dart';
import 'package:tropicos_plants_app/detail_screen.dart';
import 'package:tropicos_plants_app/model/detail_plant_name.dart';

class PlantNameListBookmarked extends StatelessWidget {
  final Function loadBookmarkedPlantList;
  final List<String> bookmarkedNameIds;
  final List<DetailPlantName> bookmarkedPlantNames;
  final Map<dynamic, dynamic> imageUrls;
  final bool isLoading;
  const PlantNameListBookmarked({
    super.key,
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
              size: 96, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          const Text('No Bookmarked Plant Names'),
        ],
      );
    } else if (bookmarkedPlantNames.length < bookmarkedNameIds.length) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: bookmarkedNameIds.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    loadBookmarkedPlantList: loadBookmarkedPlantList,
                    nameId: bookmarkedPlantNames[index].nameId.toString(),
                  ),
                ),
              ),
              child: Hero(
                tag: bookmarkedNameIds[index].toString(),
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
                          child: imageUrls[bookmarkedNameIds[index]]
                                      .toString()
                                      .length >
                                  4
                              ? Image.network(
                                  imageUrls[bookmarkedNameIds[index]]
                                      .toString(),
                                  fit: BoxFit.cover,
                                )
                              : const FittedBox(
                                  fit: BoxFit.contain,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
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
                              bookmarkedPlantNames[index]
                                  .scientificName
                                  .toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
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
                                        bookmarkedPlantNames[index].family ??
                                            '-',
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
                                        bookmarkedPlantNames[index].author ??
                                            '-',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
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
                                        bookmarkedPlantNames[index].rank ?? '-',
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
      );
    }
  }
}
