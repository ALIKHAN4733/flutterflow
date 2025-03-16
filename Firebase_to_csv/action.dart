import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html; // Import HTML package for Web
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';

Future downloadcsv() async {
  // Add your function code here!
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('data').get();

    if (querySnapshot.docs.isEmpty) {
      print('No user data available to export.');
      return;
    }

    List<List<dynamic>> csvData = [
      ["country", "firstname"]
    ];

    for (var doc in querySnapshot.docs) {
      var user = doc.data() as Map<String, dynamic>;

      csvData.add([
        user['country'] ?? "N/A",
        user['firstname'] ?? "N/A",
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    Uint8List csvBytes = Uint8List.fromList(utf8.encode(csv));

    // Convert bytes to Blob and trigger file download
    final blob = html.Blob([csvBytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "users_data.csv")
      ..click();

    html.Url.revokeObjectUrl(url);

    print('CSV file downloaded successfully!');
  } catch (e) {
    print('Error saving CSV: $e');
  }
}
