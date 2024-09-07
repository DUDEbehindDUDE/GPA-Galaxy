import 'package:flutter/material.dart';
import 'package:gpa_galaxy/class/util.dart';
import 'package:gpa_galaxy/generics/type_adapters/volunteer.dart';
import 'package:gpa_galaxy/widgets/volunteer_screen/edit_volunteer_dialog.dart';

class VolunteerItem extends StatelessWidget {
  final String profile;
  final List<Volunteer> items;
  final int year;

  const VolunteerItem({
    super.key,
    required this.profile,
    required this.items,
    required this.year,
  });

  List<Widget> _renderItems(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    var style = const TextStyle(fontSize: 18.0);
    var descStyle = const TextStyle(color: Colors.grey);

    List<Widget> items = [
      const Padding(padding: EdgeInsets.only(top: 8.0)),
      Row(
        children: [
          SizedBox(
            width: 66,
            child: Text("Date", style: descStyle),
          ),
          Text("Name", style: descStyle),
          const Spacer(),
          Text("Hours logged", style: descStyle),
        ],
      ),
      const Divider(height: 8.0),
    ];

    for (var volunteerItem in this.items) {
      items.add(Row(
        children: [
          SizedBox(
            width: 66,
            child: Text(
              Util.renderDateMD(volunteerItem.date),
              style: style,
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth - 150),
            child: Text(
              volunteerItem.name,
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Text(volunteerItem.hours.toString(), style: style),
        ],
      ));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            year.toString(),
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 26,
            ),
          ),
          ..._renderItems(context),
          TextButton.icon(
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (context) => EditDialog(
                        profile: profile,
                        items: items,
                        year: year,
                      ));
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text("Edit entries"),
            style: const ButtonStyle(
              padding: WidgetStatePropertyAll(
                  EdgeInsets.only(left: 2.0, right: 8.0)),
              iconSize: WidgetStatePropertyAll(20),
              textStyle: WidgetStatePropertyAll(
                  TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 24.0)),
        ],
      ),
    );
  }
}
