import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../core/error_mapper.dart';
import '../../l10n_gen/app_localizations.dart';
import '../../repositories/report_repository.dart';

/// Thin wrapper so feature widgets never import repository internals.
class ReportRepositoryLite {
  static Future<void> submit({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  }) =>
      ReportRepository().submit(
          targetType: targetType, targetId: targetId, reason: reason, description: description);
}

/// Reusable report sheet body (posts, comments, accounts, messages).
class ReportSheetHolder extends StatefulWidget {
  final String targetType;
  final String targetId;
  final String title;
  const ReportSheetHolder(
      {super.key, required this.targetType, required this.targetId, required this.title});

  @override
  State<ReportSheetHolder> createState() => _ReportSheetHolderState();
}

class _ReportSheetHolderState extends State<ReportSheetHolder> {
  String _reason = 'spam';
  final _desc = TextEditingController();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final reasons = {
      'spam': l.reasonSpam,
      'harassment': l.reasonHarassment,
      'inappropriate': l.reasonInappropriate,
      'other': l.reasonOther,
    };
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: reasons.entries
                  .map((e) => ChoiceChip(
                        label: Text(e.value),
                        selected: _reason == e.key,
                        onSelected: (_) => setState(() => _reason = e.key),
                        selectedColor: NexColors.accent,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            TextField(controller: _desc, maxLines: 2,
                decoration: InputDecoration(hintText: l.optionalDescription)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      try {
                        await ReportRepositoryLite.submit(
                            targetType: widget.targetType,
                            targetId: widget.targetId,
                            reason: _reason,
                            description: _desc.text);
                        if (context.mounted) {
                          showSnack(context, l.reportSent);
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) showSnack(context, friendlyError(e, l));
                        if (context.mounted) setState(() => _busy = false);
                      }
                    },
              child: Text(l.report),
            ),
          ]),
    );
  }
}
