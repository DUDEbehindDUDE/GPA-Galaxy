import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gpa_galaxy/generics/type_adapters/earned_achievement.dart';
import 'package:share_plus/share_plus.dart';

class AchievementCard extends StatelessWidget {
  final String name;
  final String desc;
  final bool upgradable;
  final int? levelCap;
  final int level;

  final TextStyle titleCardStyle = const TextStyle();
  final TextStyle descCardStyle = const TextStyle(fontStyle: FontStyle.italic);
  final GlobalKey globalKey = GlobalKey();

  AchievementCard({
    super.key,
    required this.name,
    required this.desc,
    required this.upgradable,
    this.levelCap,
    this.level = 0,
  });

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

  Widget _levelText() {
    if (!upgradable || level == 0) {
      return const SizedBox(); // Empty widget
    }
    String levelText = level == levelCap ? "Max level!" : "Level $level";
    return Text(
      levelText,
      style: const TextStyle(
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: Card.outlined(
        shape: Border.all(
            width: 2, color: level == 0 ? Colors.grey.shade800 : Colors.white),
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
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _levelText(),
                        Text(
                          name,
                          style: titleCardStyle,
                        ),
                        Text(
                          desc,
                          style: descCardStyle,
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: _share, icon: const Icon(Icons.share))
                ],
              ),
            ),
          ),
          if (level == 0)
            Positioned.fill(
              child: Container(
                color: const Color.fromARGB(180, 36, 36, 36),
              ),
            ),
        ]),
      ),
    );
  }
}
