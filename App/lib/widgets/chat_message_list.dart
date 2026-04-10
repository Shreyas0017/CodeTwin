import 'package:flutter/material.dart';
import '../models/log_entry.dart';
import '../models/session_status.dart';
import '../utils/formatters.dart';

class ChatMessageList extends StatefulWidget {
  final List<LogEntry> logs;
  
  const ChatMessageList({super.key, required this.logs});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logs.length > oldWidget.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: widget.logs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = widget.logs[index];
        final isUser = entry.message.startsWith('> Task:') || entry.message.startsWith('> Answer:');
        
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: _ChatBubble(entry: entry, isUser: isUser),
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final LogEntry entry;
  final bool isUser;

  const _ChatBubble({required this.entry, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Extract actual message if it's a user command
    String displayMessage = entry.message;
    if (isUser && displayMessage.startsWith('> Task: ')) {
      displayMessage = displayMessage.substring(8);
    } else if (isUser && displayMessage.startsWith('> Answer: ')) {
      displayMessage = displayMessage.substring(10);
    }

    // Determine bubble styling
    Color bgColor = isUser 
      ? colorScheme.primaryContainer
      : colorScheme.surfaceContainerHighest;
    
    Color textColor = isUser
      ? colorScheme.onPrimaryContainer
      : colorScheme.onSurface;

    if (entry.level == AgentLogLevel.error) {
      bgColor = colorScheme.errorContainer;
      textColor = colorScheme.onErrorContainer;
    }

    IconData? leftIcon;
    if (!isUser) {
      if (entry.level == AgentLogLevel.tool) leftIcon = Icons.build_circle_outlined;
      else if (entry.level == AgentLogLevel.error) leftIcon = Icons.error_outline;
      else if (entry.level == AgentLogLevel.info) leftIcon = Icons.info_outline;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser && leftIcon != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(leftIcon, size: 14, color: textColor.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Text(
                    entry.toolName ?? (entry.level == AgentLogLevel.error ? 'Error' : 'Agent'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Text(
              displayMessage,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
