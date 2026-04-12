import 'package:flutter/material.dart';
import 'package:purrfect_spots/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../models/leaderboard_entry.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../services/level_loader.dart';
import '../models/level_data.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  List<UserProfile> _globalRankings = [];
  List<LeaderboardEntry> _levelRankings = [];
  List<LevelData> _levels = [];
  String? _selectedLevelId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    _levels = await LevelLoader.loadAllLevels();

    try {
      _globalRankings = await _firestoreService.getGlobalLeaderboard();
    } catch (e) {
      // Offline
    }

    if (_levels.isNotEmpty) {
      _selectedLevelId = _levels.first.id;
      await _loadLevelRankings(_selectedLevelId!);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadLevelRankings(String levelId) async {
    try {
      _levelRankings = await _firestoreService.getLeaderboard(levelId);
    } catch (e) {
      _levelRankings = [];
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: CatCafeTheme.background,
      appBar: AppBar(
        title: Text(l.leaderboard),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/menu'),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: CatCafeTheme.darkText,
          indicatorColor: CatCafeTheme.darkText,
          tabs: [
            Tab(text: l.global),
            Tab(text: l.byFloor),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGlobalTab(),
                _buildLevelTab(),
              ],
            ),
    );
  }

  Widget _buildGlobalTab() {
    final l = AppLocalizations.of(context)!;
    if (_globalRankings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(l.noRankingsYet, style: const TextStyle(fontSize: 16)),
            Text(l.completeForRankings),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _globalRankings.length,
      itemBuilder: (context, index) {
        final user = _globalRankings[index];
        return _RankingCard(
          rank: index + 1,
          name: user.displayName ?? l.catLover,
          value: '${user.totalStars} ⭐',
          subtitle: l.floorsCleared(user.levelsCompleted),
        );
      },
    );
  }

  Widget _buildLevelTab() {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Level selector
        Container(
          padding: const EdgeInsets.all(12),
          child: DropdownButton<String>(
            value: _selectedLevelId,
            isExpanded: true,
            items: _levels.map((level) {
              return DropdownMenuItem(
                value: level.id,
                child: Text(l.floorNName(level.floor, level.name)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _selectedLevelId = value;
                _loadLevelRankings(value);
              }
            },
          ),
        ),
        // Rankings list
        Expanded(
          child: _levelRankings.isEmpty
              ? Center(
                  child: Text(l.noRankingsForFloor),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _levelRankings.length,
                  itemBuilder: (context, index) {
                    final entry = _levelRankings[index];
                    return _RankingCard(
                      rank: index + 1,
                      name: entry.displayName,
                      value: '${entry.moves} moves',
                      subtitle: null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RankingCard extends StatelessWidget {
  final int rank;
  final String name;
  final String value;
  final String? subtitle;

  const _RankingCard({
    required this.rank,
    required this.name,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final medal = rank <= 3
        ? ['🥇', '🥈', '🥉'][rank - 1]
        : '#$rank';

    return Card(
      color: CatCafeTheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          child: Center(
            child: Text(
              medal,
              style: TextStyle(
                fontSize: rank <= 3 ? 24 : 16,
                fontWeight: FontWeight.bold,
                color: CatCafeTheme.darkText,
              ),
            ),
          ),
        ),
        title: Text(name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: CatCafeTheme.primary,
          ),
        ),
      ),
    );
  }
}
