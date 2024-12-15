import 'package:flutter/material.dart';
import 'package:tropicos_plants_app/model/plant_names.dart';

class PlantNameGridBookmarked extends StatelessWidget {
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
  const PlantNameGridBookmarked({
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
    // TODO: implement build
    throw UnimplementedError();
  }  
}