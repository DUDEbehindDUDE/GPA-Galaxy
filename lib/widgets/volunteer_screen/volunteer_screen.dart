import 'package:flutter/material.dart';
import 'package:gpa_galaxy/generics/type_adapters/profile.dart';
import 'package:gpa_galaxy/generics/type_adapters/volunteer.dart';
import 'package:gpa_galaxy/widgets/volunteer_screen/volunteer_item.dart';
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

    if (volunteerItems.isEmpty) {
      return _renderEmptyCard();
    }

    // Map items based on year (int is year)
    Map<int, List<Volunteer>> mappedVolunteerItems = {};
    for (var item in volunteerItems) {
      mappedVolunteerItems[item.date.year] ??= [];
      mappedVolunteerItems[item.date.year]!.add(item);
    }

    List<Widget> children = [];
    mappedVolunteerItems.forEach((year, item) {
      children
          .add(VolunteerItem(profile: widget.profile, items: item, year: year));
    });

    return children;
  }

  List<Widget> _renderEmptyCard() {
    return [
      const Center(
        child: Padding(
          padding: EdgeInsets.only(left: 8.0, right: 24.0, top: 32.0),
          child: Card.outlined(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            color: Color.fromARGB(209, 26, 14, 31),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "It looks like you haven't logged anything yet. Tap '+' below to log a new activity.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
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
