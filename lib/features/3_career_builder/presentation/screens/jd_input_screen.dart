import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/job_application_provider.dart';
import '../../providers/master_profile_provider.dart';
// import '../providers/job_application_provider.dart';
// import '../providers/master_profile_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import 'optimization_view_screen.dart';

class JdInputScreen extends StatefulWidget {
  const JdInputScreen({super.key});

  @override
  State<JdInputScreen> createState() => _JdInputScreenState();
}

class _JdInputScreenState extends State<JdInputScreen> {
  final _companyCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _jdCtrl = TextEditingController();
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _jdCtrl.addListener(() {
      final has = _jdCtrl.text.trim().length > 50;
      if (has != _hasContent) setState(() => _hasContent = has);
    });
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    _jdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: SafeArea(
        child: Consumer<JobApplicationProvider>(
          builder: (_, provider, __) {
            if (provider.isProcessing) return _buildProcessing(context, provider);
            if (provider.status == JobStatus.done) {
              // Auto-navigate to results
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OptimizationViewScreen()),
                  );
                }
              });
              return _buildProcessing(context, provider);
            }
            return _buildInput(context, provider);
          },
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context, JobApplicationProvider provider) {
    return Column(
      children: [
        // Header
        Padding(
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
                    Text('Target a Job',
                        style: Theme.of(context).textTheme.titleLarge),
                    Text('Paste the JD and get a perfect resume',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company + Role
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _companyCtrl,
                        style:
                         TextStyle(color: AppTheme.textPrimaryOf(context)),
                        decoration: const InputDecoration(
                          labelText: 'Company Name',
                          prefixIcon: Icon(
                              Icons.business_outlined,
                              size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _roleCtrl,
                        style:
                         TextStyle(color: AppTheme.textPrimaryOf(context)),
                        decoration: const InputDecoration(
                          labelText: 'Job Title',
                          prefixIcon: Icon(
                              Icons.work_outline_rounded,
                              size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Info box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.accent.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppTheme.accentLight, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Paste the full job description. The AI will extract required skills, detect company tone, calculate your match score, and rewrite your resume to target this role.',
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppTheme.textSecondaryOf(context),
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text('Job Description',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceOf(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderOf(context)),
                  ),
                  child: TextField(
                    controller: _jdCtrl,
                    maxLines: 14,
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.textPrimaryOf(context),
                        height: 1.6),
                    decoration: InputDecoration(
                      hintText:
                      'Paste the full job description here...\n\nExample:\nWe are looking for a Software Engineer with 1-2 years of experience in Flutter, Firebase, and REST APIs...',
                      hintStyle: GoogleFonts.dmSans(
                          color: AppTheme.textSecondaryOf(context)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(provider.error!,
                          style:
                          const TextStyle(color: AppTheme.error)),
                    ),
                  ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: GradientButton(
            label: 'Analyze & Build Resume',
            icon: Icons.rocket_launch_rounded,
            isLoading: provider.isProcessing,
            onPressed: _hasContent
                ? () {
              final profile = context
                  .read<MasterProfileProvider>()
                  .profile;
              context.read<JobApplicationProvider>().analyzeAndGenerate(
                companyName: _companyCtrl.text.trim().isEmpty
                    ? 'Company'
                    : _companyCtrl.text.trim(),
                roleTitle: _roleCtrl.text.trim().isEmpty
                    ? 'Role'
                    : _roleCtrl.text.trim(),
                jobDescription: _jdCtrl.text.trim(),
                profile: profile,
              );
            }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessing(BuildContext context,
      JobApplicationProvider provider) {
    final steps = [
      'Analyzing job description...',
      'Calculating match score...',
      'Writing targeted resume...',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                color: provider.status == JobStatus.generating
                    ? const Color(0xFF00C9FF)
                    : AppTheme.accent,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Building Your\nTargeted Resume',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              provider.statusLabel,
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: AppTheme.textSecondaryOf(context)),
            ),
          ],
        ),
      ),
    );
  }
}