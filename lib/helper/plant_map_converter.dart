class PlantMapConverter {
  static Map<dynamic, dynamic> convertToMap(scientificNameAuthorship, family, rank, nomenclatureStatusName, symbol, otherEpithet, source, citation, copyright, author, namePublishedCitation) {
    return {
      'Scientific Name Authorship': scientificNameAuthorship,
      'Family': family,
      'Rank': rank,
      'Nomenclature Status': nomenclatureStatusName,
      'Symbol': symbol,
      'Other Epithet': otherEpithet,
      'Source': source,
      'Citation': citation,
      'Copyright': copyright,
      'Author': author,
      'Published Citation': namePublishedCitation,
    };
  }
}
