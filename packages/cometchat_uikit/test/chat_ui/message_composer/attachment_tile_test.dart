import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: Translations.localizationsDelegates,
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  );
}

AttachmentTile _pdfTile(AttachmentTileStatus status) => AttachmentTile(
  fileId: 'f1',
  name: 'report.pdf',
  mimeType: 'application/pdf',
  size: 1024,
  status: status,
);

/// Finds the tray's SVG status badge by its asset path.
Finder _svgBadge(String asset) => find.byWidgetPredicate(
  (w) =>
      w is SvgPicture &&
      (w.bytesLoader is SvgAssetLoader) &&
      (w.bytesLoader as SvgAssetLoader).assetName == asset,
);

const _cardKey = Key('cometchat_attachment_file_card');

BoxBorder? _cardBorder(WidgetTester tester) {
  final container = tester.widget<Container>(find.byKey(_cardKey));
  return (container.decoration as BoxDecoration?)?.border;
}

void main() {
  group('CometChatAttachmentTile — file card states', () {
    testWidgets('done: name + type subtitle, type glyph, no spinner, badge', (
      tester,
    ) async {
      var removed = false;
      await tester.pumpWidget(
        _wrap(
          CometChatAttachmentTile(
            tile: _pdfTile(AttachmentTileStatus.done),
            onCancelOrRemove: () => removed = true,
          ),
        ),
      );

      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget); // pdf.svg badge
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Upload failed'), findsNothing);
      expect(find.text('Tap to retry'), findsNothing);

      // Remove badge is present and live.
      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      expect(removed, isTrue);
    });

    testWidgets('uploading: spinner in icon box, badge still visible', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          CometChatAttachmentTile(
            tile: _pdfTile(AttachmentTileStatus.uploading),
            onCancelOrRemove: () {},
          ),
        ),
      );
      // Indeterminate spinner — pump once, do not settle.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      // Divergence from the reference by design: ✕ stays available mid-upload.
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets(
      'failed: "Tap to retry", error border, card tap retries in place',
      (tester) async {
        var retried = false;
        var errorTapped = false;
        await tester.pumpWidget(
          _wrap(
            CometChatAttachmentTile(
              tile: _pdfTile(AttachmentTileStatus.failed),
              onCancelOrRemove: () {},
              onErrorInteract: () => errorTapped = true,
              onRetry: () => retried = true,
            ),
          ),
        );

        expect(find.text('Tap to retry'), findsOneWidget);
        expect(_svgBadge(kAttachmentRetryIconAsset), findsOneWidget);

        final colors = CometChatThemeHelper.getColorPalette(
          tester.element(find.byKey(_cardKey)),
        );
        final border = _cardBorder(tester);
        expect(border, isNotNull);
        expect((border as Border).top.color, colors.error ?? Colors.red);

        // A failed (network) tile retries in place on tap — retry lives in the
        // tile, not the snackbar.
        await tester.tap(find.byKey(_cardKey));
        expect(retried, isTrue);
        expect(errorTapped, isFalse);
      },
    );

    testWidgets(
      'rejected: "Upload failed", error border, tap surfaces error (not retryable)',
      (tester) async {
        var errorTapped = false;
        await tester.pumpWidget(
          _wrap(
            CometChatAttachmentTile(
              tile: _pdfTile(AttachmentTileStatus.rejected),
              onCancelOrRemove: () {},
              onErrorInteract: () => errorTapped = true,
            ),
          ),
        );

        expect(find.text('Upload failed'), findsOneWidget);
        expect(_svgBadge(kAttachmentErrorIconAsset), findsOneWidget);

        final colors = CometChatThemeHelper.getColorPalette(
          tester.element(find.byKey(_cardKey)),
        );
        expect(
          (_cardBorder(tester) as Border).top.color,
          colors.error ?? Colors.red,
        );

        await tester.tap(find.byKey(_cardKey));
        expect(errorTapped, isTrue);
      },
    );

    testWidgets('badge tap on failed tile removes, does not surface error', (
      tester,
    ) async {
      var removed = false;
      var errorTapped = false;
      await tester.pumpWidget(
        _wrap(
          CometChatAttachmentTile(
            tile: _pdfTile(AttachmentTileStatus.failed),
            onCancelOrRemove: () => removed = true,
            onErrorInteract: () => errorTapped = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(removed, isTrue);
      expect(errorTapped, isFalse);
    });

    testWidgets('long filename renders with ellipsis, no overflow', (
      tester,
    ) async {
      final tile = AttachmentTile(
        fileId: 'f2',
        name: '${'a' * 60}.docx',
        mimeType:
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        size: 2048,
        status: AttachmentTileStatus.done,
      );
      await tester.pumpWidget(
        _wrap(CometChatAttachmentTile(tile: tile, onCancelOrRemove: () {})),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('DOCX'), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget); // word.svg badge
    });

    testWidgets(
      'extension-less file falls back to FILE label + default glyph',
      (tester) async {
        final tile = AttachmentTile(
          fileId: 'f3',
          name: 'README',
          mimeType: 'application/octet-stream',
          size: 10,
          status: AttachmentTileStatus.done,
        );
        await tester.pumpWidget(
          _wrap(CometChatAttachmentTile(tile: tile, onCancelOrRemove: () {})),
        );

        expect(find.text('FILE'), findsOneWidget);
        expect(find.byType(SvgPicture), findsOneWidget); // unknown.svg badge
      },
    );
  });

  group('CometChatAttachmentTile — video duration pill', () {
    testWidgets('shows m:ss when a video tile has a known duration', (
      tester,
    ) async {
      final tile = AttachmentTile(
        fileId: 'v1',
        name: 'clip.mp4',
        mimeType: 'video/mp4',
        size: 4096,
        status: AttachmentTileStatus.done,
        durationMillis: 65 * 1000, // 1:05
      );
      await tester.pumpWidget(
        _wrap(CometChatAttachmentTile(tile: tile, onCancelOrRemove: () {})),
      );
      expect(find.text('1:05'), findsOneWidget);
    });

    testWidgets('no pill when a video tile duration is unknown', (
      tester,
    ) async {
      final tile = AttachmentTile(
        fileId: 'v2',
        name: 'clip.mp4',
        mimeType: 'video/mp4',
        size: 4096,
        status: AttachmentTileStatus.done,
      );
      await tester.pumpWidget(
        _wrap(CometChatAttachmentTile(tile: tile, onCancelOrRemove: () {})),
      );
      expect(find.textContaining(':'), findsNothing);
    });
  });

  group('CometChatAttachmentTile — GIF tag', () {
    testWidgets('gif image tile shows the GIF corner tag', (tester) async {
      final tile = AttachmentTile(
        fileId: 'g1',
        name: 'funny.gif',
        mimeType: 'image/gif',
        size: 2048,
        status: AttachmentTileStatus.done,
      );
      await tester.pumpWidget(
        _wrap(CometChatAttachmentTile(tile: tile, onCancelOrRemove: () {})),
      );
      expect(find.text('GIF'), findsOneWidget);
    });

    testWidgets('non-gif image tile has no GIF tag', (tester) async {
      final tile = AttachmentTile(
        fileId: 'g2',
        name: 'photo.jpg',
        mimeType: 'image/jpeg',
        size: 2048,
        status: AttachmentTileStatus.done,
      );
      await tester.pumpWidget(
        _wrap(CometChatAttachmentTile(tile: tile, onCancelOrRemove: () {})),
      );
      expect(find.text('GIF'), findsNothing);
    });
  });

  group('CometChatAttachmentTile — tray sizing', () {
    testWidgets(
      'media overlay stays within the 64px body under tray constraints',
      (tester) async {
        // Mimic the tray: horizontal list with a taller tight cross axis (78).
        // The failed-state scrim must cover exactly the 64px thumbnail, not the
        // stretched tile box (regression: media tiles read taller than cards).
        final tile = AttachmentTile(
          fileId: 'i1',
          name: 'pic.png',
          mimeType: 'image/png',
          size: 10,
          status: AttachmentTileStatus.failed,
        );
        await tester.pumpWidget(
          _wrap(
            SizedBox(
              height: 78,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  CometChatAttachmentTile(tile: tile, onCancelOrRemove: () {}),
                ],
              ),
            ),
          ),
        );

        final clips = find.byType(ClipRRect).evaluate().toList();
        expect(clips.length, 2); // thumbnail + status overlay
        for (final e in clips) {
          expect(
            e.size!.height,
            64,
            reason: 'body and overlay must both be exactly 64px tall',
          );
        }
      },
    );
  });

  group('CometChatAttachmentTile — audio player card states', () {
    // thumbUrl deliberately null: no VideoPlayerController is created, so the
    // card renders its inert-player UI (zeroed slider + placeholder clock).
    AttachmentTile audioTile(AttachmentTileStatus status) => AttachmentTile(
      fileId: 'a1',
      name: 'Watch by Billie.mp3',
      mimeType: 'audio/mpeg',
      size: 4096,
      status: status,
    );

    const audioKey = Key('cometchat_attachment_audio_card');

    testWidgets('done: name, play circle, slider and clock; badge live', (
      tester,
    ) async {
      var removed = false;
      await tester.pumpWidget(
        _wrap(
          CometChatAttachmentTile(
            tile: audioTile(AttachmentTileStatus.done),
            onCancelOrRemove: () => removed = true,
          ),
        ),
      );

      expect(find.text('Watch by Billie.mp3'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('00:00/--:--'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Upload failed'), findsNothing);
      expect(find.text('Tap to retry'), findsNothing);

      await tester.tap(find.byIcon(Icons.close));
      expect(removed, isTrue);
    });

    testWidgets('uploading: spinner in play circle, slider + clock stay', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          CometChatAttachmentTile(
            tile: audioTile(AttachmentTileStatus.uploading),
            onCancelOrRemove: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('00:00/--:--'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets(
      'failed: "Tap to retry" replaces player row; card tap retries in place',
      (tester) async {
        var retried = false;
        var errorTapped = false;
        await tester.pumpWidget(
          _wrap(
            CometChatAttachmentTile(
              tile: audioTile(AttachmentTileStatus.failed),
              onCancelOrRemove: () {},
              onErrorInteract: () => errorTapped = true,
              onRetry: () => retried = true,
            ),
          ),
        );

        expect(find.text('Tap to retry'), findsOneWidget);
        expect(_svgBadge(kAttachmentRetryIconAsset), findsOneWidget);
        expect(find.byType(Slider), findsNothing);

        final colors = CometChatThemeHelper.getColorPalette(
          tester.element(find.byKey(audioKey)),
        );
        final container = tester.widget<Container>(find.byKey(audioKey));
        final border = (container.decoration as BoxDecoration).border as Border;
        expect(border.top.color, colors.error ?? Colors.red);

        await tester.tap(find.byKey(audioKey));
        expect(retried, isTrue);
        expect(errorTapped, isFalse);
      },
    );

    testWidgets(
      'rejected: "Upload failed", error border, tap surfaces error (not retryable)',
      (tester) async {
        var errorTapped = false;
        await tester.pumpWidget(
          _wrap(
            CometChatAttachmentTile(
              tile: audioTile(AttachmentTileStatus.rejected),
              onCancelOrRemove: () {},
              onErrorInteract: () => errorTapped = true,
            ),
          ),
        );

        expect(find.text('Upload failed'), findsOneWidget);
        expect(_svgBadge(kAttachmentErrorIconAsset), findsOneWidget);
        expect(find.byType(Slider), findsNothing);

        await tester.tap(find.byKey(audioKey));
        expect(errorTapped, isTrue);
      },
    );
  });

  group('FileTypeStyle', () {
    test('maps known extensions (case-insensitive) and falls back', () {
      expect(
        FileTypeStyle.of(fileName: 'Report.PDF').icon,
        Icons.picture_as_pdf,
      );
      expect(FileTypeStyle.of(fileName: 'sheet.xlsx').icon, Icons.table_chart);
      expect(FileTypeStyle.of(fileName: 'deck.ppt').icon, Icons.slideshow);
      expect(FileTypeStyle.of(fileName: 'a.zip').icon, Icons.folder_zip);
      expect(
        FileTypeStyle.of(fileName: 'x.unknown').icon,
        Icons.insert_drive_file,
      );
      expect(
        FileTypeStyle.of(fileName: 'noext', mimeType: 'audio/mpeg').icon,
        Icons.audiotrack,
      );
    });

    test('extOf: last dot segment, lower-cased, empty when absent', () {
      expect(FileTypeStyle.extOf('a.b.TAR'), 'tar');
      expect(FileTypeStyle.extOf('README'), '');
    });
  });

  group('attachmentSvgAsset', () {
    test(
      'maps extensions to the right badge, with mime + unknown fallback',
      () {
        expect(
          attachmentSvgAsset(fileName: 'Report.PDF'),
          endsWith('attachments/pdf.svg'),
        );
        expect(
          attachmentSvgAsset(fileName: 'a.docx'),
          endsWith('attachments/word.svg'),
        );
        expect(
          attachmentSvgAsset(fileName: 'a.xlsx'),
          endsWith('attachments/xlsx.svg'),
        );
        expect(
          attachmentSvgAsset(fileName: 'a.pptx'),
          endsWith('attachments/ppt.svg'),
        );
        expect(
          attachmentSvgAsset(fileName: 'a.zip'),
          endsWith('attachments/zip.svg'),
        );
        expect(
          attachmentSvgAsset(fileName: 'photo.png'),
          endsWith('attachments/jpg.svg'),
        );
        expect(
          attachmentSvgAsset(fileName: 'clip.mov'),
          endsWith('attachments/mov.svg'),
        );
        expect(
          attachmentSvgAsset(fileName: 'song.m4a'),
          endsWith('attachments/mp3.svg'),
        );
        // Unknown extension → mime fallback → unknown.
        expect(
          attachmentSvgAsset(fileName: 'x.bin', mimeType: 'image/heic'),
          endsWith('attachments/jpg.svg'),
        );
        expect(
          attachmentSvgAsset(fileName: 'noext'),
          endsWith('attachments/unknown.svg'),
        );
      },
    );
  });
}
