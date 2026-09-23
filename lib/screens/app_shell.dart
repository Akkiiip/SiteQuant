import 'package:flutter/material.dart';

import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sitequant_calculator_icon.dart';
import '../widgets/home_adaptive_banner_slot.dart';
import 'concrete_screen.dart';
import 'excavation_screen.dart';
import 'masonry_v2_screen.dart';
import 'paint_screen.dart';
import 'plaster_screen.dart';
import 'settings_screen.dart';
import 'shuttering_screen.dart';
import 'steel_weight_screen.dart';
import 'tile_screen.dart';
import 'unit_converter_screen.dart';
import 'volume_calculator_screen.dart';
import 'water_tank_screen.dart';

class SiteQuantShell extends StatefulWidget {
  const SiteQuantShell({super.key});
  @override
  State<SiteQuantShell> createState() => _SiteQuantShellState();
}

class _SiteQuantShellState extends State<SiteQuantShell> {
  var _index = 0;
  List<Widget> get _pages => [
    _DashboardPage(onSeeAll: () => setState(() => _index = 1)),
    _CalculatorBrowser(),
    _ToolsPage(),
    _LearnPage(),
    _ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: IndexedStack(index: _index, children: _pages),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      indicatorColor: AppTheme.primaryBlue.withValues(alpha: .14),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calculate_outlined),
          selectedIcon: Icon(Icons.calculate),
          label: 'Calculators',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view),
          label: 'Tools',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: 'Learn',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );
}

