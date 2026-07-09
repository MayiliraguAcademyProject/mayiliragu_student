import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/question_model.dart';
import '../../models/student_answer_model.dart';

class SingleChoiceLayout extends StatelessWidget {
  final QuestionModel question;
  final StudentAnswer? answer;
  final Function(String) onOptionSelected;

  const SingleChoiceLayout({
    super.key,
    required this.question,
    required this.answer,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = question.options ?? [];
    final selectedId = (answer?.selectedOptionIds ?? []).isNotEmpty
        ? answer!.selectedOptionIds!.first
        : null;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final opt = options[index];
        final isSelected = selectedId == opt.id;

        return GestureDetector(
          onTap: () => onOptionSelected(opt.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF1E60FF)
                    : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1E60FF)
                          : const Color(0xFF9CA3AF),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1E60FF),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (opt.textEn.isNotEmpty)
                        Text(
                          opt.textEn,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF1E3A8A)
                                : AppColors.textPrimary,
                          ),
                        ),
                      if (opt.textEn.isNotEmpty && opt.textTa.isNotEmpty)
                        const SizedBox(height: 2),
                      if (opt.textTa.isNotEmpty)
                        Text(
                          opt.textTa,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF1E3A8A).withValues(alpha: 0.8)
                                : AppColors.textPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MultiChoiceLayout extends StatelessWidget {
  final QuestionModel question;
  final StudentAnswer? answer;
  final Function(String) onOptionToggled;

  const MultiChoiceLayout({
    super.key,
    required this.question,
    required this.answer,
    required this.onOptionToggled,
  });

  @override
  Widget build(BuildContext context) {
    final options = question.options ?? [];
    final selectedIds = answer?.selectedOptionIds ?? [];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final opt = options[index];
        final isSelected = selectedIds.contains(opt.id);

        return GestureDetector(
          onTap: () => onOptionToggled(opt.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF1E60FF)
                    : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1E60FF)
                          : const Color(0xFF9CA3AF),
                      width: 2,
                    ),
                    color: isSelected
                        ? const Color(0xFF1E60FF)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (opt.textEn.isNotEmpty)
                        Text(
                          opt.textEn,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF1E3A8A)
                                : AppColors.textPrimary,
                          ),
                        ),
                      if (opt.textEn.isNotEmpty && opt.textTa.isNotEmpty)
                        const SizedBox(height: 2),
                      if (opt.textTa.isNotEmpty)
                        Text(
                          opt.textTa,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF1E3A8A).withValues(alpha: 0.8)
                                : AppColors.textPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TrueFalseLayout extends StatelessWidget {
  final QuestionModel question;
  final StudentAnswer? answer;
  final Function(bool) onAnswerChanged;

  const TrueFalseLayout({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool? currentSelection = answer?.booleanAnswer;

    return Column(
      children: [
        _buildTFCard(
          context,
          label: 'TRUE',
          isSelected: currentSelection == true,
          activeColor: const Color(0xFF10B981), // Green
          icon: Icons.check_circle_outline,
          onTap: () => onAnswerChanged(true),
        ),
        const SizedBox(height: 16),
        _buildTFCard(
          context,
          label: 'FALSE',
          isSelected: currentSelection == false,
          activeColor: const Color(0xFFEF4444), // Red
          icon: Icons.cancel_outlined,
          onTap: () => onAnswerChanged(false),
        ),
      ],
    );
  }

  Widget _buildTFCard(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Color activeColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : const Color(0xFF9CA3AF),
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? activeColor : AppColors.textPrimary,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FillInBlankLayout extends StatefulWidget {
  final QuestionModel question;
  final StudentAnswer? answer;
  final Function(String) onAnswerChanged;

  const FillInBlankLayout({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswerChanged,
  });

  @override
  State<FillInBlankLayout> createState() => _FillInBlankLayoutState();
}

class _FillInBlankLayoutState extends State<FillInBlankLayout> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.answer?.textAnswer ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant FillInBlankLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the active question is changed, refresh controller text
    if (oldWidget.question.id != widget.question.id) {
      _textController.text = widget.answer?.textAnswer ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Answer',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  onChanged: widget.onAnswerChanged,
                  decoration: const InputDecoration(
                    hintText: 'Type your answer here...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.edit, color: Colors.grey, size: 18),
            ],
          ),
        ),
        if (widget.question.hint != null &&
            widget.question.hint!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Hint: ${widget.question.hint}',
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}

class DescriptiveLayout extends StatefulWidget {
  final QuestionModel question;
  final StudentAnswer? answer;
  final Function(String) onAnswerChanged;
  final Function(String) onAttachmentChanged;

  const DescriptiveLayout({
    super.key,
    required this.question,
    required this.answer,
    required this.onAnswerChanged,
    required this.onAttachmentChanged,
  });

  @override
  State<DescriptiveLayout> createState() => _DescriptiveLayoutState();
}

class _DescriptiveLayoutState extends State<DescriptiveLayout> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.answer?.descriptiveText ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant DescriptiveLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _textController.text = widget.answer?.descriptiveText ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        final fileName = result.files.single.name;
        widget.onAttachmentChanged('/uploads/$fileName');
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordLimit = widget.question.wordLimit ?? 0;
    final currentWordCount = _countWords(_textController.text);
    final isOverLimit = wordLimit > 0 && currentWordCount > wordLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Answer',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            if (wordLimit > 0)
              Text(
                'Limit: $wordLimit words',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOverLimit ? Colors.red : Colors.grey,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _textController,
                onChanged: (text) {
                  widget.onAnswerChanged(text);
                  setState(() {});
                },
                maxLines: 8,
                minLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Type your essay response here...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$currentWordCount words',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isOverLimit ? Colors.red : Colors.grey,
                      ),
                    ),
                    const Icon(Icons.edit, color: Colors.grey, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Or Upload Handwritten Answer Sheet',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.answer?.attachmentUrl != null
                    ? const Color(0xFF10B981)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.answer?.attachmentUrl != null
                      ? Icons.check_circle
                      : Icons.cloud_upload_outlined,
                  color: widget.answer?.attachmentUrl != null
                      ? const Color(0xFF10B981)
                      : const Color(0xFF1E60FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.answer?.attachmentUrl != null
                        ? 'Attached: ${widget.answer!.attachmentUrl!.split('/').last}'
                        : 'Choose PDF, JPEG, or PNG file',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.answer?.attachmentUrl != null
                          ? const Color(0xFF10B981)
                          : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.answer?.attachmentUrl != null)
                  IconButton(
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 18,
                    ),
                    onPressed: () {
                      widget.onAttachmentChanged('');
                      setState(() {});
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------
// NEW RICH QUESTION LAYOUTS
// ----------------------------------------------------

class SharedContextBlock extends StatefulWidget {
  final QuestionModel question;
  const SharedContextBlock({super.key, required this.question});

  @override
  State<SharedContextBlock> createState() => _SharedContextBlockState();
}

class _SharedContextBlockState extends State<SharedContextBlock> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final textEn = widget.question.sharedContextEn ?? '';
    final textTa = widget.question.sharedContextTa ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Toggle
          InkWell(
            onTap: () => setState(() => _isCollapsed = !_isCollapsed),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: Color(0xFF1E60FF),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.question.format ==
                                QuestionFormat.readingComprehension
                            ? 'Reading Passage'
                            : 'Common Instruction / Caselet',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isCollapsed
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    size: 20,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (!_isCollapsed) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (textEn.isNotEmpty)
                      Text(
                        textEn,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    if (textEn.isNotEmpty && textTa.isNotEmpty)
                      const SizedBox(height: 12),
                    if (textTa.isNotEmpty)
                      Text(
                        textTa,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.textPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DiTableWidget extends StatelessWidget {
  final List<List<String>> rows;
  const DiTableWidget({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: const TableBorder(
            horizontalInside: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            verticalInside: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
          children: rows.asMap().entries.map((entry) {
            final idx = entry.key;
            final cells = entry.value;
            final isHeader = idx == 0;

            return TableRow(
              decoration: BoxDecoration(
                color: isHeader ? const Color(0xFFF3F4F6) : Colors.white,
              ),
              children: cells.map((cell) {
                // Heuristic: right-align numbers
                final isNumeric =
                    double.tryParse(cell.replaceAll(RegExp(r'[^\d\.]'), '')) !=
                    null;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    cell.isEmpty ? '—' : cell,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isHeader
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isHeader
                          ? const Color(0xFF374151)
                          : AppColors.textPrimary,
                    ),
                    textAlign: isNumeric ? TextAlign.right : TextAlign.left,
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class QuestionImagesRow extends StatelessWidget {
  final List<QuestionImage> images;
  const QuestionImagesRow({super.key, required this.images});

  void _openZoomModal(BuildContext context, String url, String? caption) {
    showDialog(
      context: context,
      builder: (context) => ZoomableImageModal(url: url, caption: caption),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height:300,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final img = images[index];
          return GestureDetector(
            onTap: () => _openZoomModal(context, img.url, img.caption),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: img.url,
                fit: BoxFit.fill,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFFF3F4F6),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ZoomableImageModal extends StatelessWidget {
  final String url;
  final String? caption;
  const ZoomableImageModal({super.key, required this.url, this.caption});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Zoomable viewer
          InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.white, size: 48),
                      SizedBox(height: 8),
                      Text(
                        'Image unavailable',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // Caption
          if (caption != null && caption!.isNotEmpty)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  caption!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AssertionReasonCard extends StatelessWidget {
  final QuestionModel question;
  const AssertionReasonCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatementBox(
          context,
          label: 'Assertion (A)',
          text: question.assertion ?? '[Not available]',
          color: const Color(0xFFEFF6FF),
          borderColor: const Color(0xFFBFDBFE),
          labelColor: const Color(0xFF1D4ED8),
        ),
        const SizedBox(height: 12),
        _buildStatementBox(
          context,
          label: 'Reason (R)',
          text: question.reason ?? '[Not available]',
          color: const Color(0xFFFAF5FF),
          borderColor: const Color(0xFFE9D5FF),
          labelColor: const Color(0xFF7E22CE),
        ),
        const SizedBox(height: 16),
        const Text(
          'Choose the correct relation from options below:',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatementBox(
    BuildContext context, {
    required String label,
    required String text,
    required Color color,
    required Color borderColor,
    required Color labelColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: labelColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
