import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

class AchievementDialog extends StatelessWidget {
  final String name;
  final String desc;
  final bool upgradable;
  final int? levelCap;
  final int level;

  final TextStyle titleCardStyle = const TextStyle();
  final TextStyle descCardStyle = const TextStyle(fontStyle: FontStyle.italic);
  final GlobalKey globalKey = GlobalKey();
  

  AchievementDialog({
    super.key,
    required this.name,
    required this.desc,
    required this.upgradable,
    this.levelCap,
    this.level = 0,
  });

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
    var width = MediaQuery.of(context).size.width - 16;

    return Dialog.fullscreen(
      backgroundColor: Colors.black.withOpacity(0.6),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton.filled(
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.black)),
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, "close"),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RepaintBoundary(
                key: globalKey,
                child: SizedBox(
                  height: width / 1.8,
                  width: width,
                  child: Card.outlined(
                    shape: Border.all(
                      width: 3,
                      color: Colors.grey.shade400,
                    ),
                    child: Stack(
                      children: [
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                Row(
                                  children: [
                                    const Spacer(),
                                    SizedBox(
                                      width: 48,
                                      height: 40,
                                      child: Image.asset(
                                        "assets/images/logo_transparent.png",
                                        filterQuality: FilterQuality.none,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      _share();
                    },
                    icon: const Icon(Icons.share),
                    label: const Text("Share to Social Media"),
                  ),
                ],
              )
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