class _DashboardPage extends StatefulWidget {
  const _DashboardPage({required this.onSeeAll});
  final VoidCallback onSeeAll;
  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final entries = _calculatorEntries
        .take(8)
        .where(
          (entry) =>
              entry.title.toLowerCase().contains(query.toLowerCase()) ||
              entry.subtitle.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      children: [
        Row(
          children: [
            const Icon(
              Icons.architecture_rounded,
              color: AppTheme.navy,
              size: 32,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SiteQuant',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  Text(
                    'Civil Engineering Tools for the Jobsite',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.mutedInk),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: _SearchField(
            hint: 'Search calculators...',
            onChanged: (value) => setState(() => query = value),
          ),
        ),
        const SizedBox(height: 10),
        _HeroCard(onTap: widget.onSeeAll),
        const SizedBox(height: 8),
        const HomeAdaptiveBannerSlot(),
        const SizedBox(height: 8),
        _SectionTitle(
          title: 'Quick Calculators',
          action: 'See All',
          onAction: widget.onSeeAll,
        ),
        const SizedBox(height: 6),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No calculators found.'),
          )
        else
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 66,
              mainAxisSpacing: 6,
              crossAxisSpacing: 8,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final kind = SiteQuantCalculatorIcon.kindFor(entry.title)!;
              return Card(
                key: ValueKey('home-calculator-${kind.name}'),
                child: InkWell(
                  onTap: () => entry.open(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Row(
                      children: [
                        SiteQuantCalculatorIcon(kind: kind),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                entry.homeTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.ink,
                                ),
                              ),
                              Text(
                                entry.homeSubtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.mutedInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: SizedBox(
      height: 132,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/construction-hero.png',
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xF0081D3B),
                  Color(0xA0081D3B),
                  Color(0x20081D3B),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'From Drawings\nto Quantities\nin Seconds.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 30,
                  child: FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(
                      'See How →',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _CalculatorBrowser extends StatefulWidget {
  const _CalculatorBrowser();
  @override
  State<_CalculatorBrowser> createState() => _CalculatorBrowserState();
}

class _CalculatorBrowserState extends State<_CalculatorBrowser> {
  var _query = '';
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final filtered = _calculatorEntries.where((entry) {
      return entry.title.toLowerCase().contains(_query.toLowerCase()) &&
          (_tab == 0 || entry.category == _tab);
    }).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Calculators',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.search_rounded),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SearchField(
            hint: 'Search calculators...',
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: ['All', 'Structural', 'Finishing', 'Earthwork']
                .asMap()
                .entries
                .map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: _tab == entry.key,
                      onSelected: (_) => setState(() => _tab = entry.key),
                    ),
                  );
                })
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = filtered[index];
              return Card(
                child: ListTile(
                  leading: SiteQuantCalculatorIcon(
                    kind:
                        SiteQuantCalculatorIcon.kindFor(entry.title) ??
                        CalculatorArtwork.concrete,
                    size: 44,
                  ),
                  title: Text(entry.title),
                  subtitle: Text(entry.subtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => entry.open(context),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ToolsPage extends StatelessWidget {
  const _ToolsPage();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Tools',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 16),
      _tool(
        context,
        Icons.straighten_rounded,
        'Unit Converter',
        'Length, area, volume, weight',
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UnitConverterScreen()),
        ),
      ),
      _tool(
        context,
        Icons.request_quote_outlined,
        'Rate Analysis',
        'Material and labour rates',
        null,
      ),
      _tool(
        context,
        Icons.description_outlined,
        'BOQ Generator',
        'Coming soon',
        null,
      ),
      _tool(
        context,
        Icons.account_tree_outlined,
        'Project Tracker',
        'Track quantities',
        null,
      ),
    ],
  );
}

Widget _tool(
  BuildContext c,
  IconData i,
  String t,
  String s,
  VoidCallback? tap,
) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Card(
    child: ListTile(
      leading: _IconTile(icon: i, color: AppTheme.primaryBlue),
      title: Text(t),
      subtitle: Text(s),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: tap,
    ),
  ),
);

class _LearnPage extends StatelessWidget {
  const _LearnPage();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Learn',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 14),
      Card(
        color: AppTheme.navy,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Civil Engineering Quiz',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Test your knowledge\nLearn · Practice · Improve',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizScreen()),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryBlue,
                ),
                child: const Text('Start Quiz'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 22),
      Text('Topics', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.55,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: _topics
            .map(
              (t) => Card(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuizScreen()),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(t.$2, color: t.$3),
                        const Spacer(),
                        Text(
                          t.$1,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const Text(
                          '10 Questions',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.mutedInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ],
  );
}

final _topics = [
  ('RCC & Concrete', Icons.foundation_rounded, AppTheme.primaryBlue),
  ('Surveying', Icons.square_foot_rounded, const Color(0xFFF29A28)),
  ('Estimation & QS', Icons.calculate_outlined, const Color(0xFF7655C8)),
  ('Building Materials', Icons.inventory_2_outlined, const Color(0xFF169B65)),
  ('Soil Mechanics', Icons.terrain_outlined, const Color(0xFFAC6A2E)),
  ('Transportation', Icons.local_shipping_outlined, const Color(0xFF3284C3)),
  ('Environmental', Icons.eco_outlined, const Color(0xFF2C9A5A)),
  ('Construction Practice', Icons.engineering_outlined, AppTheme.navy),
];

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Profile',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 16),
      const ListTile(
        leading: CircleAvatar(child: Text('SQ')),
        title: Text('SiteQuant'),
        subtitle: Text('Tools and settings'),
      ),
      const SizedBox(height: 10),
      Card(
        color: AppTheme.navy,
        child: ListTile(
          leading: const Icon(
            Icons.workspace_premium_rounded,
            color: Color(0xFFFFC13B),
          ),
          title: const Text(
            'SiteQuant Pro',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            'Unlock advanced tools, BOQ and BBS',
            style: TextStyle(color: Colors.white70),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white),
        ),
      ),
      const SizedBox(height: 14),
      ...[
        'Saved Calculations',
        'My Projects',
        'Rate Library',
        'Help & Support',
        'Share SiteQuant',
        'About',
        'Settings',
      ].map(
        (label) => Card(
          child: ListTile(
            leading: const Icon(Icons.chevron_right_rounded),
            title: Text(label),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: label == 'Settings'
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  )
                : null,
          ),
        ),
      ),
    ],
  );
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  var _index = 0;
  int? _answer;
  var _score = 0;
  final _questions = const [
    (
      'The commonly used grade for residential RCC slabs in India is?',
      ['M10', 'M15', 'M20', 'M30'],
      2,
      'M20 is commonly used for residential reinforced concrete work.',
    ),
    (
      'Which test measures concrete workability?',
      ['Slump test', 'Sieve test', 'CBR test', 'Soundness test'],
      0,
      'The slump test is the standard on-site workability test.',
    ),
    (
      'Cement is normally measured in?',
      ['Litres', 'Bags', 'Metres', 'Kilograms only'],
      1,
      'Cement is typically ordered and estimated in bags.',
    ),
    (
      'A beam primarily resists?',
      ['Bending', 'Only compression', 'Only tension', 'Temperature'],
      0,
      'Beams transfer loads by resisting bending and shear.',
    ),
    (
      'Water-cement ratio affects?',
      [
        'Workability and strength',
        'Only colour',
        'Only aggregate size',
        'Only setting time',
      ],
      0,
      'It has a direct effect on strength and workability.',
    ),
    (
      'Which is a fine aggregate?',
      ['Sand', 'Gravel', 'Rebar', 'Cement'],
      0,
      'Sand is fine aggregate in concrete and mortar.',
    ),
    (
      'RCC stands for?',
      [
        'Reinforced Cement Concrete',
        'Rapid Concrete Course',
        'Ready Cement Compound',
        'Reinforced Clay Concrete',
      ],
      0,
      'RCC uses steel reinforcement with cement concrete.',
    ),
    (
      'A footing transfers load to?',
      ['Soil', 'Roof', 'Brickwork only', 'Plaster'],
      0,
      'Footings spread structural loads safely into soil.',
    ),
    (
      'Concrete curing helps improve?',
      ['Strength and durability', 'Colour only', 'Steel weight', 'Brick size'],
      0,
      'Curing supports hydration, strength and durability.',
    ),
    (
      'Which unit is used for concrete volume?',
      ['m³', 'm²', 'kg/m', 'litres per second'],
      0,
      'Concrete quantity is measured by volume in cubic metres.',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    if (_index == _questions.length) return _results(context);
    final q = _questions[_index];
    return Scaffold(
      appBar: AppBar(title: const Text('RCC & Concrete')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: _index / _questions.length),
            const SizedBox(height: 14),
            Text(
              'Question ${_index + 1} of 10',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 24),
            Text(q.$1, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            ...q.$2.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  onPressed: _answer == null
                      ? () => setState(() {
                          _answer = e.key;
                          if (e.key == q.$3) _score++;
                        })
                      : null,
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    minimumSize: const Size.fromHeight(52),
                    side: BorderSide(
                      color: _answer == e.key
                          ? (e.key == q.$3 ? Colors.green : Colors.red)
                          : AppTheme.border,
                    ),
                  ),
                  child: Text('${String.fromCharCode(65 + e.key)}  ${e.value}'),
                ),
              ),
            ),
            if (_answer != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_answer == q.$3 ? Colors.green : Colors.red)
                      .withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _answer == q.$3
                      ? 'Correct! ${q.$4}'
                      : 'Correct answer: ${q.$2[q.$3]}. ${q.$4}',
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _index++;
                    _answer = null;
                  }),
                  child: Text(_index == 9 ? 'See Results' : 'Next'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _results(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Quiz Results')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 64,
                  color: Color(0xFFF4AE00),
                ),
                const SizedBox(height: 14),
                Text(
                  'Great Job!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '$_score / 10',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
                Text(
                  '${_score * 10}%',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      _index = 0;
                      _score = 0;
                      _answer = null;
                    }),
                    child: const Text('Try Again'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const _SearchField({required this.hint, this.onChanged});
  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search_rounded),
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title, action;
  final VoidCallback onAction;
  const _SectionTitle({
    required this.title,
    required this.action,
    required this.onAction,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      TextButton(onPressed: onAction, child: Text(action)),
    ],
  );
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconTile({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: color),
  );
}

