import 'package:flutter/material.dart';
import 'package:tropicos_plants_app/helper/plant_map_converter.dart';
import 'package:tropicos_plants_app/model/detail_plant_name.dart';
import 'package:tropicos_plants_app/model/plant_images.dart';

class DetailWebPage extends StatefulWidget {
  final bool areImagesLoading;
  final bool isContentLoading;
  final DetailPlantName detailPlantName;
  final List<PlantImages> plantImages;
  final bool isBookmarked;
  final Future Function(String nameId) toggleBookmarkButton;
  const DetailWebPage({
    super.key,
    required this.detailPlantName,
    required this.plantImages,
    required this.areImagesLoading,
    required this.isContentLoading,
    required this.isBookmarked,
    required this.toggleBookmarkButton,
  });

  @override
  State<DetailWebPage> createState() => _DetailWebPageState();
}

class _DetailWebPageState extends State<DetailWebPage> {
  var scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var detailPlantList = PlantMapConverter.convertToMap(
      widget.detailPlantName.scientificNameAuthorship,
      widget.detailPlantName.family,
      widget.detailPlantName.rank,
      widget.detailPlantName.nomenclatureStatusName,
      widget.detailPlantName.symbol,
      widget.detailPlantName.otherEpithet,
      widget.detailPlantName.source,
      widget.detailPlantName.citation,
      widget.detailPlantName.copyright,
      widget.detailPlantName.author,
      widget.detailPlantName.namePublishedCitation,
    );
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 128),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plant Name'.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(children: [
                    Hero(
                      tag: widget.detailPlantName.nameId.toString(),
                      child: widget.areImagesLoading
                          ? Stack(
                              children: [
                                const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(8),
                                  child: const CircularProgressIndicator(),
                                ),
                              ],
                            )
                          : widget.plantImages.isEmpty
                              ? const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                )
                              : Image.network(
                                  widget.plantImages[0].detailJpgUrl.toString(),
                                  fit: BoxFit.cover,
                                ),
                    ),
                    const SizedBox(height: 16),
                    Scrollbar(
                      controller: scrollController,
                      child: widget.plantImages.isEmpty
                          ? const SizedBox(height: 10)
                          : Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: SizedBox(
                                height: 200,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: widget.plantImages
                                      .map(
                                        (imgUrl) => Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                width: 3,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                imgUrl.thumbnailUrl.toString(),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                    )
                  ]),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.detailPlantName.scientificName
                                    .toString()
                                    .toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'Lato',
                                ),
                              ),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Add to Bookmarks',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                    IconButton.filled(
                                      onPressed: () {
                                        if (!widget.isContentLoading) {
                                          widget.toggleBookmarkButton(
                                            widget.detailPlantName.nameId
                                                .toString(),
                                          );
                                        }
                                      },
                                      icon: Icon(
                                        widget.isBookmarked
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                    ),
                                  ])
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            alignment: Alignment.center,
                            child: widget.isContentLoading
                                ? const CircularProgressIndicator()
                                : Table(
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.top,
                                    columnWidths: const {
                                      0: IntrinsicColumnWidth(),
                                      1: IntrinsicColumnWidth(),
                                      2: FlexColumnWidth(),
                                    },
                                    children: detailPlantList.entries
                                        .map(
                                          (entry) => TableRow(
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
                                                  entry.value ?? '-',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  textAlign: TextAlign.justify,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
