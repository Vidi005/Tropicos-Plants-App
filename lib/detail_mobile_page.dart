import 'package:flutter/material.dart';
import 'package:tropicos_plants_app/model/detail_plant_name.dart';
import 'package:tropicos_plants_app/model/plant_images.dart';
import 'package:tropicos_plants_app/utils/plant_map_converter.dart';

class DetailMobilePage extends StatelessWidget {
  final bool areImagesLoading;
  final bool isContentLoading;
  final DetailPlantName detailPlantName;
  final List<PlantImages> plantImages;
  const DetailMobilePage({
    super.key,
    required this.detailPlantName,
    required this.plantImages,
    required this.areImagesLoading,
    required this.isContentLoading,
  });

  @override
  Widget build(BuildContext context) {
    var detailPlantList = PlantMapConverter.convertToMap(
      detailPlantName.scientificNameAuthorship,
      detailPlantName.family,
      detailPlantName.rank,
      detailPlantName.nomenclatureStatusName,
      detailPlantName.symbol,
      detailPlantName.otherEpithet,
      detailPlantName.source,
      detailPlantName.citation,
      detailPlantName.copyright,
      detailPlantName.author,
      detailPlantName.namePublishedCitation,
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Hero(
                    tag: detailPlantName.nameId.toString(),
                    child: areImagesLoading
                        ? Stack(children: [
                            Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: MediaQuery.of(context).size.width,
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(8),
                              child: const CircularProgressIndicator(),
                            )
                          ])
                        : plantImages.isEmpty
                            ? Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: MediaQuery.of(context).size.width,
                              )
                            : Image.network(
                                plantImages[0].detailJpgUrl.toString(),
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                              )),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () {},
                          icon: Icon(
                            Icons.bookmark_border,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            plantImages.isEmpty
                ? SizedBox(
                    height: 10,
                    width: MediaQuery.of(context).size.width,
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      height: 200,
                      child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: plantImages
                              .map((imgUrl) => Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          width: 3,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          imgUrl.thumbnailUrl.toString(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList()),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                detailPlantName.scientificName.toString().toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              child: isContentLoading
                  ? const CircularProgressIndicator()
                  : Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: IntrinsicColumnWidth(),
                        2: FlexColumnWidth(),
                      },
                      children: detailPlantList.entries
                          .map((entry) => TableRow(
                                children: [
                                  TableCell(
                                    child: Text(
                                      entry.key,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
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
                                      entry.value.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
