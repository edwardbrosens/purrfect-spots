import 'dart:convert';
import 'package:flutter/services.dart';
import '../config/constants.dart';
import '../models/level_data.dart';
import 'xsb_parser.dart';

/// Loads and parses level definitions from bundled assets.
/// Supports both our JSON format and standard XSB format.
class LevelLoader {
  static final Map<String, LevelData> _cache = {};
  static List<LevelData>? _allLevels;

  /// XSB level packs to load (filename without extension).
  static const List<String> _xsbPacks = [
    'cafe',
  ];

  /// Load a single level by ID.
  static Future<LevelData> loadLevel(String levelId) async {
    if (_cache.containsKey(levelId)) {
      return _cache[levelId]!;
    }

    // Try loading from JSON first
    try {
      final jsonString =
          await rootBundle.loadString('assets/levels/$levelId.json');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final level = LevelData.fromJson(json);
      _cache[levelId] = level;
      return level;
    } catch (_) {
      // Not a JSON level — might be from an XSB pack
    }

    // Try loading all levels to find this ID
    if (_allLevels == null) {
      await loadAllLevels();
    }

    if (_cache.containsKey(levelId)) {
      return _cache[levelId]!;
    }

    throw Exception('Level $levelId not found');
  }

  /// Load all available levels from all sources.
  static Future<List<LevelData>> loadAllLevels() async {
    if (_allLevels != null) return _allLevels!;

    final levels = <LevelData>[];

    // Load XSB level packs
    for (final pack in _xsbPacks) {
      try {
        final xsbContent =
            await rootBundle.loadString('assets/levels/$pack.xsb');
        final packLevels = XsbParser.parseMultipleLevels(
          xsbContent,
          collectionName: _packDisplayName(pack),
          startFloor: levels.length + 1,
          defaultUndoLimit: GameConstants.defaultUndoLimit,
        );
        levels.addAll(packLevels);
      } catch (e) {
        // Pack not found — skip
      }
    }

    // Cache all levels
    for (final level in levels) {
      _cache[level.id] = level;
    }

    // Sort by floor number
    levels.sort((a, b) => a.floor.compareTo(b.floor));
    _allLevels = levels;
    return levels;
  }

  /// Display name for a pack file.
  static String _packDisplayName(String filename) {
    switch (filename) {
      case 'cafe':
        return 'Cat Café';
      default:
        return filename[0].toUpperCase() + filename.substring(1);
    }
  }

  /// Clear the cache.
  static void clearCache() {
    _cache.clear();
    _allLevels = null;
  }
}
