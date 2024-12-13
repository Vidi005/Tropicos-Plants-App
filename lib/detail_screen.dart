import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tropicos_plants_app/detail_mobile_page.dart';
import 'package:tropicos_plants_app/model/detail_plant_name.dart';
import 'package:tropicos_plants_app/model/plant_images.dart';
import 'package:tropicos_plants_app/model/plant_names.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final PlantNames plantNames;
  const DetailScreen({super.key, required this.plantNames});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late http.Client httpClient;
  var areImagesLoading = true;
  var isContentLoading = true;
  var plantImages = <PlantImages>[];
  var detailPlantName = DetailPlantName(
    nameId: 0,
    scientificName: '',
    scientificNameAuthorship: '',
    family: '',
    rank: '',
    nomenclatureStatusName: '',
    symbol: '',
    otherEpithet: '',
    source: '',
    citation: '',
    copyright: '',
    namePublishedCitation: '',
    typeSpecimens: [],
  );
  var isBookmarked = false;
  var bookmarkedNameIds = <String>[];

  @override
  void initState() {
    super.initState();
    httpClient = http.Client();
    fetchPlantImages();
    fetchDetailPlantName().then((_) => loadBookmarkedPlantNames());
  }

  Future fetchPlantImages() async {
    setState(() {
      plantImages.clear();
    });
    try {
      var apiKey = dotenv.env['API_KEY'] ?? '';
      const baseUrl = 'https://services.tropicos.org/Name/';
      var url = Uri.parse(
          '$baseUrl${widget.plantNames.nameId}/Images?apikey=$apiKey&format=json');
      var response = await httpClient.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data[0]['Error'] == null) {
          setState(() {
            plantImages.addAll((data as List)
                .map((item) => PlantImages.fromJson(item))
                .toList());
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
      setState(() => areImagesLoading = false);
    }
  }

  Future fetchDetailPlantName() async {
    try {
      var apiKey = dotenv.env['API_KEY'] ?? '';
      const baseUrl = 'https://services.tropicos.org/Name/';
      var url = Uri.parse(
          '$baseUrl${widget.plantNames.nameId}?apikey=$apiKey&format=json');
      var response = await httpClient.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          detailPlantName = DetailPlantName.fromJson(data);
        });
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
      setState(() => isContentLoading = false);
    }
  }

  Future loadBookmarkedPlantNames() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      bookmarkedNameIds = sharedPreferences.getStringList('savedNameIds') ?? [];
      isBookmarked =
          bookmarkedNameIds.contains(detailPlantName.nameId.toString());
    });
  }

  Future saveBookmarkedPlantNames() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setStringList('savedNameIds', bookmarkedNameIds);
  }

  Future toggleBookmarkButton(nameId) async {
    setState(() {
      if (bookmarkedNameIds.contains(nameId)) {
        bookmarkedNameIds.remove(nameId);
        isBookmarked = false;
      } else {
        bookmarkedNameIds.add(nameId);
        isBookmarked = true;
      }
    });
    await saveBookmarkedPlantNames();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 800) {
        return Container();
      } else {
        return DetailMobilePage(
          areImagesLoading: areImagesLoading,
          isContentLoading: isContentLoading,
          detailPlantName: detailPlantName,
          plantImages: plantImages,
          isBookmarked: isBookmarked,
          toggleBookmarkButton: toggleBookmarkButton,
        );
      }
    });
  }

  @override
  void dispose() {
    httpClient.close();
    super.dispose();
  }
}
