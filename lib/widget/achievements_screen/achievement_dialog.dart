import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gpa_galaxy/class/util.dart';
import 'package:share_plus/share_plus.dart';

class AchievementDialog extends StatelessWidget {
  final String name;
  final String desc;
  final bool upgradable;
  final int? levelCap;
  final int level;
  final DateTime? dateEarned;

  final GlobalKey globalKey = GlobalKey();

  AchievementDialog({
    super.key,
    required this.name,
    required this.desc,
    required this.upgradable,
    this.levelCap,
    this.level = 0,
    this.dateEarned,
  });

  TextStyle _getTextStyle(String item, BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    TextStyle titleCardStyle = TextStyle(
      fontSize: Util.dynamicUnit(18, width),
      fontWeight: FontWeight.w700,
    );
    TextStyle descCardStyle = TextStyle(
      fontSize: Util.dynamicUnit(13.5, width),
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w500,
    );
    final TextStyle descriptorCardStyle = TextStyle(
      fontSize: Util.dynamicUnit(10.5, width),
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade400,
    );
    final TextStyle descriptorCardStyleItalic = TextStyle(
      fontSize: Util.dynamicUnit(10.5, width),
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade400,
    );

    return switch (item) {
      "title" => titleCardStyle,
      "descriptor" => descriptorCardStyle,
      "descriptorItalic" => descriptorCardStyleItalic,
      "desc" => descCardStyle,
      _ => throw ("Item not valid"),
    };
  }

  Widget _levelText(BuildContext context) {
    if (!upgradable || level == 0) {
      return const SizedBox(); // Empty widget
    }
    String levelText = level == levelCap ? "Max level!" : "Level $level";
    return Text(
      levelText,
      style: _getTextStyle("descriptorItalic", context),
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
          child: Stack(
            children: [
              Positioned.fill(
                  child: GestureDetector(
                onTap: () => Navigator.pop(context, "close"),
              )),
              Column(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _levelText(context),
                                          Text(
                                            name,
                                            style: _getTextStyle("title", context),
                                          ),
                                          Text(
                                            desc,
                                            style: _getTextStyle("desc", context),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (dateEarned != null)
                                          Text(
                                            "Earned ${Util.renderDateMDYyyy(dateEarned!)}",
                                            style: _getTextStyle("descriptor", context),
                                          ),
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
                        label: const Text("Share on social media"),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
