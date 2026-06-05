import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/syllabus_provider.dart';
// import '../providers/syllabus_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';

class SyllabusTrackerScreen extends StatefulWidget {
  const SyllabusTrackerScreen({super.key});

  @override
  State<SyllabusTrackerScreen> createState() => _SyllabusTrackerScreenState();
}

class _SyllabusTrackerScreenState extends State<SyllabusTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<SyllabusProvider>(
                builder: (_, provider, __) {
                  if (provider.status == SyllabusStatus.loading ||
                      provider.status == SyllabusStatus.importing) {
                    return _buildLoading(provider.status);
                  }
                  if (!provider.hasUnits) return _buildEmpty(provider);
                  return _buildUnitList(provider);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _AddUnitFAB(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon:  Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimaryOf(context)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Syllabus Mapper',
                    style: Theme.of(context).textTheme.titleLarge),
                Consumer<SyllabusProvider>(
                  builder: (_, p, __) => Text(
                    '${(p.overallProgress * 100).toInt()}% of semester covered',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          // PDF Import button
          IconButton(
            icon:  Icon(Icons.upload_file_rounded,
                color: AppTheme.textSecondaryOf(context)),
            tooltip: 'Import syllabus PDF',
            onPressed: _importPdf,
          ),
        ],
      ),
    );
  }

  Future<void> _importPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      if (!mounted) return;
      await context
          .read<SyllabusProvider>()
          .importFromPdf(result.files.single.path!);
    }
  }

  Widget _buildLoading(SyllabusStatus status) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.accent),
          const SizedBox(height: 20),
          Text(
            status == SyllabusStatus.importing
                ? 'Parsing your syllabus...'
                : 'Loading...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(SyllabusProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderOf(context)),
            ),
            child: Column(
              children: [
                const Icon(Icons.menu_book_rounded,
                    color: AppTheme.accent, size: 44),
                const SizedBox(height: 16),
                Text(
                  'Set Up Your Syllabus',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Import your university syllabus once and the app will automatically track which units your lectures cover.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                GradientButton(
                  label: 'Import PDF Syllabus',
                  icon: Icons.upload_file_rounded,
                  onPressed: _importPdf,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _showManualEntrySheet(provider),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Type Manually'),
                  style: OutlinedButton.styleFrom(
                    side:  BorderSide(color: AppTheme.borderOf(context)),
                    foregroundColor: AppTheme.textSecondaryOf(context),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: AppTheme.error),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnitList(SyllabusProvider provider) {
    return Column(
      children: [
        // Overall progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderOf(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Overall Progress',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${(provider.overallProgress * 100).toInt()}%',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: provider.overallProgress,
                    backgroundColor: AppTheme.borderOf(context),
                    valueColor:
                    const AlwaysStoppedAnimation(AppTheme.accent),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: provider.units.length,
            itemBuilder: (_, i) => _UnitCard(
              unit: provider.units[i],
              onDelete: () => provider.deleteUnit(provider.units[i].id),
            ),
          ),
        ),
      ],
    );
  }

  void _showManualEntrySheet(SyllabusProvider provider) {
    final textCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paste Your Syllabus',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Paste your syllabus text. Use "Unit 1:", "Module 2:" etc. headers for best results.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textCtrl,
              maxLines: 8,
              style: TextStyle(color: AppTheme.textPrimaryOf(context)),
              decoration: const InputDecoration(
                hintText: 'Unit 1: Introduction to...\n  - Topic 1\n  - Topic 2\nUnit 2: ...',
              ),
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: 'Import Text',
              onPressed: () {
                if (textCtrl.text.trim().isNotEmpty) {
                  Navigator.pop(ctx);
                  provider.importFromText(textCtrl.text.trim());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Unit Card ────────────────────────────────────────────────────────────────
class _UnitCard extends StatelessWidget {
  final dynamic unit;
  final VoidCallback onDelete;

  const _UnitCard({required this.unit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final progress = unit.progressPercent as double;
    final progressColor = progress >= 1.0
        ? AppTheme.success
        : progress > 0
        ? AppTheme.amber
        : AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: progress >= 1.0
              ? AppTheme.success.withOpacity(0.3)
              : AppTheme.borderOf(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.unitNumber,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondaryOf(context),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unit.unitTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon:  Icon(Icons.more_vert,
                    color: AppTheme.textSecondaryOf(context), size: 18),
                color: AppTheme.surfaceElevOf(context),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onSelected: (v) {
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          color: AppTheme.error, size: 16),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: AppTheme.error)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.borderOf(context),
                    valueColor: AlwaysStoppedAnimation(progressColor),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: progressColor,
                ),
              ),
            ],
          ),
          if ((unit.sections as List).isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: (unit.sections as List<String>)
                  .take(4)
                  .map((s) => SkillChip(
                label: s.length > 30
                    ? '${s.substring(0, 30)}...'
                    : s,
                highlighted:
                (unit.coveredSections as List<String>).contains(s),
              ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Add Unit FAB ─────────────────────────────────────────────────────────────
class _AddUnitFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddUnitDialog(context),
      backgroundColor: AppTheme.accent,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        'Add Unit',
        style: GoogleFonts.spaceGrotesk(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showAddUnitDialog(BuildContext context) {
    final unitNumCtrl = TextEditingController();
    final unitTitleCtrl = TextEditingController();
    final sectionsCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Syllabus Unit',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            TextField(
              controller: unitNumCtrl,
              style: TextStyle(color: AppTheme.textPrimaryOf(context)),
              decoration: const InputDecoration(labelText: 'Unit Number (e.g. Unit 3)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitTitleCtrl,
              style: TextStyle(color: AppTheme.textPrimaryOf(context)),
              decoration: const InputDecoration(labelText: 'Unit Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: sectionsCtrl,
              maxLines: 4,
              style: TextStyle(color: AppTheme.textPrimaryOf(context)),
              decoration: const InputDecoration(
                labelText: 'Sections (one per line)',
                hintText: 'Introduction to Neural Networks\nBackpropagation\nActivation Functions',
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Add Unit',
              onPressed: () {
                final sections = sectionsCtrl.text
                    .split('\n')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
                context.read<SyllabusProvider>().addUnitManually(
                  unitNumber: unitNumCtrl.text.trim(),
                  unitTitle: unitTitleCtrl.text.trim(),
                  sections: sections,
                );
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}