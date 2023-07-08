import 'package:equatable/equatable.dart';

class FlutterData extends Equatable {
  final bool? usesMaterialDesign;
  final List<String>? assets;
  final bool? generate;
  final List<Font>? fonts;

  const FlutterData({
    this.usesMaterialDesign,
    this.assets,
    this.generate,
    this.fonts,
  });

  Map<String, dynamic> toMap() {
    return {
      if (usesMaterialDesign != null)
        'uses-material-design': usesMaterialDesign,
      if (assets != null && assets!.isNotEmpty) 'assets': assets,
      if (generate != null) 'generate': generate,
      if (fonts != null) 'fonts': fonts?.map((x) => x.toMap()).toList()
    };
  }

  factory FlutterData.fromMap(Map map) {
    return FlutterData(
      usesMaterialDesign: map['uses-material-design'],
      assets: map['assets'] != null && map['assets'] is List
          ? (map['assets'] as List).map((e) => e.toString()).toList()
          : null,
      generate: map['generate'],
      fonts: map['fonts'] != null && map['fonts'] is List
          ? (map['fonts'] as List).map((e) => Font.fromMap(e)).toList()
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [usesMaterialDesign, ...assets ?? [], generate, ...fonts ?? []];
}

class Font extends Equatable {
  final String family;
  final List<FontsData>? fonts;

  const Font({required this.family, this.fonts});

  Map<String, dynamic> toMap() {
    return {
      'family': family,
      if (fonts != null) 'fonts': fonts?.map((e) => e.toMap()).toList(),
    };
  }

  factory Font.fromMap(Map map) {
    return Font(
        family: map['family'] as String,
        fonts: map['fonts'] != null && map['fonts'] is List
            ? (map['fonts'] as List).map((e) => FontsData.fromMap(e)).toList()
            : null);
  }

  @override
  List<Object?> get props => [family, ...fonts ?? []];
}

class FontsData extends Equatable {
  final String asset;
  final int? weight;

  const FontsData({
    required this.asset,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'asset': asset,
      if (weight != null) 'weight': weight,
    };
  }

  factory FontsData.fromMap(Map map) {
    return FontsData(
      asset: map['asset'] as String,
      weight: map['weight'],
    );
  }

  @override
  List<Object?> get props => [asset, weight];
}
