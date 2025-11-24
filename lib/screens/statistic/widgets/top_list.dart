import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

// Layout constants to keep columns aligned between header and rows
const double _kRankWidth = 32.0; // circle width
const double _kGapAfterRank = 4.0;
const double _kSeparatorWidth = 1.0; // vertical line
const double _kSeparatorMargin = 4.0; // horizontal margin around separator
const double _kCountWidth = 60.0; // width allocated for the count text (increased to avoid wrapping)

class TopList extends StatefulWidget {
  final List<Map<String, String>>? data;
  final int initialVisible;

  const TopList({Key? key, this.data, this.initialVisible = 3}) : super(key: key);

  @override
  State<TopList> createState() => _TopListState();
}

class _TopListState extends State<TopList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final rows = (widget.data ?? <Map<String, String>>[]).take(10).toList();
    final visibleCount = _expanded ? rows.length : (rows.length >= widget.initialVisible ? widget.initialVisible : rows.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TopListHeader(),
        const SizedBox(height: 8),
        if (rows.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(child: Text('No hay barrios reportados', style: Theme.of(context).textTheme.bodySmall)),
          )
        ] else ...[
          ...rows.take(visibleCount).toList().asMap().entries.map((entry) {
            final idx = entry.key;
            final e = entry.value;
            final rank = (idx + 1).toString();
            final name = e['name'] ?? '';
            final count = e['count'] ?? '0';
            return _TopListItem(rank: rank, name: name, count: count);
          }),
        ],
        if (rows.length > widget.initialVisible) ...[
          const SizedBox(height: 8),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                elevation: 0,
                foregroundColor: Colors.black,
              ),
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(_expanded ? 'Ver menos' : 'Ver más'),
            ),
          ),
        ],
      ],
    );
  }
}

class _TopListHeader extends StatelessWidget {
  const _TopListHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Row(
        children: [
          const SizedBox(width: _kRankWidth + _kGapAfterRank),
          Expanded(
            child: Text('Barrio', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            width: _kSeparatorWidth + (_kSeparatorMargin * 2) + _kCountWidth,
            child: Text('Reportes', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _TopListItem extends StatelessWidget {
  final String rank;
  final String name;
  final String count;

  const _TopListItem({Key? key, required this.rank, required this.name, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.softBlue,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(rank, style: const TextStyle(fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: _kGapAfterRank),
          Expanded(
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          ),
          Container(height: 24, width: _kSeparatorWidth, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: _kSeparatorMargin)),
          SizedBox(width: _kCountWidth, child: Text(count, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
