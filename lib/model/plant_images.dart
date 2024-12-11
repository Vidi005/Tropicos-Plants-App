class PlantImages {
  int? nameId;
  int? imageId;
  String? nameText;
  int? specimenId;
  String? caption;
  String? imageKindText;
  String? thumbnailUrl;
  String? detailUrl;
  String? detailJpgUrl;

  PlantImages({
    required this.nameId,
    required this.imageId,
    required this.nameText,
    required this.specimenId,
    required this.caption,
    required this.imageKindText,
    required this.thumbnailUrl,
    required this.detailUrl,
    required this.detailJpgUrl,
  });

  factory PlantImages.fromJson(Map<String, dynamic> json) => PlantImages(
    nameId: json['NameId'],
    imageId: json['ImageId'],
    nameText: json['NameText'],
    specimenId: json['SpecimenId'],
    caption: json['Caption'],
    imageKindText: json['ImageKindText'],
    thumbnailUrl: json['ThumbnailUrl'],
    detailUrl: json['DetailUrl'],
    detailJpgUrl: json['DetailJpgUrl'],
  );
}
