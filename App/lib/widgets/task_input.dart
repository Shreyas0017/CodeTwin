/// Modern multi-line task text input mimicking an AI chat bar.

import 'package:flutter/material.dart';

class TaskInput extends StatefulWidget {
  final void Function(String task) onSubmit;
  final bool enabled;

  const TaskInput({super.key, required this.onSubmit, this.enabled = true});

  @override
  State<TaskInput> createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _focusNode.addListener(() {
      setState(() {}); // Trigger rebuild for focus styling
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF20B2AA);
    final isFocused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF16161A), // Deep sleek background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFocused
              ? primaryColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          if (isFocused)
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'Ask CodeTwin to do something...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
                isDense: true,
              ),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.none, // Allow multiline typing
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: _hasText ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, val, child) {
                return Opacity(
                  opacity: val,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * val),
                    child: IconButton(
                      onPressed: widget.enabled && _hasText ? _submit : null,
                      style: IconButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                      ),
                      icon: const Icon(Icons.arrow_upward, size: 20),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
