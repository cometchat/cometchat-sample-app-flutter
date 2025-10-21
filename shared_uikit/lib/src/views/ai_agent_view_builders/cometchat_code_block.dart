import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../cometchat_uikit_shared.dart';

class CometChatAiAssistantCodeBlock extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final lines = codes.split('\n');
    final lineCount = lines.length - 1;

    final verticalController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language header
        Container(
          decoration: BoxDecoration(
            color: colorPalette?.background4,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(spacing?.radius3 ?? 12),
              topRight: Radius.circular(spacing?.radius3 ?? 12),
            ),
            border: Border(
              left: BorderSide(
                color: colorPalette?.borderDark ?? Colors.transparent,
                width: 1,
              ),
              right: BorderSide(
                color: colorPalette?.borderDark ?? Colors.transparent,
                width: 1,
              ),
              top: BorderSide(
                color: colorPalette?.borderDark ?? Colors.transparent,
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            left: spacing?.padding3 ?? 12,
            right: spacing?.padding3 ?? 12,
            top: spacing?.padding2 ?? 8,
            bottom: spacing?.padding2 ?? 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                language,
                style: TextStyle(
                  color: colorPalette?.textPrimary,
                  fontWeight: typography?.caption1?.medium?.fontWeight,
                  fontSize: typography?.caption1?.medium?.fontSize,
                  fontFamily: typography?.caption1?.medium?.fontFamily,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: codes));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        backgroundColor: colorPalette?.background3,
                        content: Text(
                          'Code copied to clipboard',
                          style: TextStyle(
                            color: colorPalette?.textPrimary ?? Colors.white,
                          ),
                        )),
                  );
                },
                child: Icon(
                  Icons.copy_rounded,
                  size: 20,
                  color: colorPalette?.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Scrollable code container with line numbers
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(spacing?.radius3 ?? 12),
              bottomRight: Radius.circular(spacing?.radius3 ?? 12),
            ),
            border: Border.all(
              color: colorPalette?.borderDark ?? Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line Numbers Column
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing?.padding2 ?? 8,
                  vertical: spacing?.padding5 ?? 12,
                ),
                decoration: BoxDecoration(
                  color: colorPalette?.background4,
                  border: Border(
                    right: BorderSide(
                      color: colorPalette?.borderDark ?? Colors.grey,
                      width: 1,
                    ),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(spacing?.radius3 ?? 12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    lineCount,
                    (index) => Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: colorPalette?.textTertiary ?? Colors.grey,
                        fontSize: typography?.body?.regular?.fontSize,
                        fontFamily: typography?.body?.regular?.fontFamily,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Code Column with vertical + horizontal scrolling
              Expanded(
                child: Scrollbar(
                  controller: verticalController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: verticalController,
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.all(spacing?.padding5 ?? 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          lineCount,
                          (index) => Text(
                            lines[index],
                            style: _getSyntaxHighlightStyle(
                              lines[index],
                              typography,
                              colorPalette,
                              spacing,
                            ).copyWith(
                              fontSize: typography?.body?.regular?.fontSize,
                              fontFamily: typography?.body?.regular?.fontFamily,
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

  TextStyle _getSyntaxHighlightStyle(
    String line,
    CometChatTypography? typography,
    CometChatColorPalette? colorPalette,
    CometChatSpacing? spacing,
  ) {
    if (line.trim().startsWith('//')) {
      return TextStyle(color: colorPalette?.success);
    } else if (line.contains(
        RegExp(r'\b(class|final|const|var|void|int|String|bool)\b'))) {
      return TextStyle(color: colorPalette?.warning);
    } else if (line.contains(RegExp("\".*?\"|'.*?'"))) {
      return TextStyle(color: colorPalette?.info);
    }
    return TextStyle(color: colorPalette?.textPrimary);
  }
}