class _CalculatorEntry {
  final String title, subtitle;
  String get homeTitle =>
      title == 'RCC Water Tank' ? title : title.replaceAll(' Calculator', '');
  String get homeSubtitle => switch (homeTitle) {
    'Concrete' => 'Slabs & beams',
    'Masonry' => 'Bricks & AAC',
    'Plaster' => 'Wall & ceiling',
    'Paint' => 'Finishes',
    'Tiles & Flooring' => 'Tile area & pieces',
    'Shuttering' => 'Formwork',
    'Steel Weight' => 'Rebar quantity',
    'Excavation' => 'Earthwork',
    _ => 'RCC tank',
  };
  final IconData icon;
  final Color color;
  final int category;
  final void Function(BuildContext) open;
  const _CalculatorEntry(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.category,
    this.open,
  );
}

final _calculatorEntries = <_CalculatorEntry>[
  _CalculatorEntry(
    'Concrete Calculator',
    'Slabs, beams, columns, footings',
    Icons.foundation_rounded,
    AppTheme.primaryBlue,
    1,
    (c) {
      AnalyticsService.logCalculatorOpened('concrete');
      Navigator.push(
        c,
        MaterialPageRoute(builder: (_) => const ConcreteScreen()),
      );
    },
  ),
  _CalculatorEntry(
    'Masonry Calculator',
    'Bricks, AAC blocks, laterite',
    Icons.view_quilt_rounded,
    const Color(0xFFE87520),
    1,
    (c) {
      AnalyticsService.logCalculatorOpened('masonry');
      Navigator.push(
        c,
        MaterialPageRoute(builder: (_) => const MasonryV2Screen()),
      );
    },
  ),
  _CalculatorEntry(
    'Plaster Calculator',
    'Internal and external plaster',
    Icons.format_paint_rounded,
    const Color(0xFF169B65),
    2,
    (c) {
      AnalyticsService.logCalculatorOpened('plaster');
      Navigator.push(
        c,
        MaterialPageRoute(builder: (_) => const PlasterScreen()),
      );
    },
  ),
  _CalculatorEntry(
    'Paint Calculator',
    'Wall and ceiling paint',
    Icons.format_paint_outlined,
    const Color(0xFFF05252),
    2,
    (c) {
      AnalyticsService.logCalculatorOpened('paint');
      Navigator.push(c, MaterialPageRoute(builder: (_) => const PaintScreen()));
    },
  ),
  _CalculatorEntry(
    'Tiles & Flooring',
    'Floor, wall and skirting tiles',
    Icons.grid_on_rounded,
    AppTheme.primaryBlue,
    2,
    (c) => Navigator.push(
      c,
      MaterialPageRoute(builder: (_) => const TileScreen()),
    ),
  ),
  _CalculatorEntry(
    'Shuttering Calculator',
    'Formwork area for RCC elements',
    Icons.architecture_rounded,
    AppTheme.navy,
    1,
    (c) {
      Navigator.push(
        c,
        MaterialPageRoute(builder: (_) => const ShutteringScreen()),
      );
    },
  ),
  _CalculatorEntry(
    'RCC Water Tank',
    'Design and material estimation',
    Icons.water_drop_outlined,
    AppTheme.primaryBlue,
    1,
    (c) {
      Navigator.push(
        c,
        MaterialPageRoute(builder: (_) => const WaterTankScreen()),
      );
    },
  ),
  _CalculatorEntry(
    'Excavation Calculator',
    'Earthwork volume',
    Icons.construction_rounded,
    const Color(0xFFF29A28),
    3,
    (c) {
      AnalyticsService.logCalculatorOpened('excavation');
      Navigator.push(
        c,
        MaterialPageRoute(builder: (_) => const ExcavationScreen()),
      );
    },
  ),
  _CalculatorEntry(
    'Steel Weight Calculator',
    'Rebar weight and quantity',
    Icons.hardware_rounded,
    AppTheme.navy,
    1,
    (c) {
      AnalyticsService.logCalculatorOpened('steel_weight');
      Navigator.push(
        c,
        MaterialPageRoute(builder: (_) => const SteelWeightScreen()),
      );
    },
  ),
  _CalculatorEntry(
    'Volume Calculator',
    'Common structural volumes',
    Icons.view_in_ar_rounded,
    AppTheme.primaryBlue,
    1,
    (c) {
      AnalyticsService.logCalculatorOpened('volume');
      Navigator.push(
        c,
        MaterialPageRoute(builder: (_) => const VolumeCalculatorScreen()),
      );
    },
  ),
];
