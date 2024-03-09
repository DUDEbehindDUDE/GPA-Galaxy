import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

class AchievementCard extends StatefulWidget {
  const AchievementCard({
    super.key,
    required this.titleCardStyle,
    required this.descCardStyle,
  });

  final TextStyle titleCardStyle;
  final TextStyle descCardStyle;

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard> {
  GlobalKey globalKey = GlobalKey();

  Future<Uint8List> _capturePng() async {
    try {
      final RenderRepaintBoundary boundary = globalKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      // wait a short time for it to draw
      WidgetsBinding.instance.ensureVisualUpdate();
      await Future.delayed(Durations.short1);
      return await _capturePng();
    }
  }

  void _share() async {
    var image = await _capturePng();
    Share.shareXFiles([
      XFile.fromData(
        image,
        mimeType: "image/png",
        name: "achievement",
      )
    ], text: "Check out my awesome achievement! #GPAGalaxy");
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: Card.outlined(
        shape: Border.all(width: 2, color: Colors.white),
        child: Stack(children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/achievement_tile_bg.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Column(
                  children: [
                    Text("Building up the Galaxy",
                        style: widget.titleCardStyle),
                    Text("Log your first grade", style: widget.descCardStyle),
                  ],
                ),
                IconButton(onPressed: _share, icon: const Icon(Icons.share))
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
