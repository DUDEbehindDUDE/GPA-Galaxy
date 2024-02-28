import 'package:flutter/material.dart';
import 'package:gpa_galaxy/widget/info/license.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoIndex extends StatelessWidget {
  InfoIndex({Key? key}) : super(key: key);

  final Uri source = Uri(scheme: "https", host: "github.com", path: "DUDEbehindDUDE/GPA-Galaxy");
  final Uri wiki = Uri(scheme: "https", host: "github.com", path: "DUDEbehindDUDE/GPA-Galaxy/wiki");

  void _launch(Uri uri) async {
    try {
      await launchUrl(uri);
    } catch (e) {
      throw("Could not launch $uri");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Information")),
      body: Column(
        children: [
          ListTile(
            title: const Text("License"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const License())),
          ),
          ListTile(
            title: const Text("Terms of Use"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Open source licenses used"),
            onTap: () => showLicensePage(context: context),
          ),
          ListTile(
            title: const Text("View source code on GitHub"),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launch(source),
          ),
          ListTile(
            title: const Text("View documentation on GitHub"),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launch(wiki),
          ),
        ],
      ),
    );
  }
}
