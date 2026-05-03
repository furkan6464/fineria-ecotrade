import 'package:flutter/material.dart';
import 'package:mobile/features/ai/presentation/ai_theme.dart';

class AiMessageInputBar extends StatefulWidget {
  const AiMessageInputBar({
    super.key,
    required this.hint,
    required this.onSend,
  });

  final String hint;
  final ValueChanged<String> onSend;

  @override
  State<AiMessageInputBar> createState() => _AiMessageInputBarState();
}

class _AiMessageInputBarState extends State<AiMessageInputBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _controller.text;
    widget.onSend(t);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: AiTheme.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AiTheme.inputBorder, width: 0.5),
        ),
        padding: const EdgeInsets.only(left: 16, right: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AiTheme.sectionTitle,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AiTheme.hintGray,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            Material(
              color: AiTheme.greenBorder,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _submit,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: AiTheme.white,
                    size: 22,
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
