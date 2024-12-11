class DetailPlantName {
  int? nameId;
  String? scientificName;
  String? scientificNameAuthorship;
  String? family;
  String? rank;
  String? nomenclatureStatusName;
  String? symbol;
  String? otherEpithet;
  String? source;
  String? citation;
  String? copyright;
  String? author;
  String? namePublishedCitation;
  List<String>? typeSpecimens;

  DetailPlantName({
    required this.nameId,
    required this.scientificName,
    required this.scientificNameAuthorship,
    required this.family,
    required this.rank,
    required this.nomenclatureStatusName,
    required this.symbol,
    required this.otherEpithet,
    required this.source,
    required this.citation,
    required this.copyright,
    required this.namePublishedCitation,
    required this.typeSpecimens,
  });

  factory DetailPlantName.fromJson(Map<String, dynamic> json) => DetailPlantName(
    nameId: json['NameId'],
    scientificName: json['ScientificName'],
    scientificNameAuthorship: json['ScientificNameWithAuthors'],
    family: json['fFamily'],
    rank: json['Rank'],
    nomenclatureStatusName: json['NomenclatureStatusName'],
    symbol: json['Symbol'],
    otherEpithet: json['OtherEpithet'],
    source: json['Source'],
    citation: json['Citation'],
    copyright: json['Copyright'],
    namePublishedCitation: json['NamePublishedCitation'],
    typeSpecimens: json['TypeSpecimens'].cast<String>(),
  );
}
