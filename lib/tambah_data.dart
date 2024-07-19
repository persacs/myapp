import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'home.dart';

class TambahData extends StatefulWidget {
  @override
  _TambahDataState createState() => _TambahDataState();
}

class _TambahDataState extends State<TambahData> {
  TextEditingController nikController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController umurController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController nohpController = TextEditingController();
  String? pinjamValue = '1500000';
  String? tempoValue = '1';
  String? angsuran;
  XFile? _imageFile;

  @override
  Widget build(BuildContext context) {
    // Function to calculate installment based on pinjam and tempo
    void calculateAngsuran() {
      int pinjam = int.parse(pinjamValue!);
      int tempo = int.parse(tempoValue!);

      // Perform calculations based on your requirements
      int hasilPinjam;
      int hasilTempo;

      if (pinjam == 1500000) {
        hasilPinjam = 1800000;
      } else if (pinjam == 3000000) {
        hasilPinjam = 3500000;
      } else if (pinjam == 5000000) {
        hasilPinjam = 5600000;
      } else if (pinjam == 10000000) {
        hasilPinjam = 11000000;
      } else {
        hasilPinjam = 0;
      }

      if (tempo == 1) {
        hasilTempo = 12;
      } else if (tempo == 2) {
        hasilTempo = 24;
      } else if (tempo == 3) {
        hasilTempo = 36;
      } else if (tempo == 4) {
        hasilTempo = 48;
      } else if (tempo == 5) {
        hasilTempo = 60;
      } else {
        hasilTempo = 0;
      }

      int hasilAngsuran = hasilPinjam ~/ hasilTempo;

      setState(() {
        angsuran = hasilAngsuran.toString();
      });
    }

    Future<void> _pickImage(ImageSource source) async {
      XFile? pickedFile = await ImagePicker().pickImage(source: source);
      setState(() {
        _imageFile = pickedFile;
      });
    }

    Future<String> _uploadImageToFirebaseStorage(File imageFile) async {
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        firebase_storage.Reference storageReference = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(fileName);

        await storageReference.putFile(File(_imageFile!.path));
        String imageUrl = await storageReference.getDownloadURL();
        return imageUrl;
      } catch (e) {
        print('Error uploading image to Firebase Storage: $e');
        return '';
      }
    }

    void _showNikExistsPopup() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("NIK nasabah sudah tersedia"),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> addData() async {
      String imageUrl =
          await _uploadImageToFirebaseStorage(File(_imageFile!.path));

      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('nasabah')
          .doc(nikController.text);

      Map<String, dynamic> nsb = {
        "nik": nikController.text,
        "nama": namaController.text,
        "umur": umurController.text,
        "alamat": alamatController.text,
        "nohp": nohpController.text,
        "pinjam": pinjamValue,
        "tempo": tempoValue,
        "angsuran": angsuran,
        "photoUrl": imageUrl,
      };

      documentReference
          .set(nsb)
          .then((value) => print('${nikController.text} created'))
          .catchError((error) => print('Failed to add data: $error'));
    }

    Future<void> _checkAndAddData() async {
      String nik = nikController.text;

      // Check if NIK already exists
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('nasabah')
          .where('nik', isEqualTo: nik)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Show a popup if NIK already exists
        _showNikExistsPopup();
      } else {
        // Proceed with adding data
        await addData(); // Make sure to await the addData call
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("ADD DATA"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Text(
              "Input Data Nasabah",
              style: TextStyle(
                color: Colors.red,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            TextFormField(
              controller: nikController,
              decoration: InputDecoration(
                labelText: "NIK",
              ),
            ),
            TextFormField(
              controller: namaController,
              decoration: InputDecoration(labelText: "Nama"),
            ),
            TextFormField(
              controller: umurController,
              decoration: InputDecoration(labelText: "Umur"),
            ),
            TextFormField(
              controller: alamatController,
              decoration: InputDecoration(labelText: "Alamat"),
            ),
            TextFormField(
              controller: nohpController,
              decoration: InputDecoration(labelText: "No HP"),
            ),
            DropdownButtonFormField<String>(
              value: pinjamValue,
              onChanged: (String? newValue) {
                setState(() {
                  pinjamValue = newValue;
                  calculateAngsuran(); // Recalculate installment when pinjam changes
                });
              },
              decoration: InputDecoration(labelText: "Pinjam"),
              items: <String>['1500000', '3000000', '5000000', '10000000']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButtonFormField<String>(
              value: tempoValue,
              onChanged: (String? newValue) {
                setState(() {
                  tempoValue = newValue;
                  calculateAngsuran();
                });
              },
              decoration: InputDecoration(labelText: "Tempo Tahun"),
              items: <String>['1', '2', '3', '4', '5']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.photo_library),
                  onPressed: () {
                    _pickImage(ImageSource.gallery);
                  },
                  tooltip: 'Pick Image from gallery',
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () {
                    _pickImage(ImageSource.camera);
                  },
                  tooltip: 'Take a photo',
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                _pickImage(ImageSource.gallery);
              },
              child: Container(
                color: Colors.grey[200],
                height: 150,
                child: _imageFile == null
                    ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                    : Image.file(File(_imageFile!.path)),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                calculateAngsuran();
                _checkAndAddData(); // Check and add data to Firestore
              },
              child: Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
