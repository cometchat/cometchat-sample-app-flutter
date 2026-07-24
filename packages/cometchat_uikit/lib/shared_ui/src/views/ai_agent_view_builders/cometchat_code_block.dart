import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../cometchat_uikit_shared.dart';

class CometChatAiAssistantCodeBlock extends StatefulWidget {
  const CometChatAiAssistantCodeBlock({
    super.key,
    required this.language,
    required this.codes,
    this.typography,
    this.spacing,
    this.colorPalette,
  });

  final String language;
  final String codes;
  final CometChatTypography? typography;
  final CometChatColorPalette? colorPalette;
  final CometChatSpacing? spacing;

  @override
  State<CometChatAiAssistantCodeBlock> createState() =>
      _CometChatAiAssistantCodeBlockState();
}

class _CometChatAiAssistantCodeBlockState
    extends State<CometChatAiAssistantCodeBlock> {
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.codes.split('\n');
    final lineCount = lines.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language header
        Container(
          decoration: BoxDecoration(
            color: widget.colorPalette?.background4,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.spacing?.radius3 ?? 12),
              topRight: Radius.circular(widget.spacing?.radius3 ?? 12),
            ),
            border: Border(
              left: BorderSide(
                color: widget.colorPalette?.borderDark ?? Colors.transparent,
                width: 1,
              ),
              right: BorderSide(
                color: widget.colorPalette?.borderDark ?? Colors.transparent,
                width: 1,
              ),
              top: BorderSide(
                color: widget.colorPalette?.borderDark ?? Colors.transparent,
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            left: widget.spacing?.padding3 ?? 12,
            right: widget.spacing?.padding3 ?? 12,
            top: widget.spacing?.padding2 ?? 8,
            bottom: widget.spacing?.padding2 ?? 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.language,
                style: TextStyle(
                  color: widget.colorPalette?.textPrimary,
                  fontWeight: widget.typography?.caption1?.medium?.fontWeight,
                  fontSize: widget.typography?.caption1?.medium?.fontSize,
                  fontFamily: widget.typography?.caption1?.medium?.fontFamily,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.codes));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: widget.colorPalette?.background3,
                      content: Text(
                        'Code copied to clipboard',
                        style: TextStyle(
                          color:
                              widget.colorPalette?.textPrimary ?? Colors.white,
                        ),
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.copy_rounded,
                  size: 20,
                  color: widget.colorPalette?.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Scrollable code container with line numbers
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(widget.spacing?.radius3 ?? 12),
              bottomRight: Radius.circular(widget.spacing?.radius3 ?? 12),
            ),
            border: Border.all(
              color: widget.colorPalette?.borderDark ?? Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line Numbers Column
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.spacing?.padding2 ?? 8,
                  vertical: widget.spacing?.padding5 ?? 12,
                ),
                decoration: BoxDecoration(
                  color: widget.colorPalette?.background4,
                  border: Border(
                    right: BorderSide(
                      color: widget.colorPalette?.borderDark ?? Colors.grey,
                      width: 1,
                    ),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(widget.spacing?.radius3 ?? 12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    lineCount,
                    (index) => Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: widget.colorPalette?.textTertiary ?? Colors.grey,
                        fontSize: widget.typography?.body?.regular?.fontSize,
                        fontFamily:
                            widget.typography?.body?.regular?.fontFamily,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Code Column with vertical + horizontal scrolling
              Expanded(
                child: Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.all(widget.spacing?.padding5 ?? 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          lineCount,
                          (index) => Text(
                            lines[index],
                            style: _getSyntaxHighlightStyle(lines[index])
                                .copyWith(
                                  fontSize: widget
                                      .typography
                                      ?.body
                                      ?.regular
                                      ?.fontSize,
                                  fontFamily: widget
                                      .typography
                                      ?.body
                                      ?.regular
                                      ?.fontFamily,
                                  height: 1.5,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _getSyntaxHighlightStyle(String line) {
    if (line.trim().startsWith('//')) {
      return TextStyle(color: widget.colorPalette?.success);
    } else if (line.contains(
      RegExp(r'\b(class|final|const|var|void|int|String|bool)\b'),
    )) {
      return TextStyle(color: widget.colorPalette?.warning);
    } else if (line.contains(RegExp("\".*?\"|'.*?'"))) {
      return TextStyle(color: widget.colorPalette?.info);
    }
    return TextStyle(color: widget.colorPalette?.textPrimary);
  }
}
