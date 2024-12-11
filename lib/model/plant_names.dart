class PlantNames {
  int? nameId;
  String? scientificName;
  String? scientificNameAuthorship;
  String? family;
  String? nomenclatureStatusName;
  String? author;
  String? displayReference;
  String? displayDate;
  int? totalRows;

  PlantNames({
    required this.nameId,
    required this.scientificName,
    required this.scientificNameAuthorship,
    required this.family,
    required this.nomenclatureStatusName,
    required this.author,
    required this.displayReference,
    required this.displayDate,
    required this.totalRows,
  });

  factory PlantNames.fromJson(Map<String, dynamic> json) => PlantNames(
    nameId: json['NameId'],
    scientificName: json['ScientificName'],
    scientificNameAuthorship: json['ScientificNameWithAuthors'],
    family: json['Family'],
    nomenclatureStatusName: json['NomenclatureStatusName'],
    author: json['Author'],
    displayReference: json['DisplayReference'],
    displayDate: json['DisplayDate'],
    totalRows: json['TotalRows'],
  );
}
