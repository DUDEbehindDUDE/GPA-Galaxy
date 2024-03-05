import 'package:flutter/material.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/generics/type_adapters/volunteer.dart';
import 'package:gpa_galaxy/widget/volunteer_screen/volunteer_item.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VolunteerScreen extends StatefulWidget {
  final String profile;

  const VolunteerScreen({super.key, required this.profile});

  @override
  createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  var profileBox = Hive.box<Profile>("profiles");

  List<Widget> _renderChildren() {
    var volunteerItems = profileBox.get(widget.profile)!.volunteering;
    volunteerItems.sort((a, b) => a.date.compareTo(b.date));

    // Map items based on year (int is year)
    Map<int, List<Volunteer>> mappedVolunteerItems = {};
    for (var item in volunteerItems) {
      mappedVolunteerItems[item.date.year] ??= [];
      mappedVolunteerItems[item.date.year]!.add(item);
    }

    List<Widget> children = [];
    mappedVolunteerItems.forEach((key, value) {
      children.add(VolunteerItem(profile: widget.profile, items: value, year: key));
    });

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Column(
        children: _renderChildren(),
      ),
    );
  }
}
