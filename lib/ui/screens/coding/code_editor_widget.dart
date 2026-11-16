import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class CodeEditorWidget extends StatefulWidget {
  final String initialCode;
  final String language;
  final double fontSize;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback onPasteAttempted;

  const CodeEditorWidget({
    super.key,
    required this.initialCode,
    required this.language,
    this.fontSize = 13.0,
    required this.onCodeChanged,
    required this.onPasteAttempted,
  });

  @override
  State<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends State<CodeEditorWidget> {
  late TextEditingController _controller;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _lineScrollController = ScrollController();
  int _lineCount = 1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
    _lineCount = _calculateLineCount(widget.initialCode);
  }

  @override
  void didUpdateWidget(covariant CodeEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCode != widget.initialCode && _controller.text != widget.initialCode) {
      _controller.text = widget.initialCode;
      _lineCount = _calculateLineCount(widget.initialCode);
    }
  }

  int _calculateLineCount(String text) {
    if (text.isEmpty) return 1;
    return '\n'.allMatches(text).length + 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _lineScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monoStyle = GoogleFonts.jetBrainsMono(
      fontSize: widget.fontSize,
      color: AppColors.textCode,
      height: 1.5,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.editorBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line numbers column
            Container(
              width: 42,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: AppColors.editorGutter,
              child: ListView.builder(
                controller: _lineScrollController,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _lineCount < 1 ? 1 : _lineCount,
                itemBuilder: (context, index) {
                  return Text(
                    '${index + 1}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: widget.fontSize - 1,
                      color: AppColors.editorLineNumber,
                      height: 1.5,
                    ),
                  );
                },
              ),
            ),

            // Vertical divider
            Container(width: 1, color: AppColors.surfaceBorder),

            // Code Input field with Paste Interception
            Expanded(
              child: CallbackShortcuts(
                bindings: <ShortcutActivator, VoidCallback>{
                  // Intercept Ctrl+V and Shift+Insert on desktop/keyboard
                  const SingleActivator(LogicalKeyboardKey.keyV, control: true): () {
                    widget.onPasteAttempted();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pasting is disabled. Type your code manually to unlock screen time!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                  const SingleActivator(LogicalKeyboardKey.insert, shift: true): () {
                    widget.onPasteAttempted();
                  },
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: TextField(
                    controller: _controller,
                    scrollController: _scrollController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: monoStyle,
                    cursorColor: AppColors.secondary,
                    enableInteractiveSelection: true,
                    // Custom context menu with NO paste option
                    contextMenuBuilder: (context, editableTextState) {
                      final items = editableTextState.contextMenuButtonItems;
                      // Remove paste from context menu items
                      items.removeWhere((item) => item.type == ContextMenuButtonType.paste);
                      return AdaptiveTextSelectionToolbar.buttonItems(
                        anchors: editableTextState.contextMenuAnchors,
                        buttonItems: items,
                      );
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                    ),
                    onChanged: (text) {
                      setState(() {
                        _lineCount = _calculateLineCount(text);
                      });
                      widget.onCodeChanged(text);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
