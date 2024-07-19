import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class EditData extends StatefulWidget {
  final String? nik;
  final String? nama;
  final String? umur;
  final String? alamat;
  final String? nohp;
  final String? pinjam;
  final String? tempo;
  final String? photoUrl;

  EditData(
      {this.nik,
      this.nama,
      this.umur,
      this.alamat,
      this.nohp,
      this.pinjam,
      this.tempo,
      this.photoUrl});

  @override
  _EditDataState createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {
  TextEditingController nikController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController umurController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController nohpController = TextEditingController();
  String? selectedPinjam;
  String? selectedTempo;

  void editData() {
    int pinjamAmount = int.parse(selectedPinjam ?? '0');
    int tempoYears = int.parse(selectedTempo ?? '0');

    // Mapping pinjam amount to total amount
    int totalAmount = 0;
    switch (pinjamAmount) {
      case 1500000:
        totalAmount = 1800000;
        break;
      case 3000000:
        totalAmount = 3500000;
        break;
      case 5000000:
        totalAmount = 5600000;
        break;
      case 10000000:
        totalAmount = 11000000;
        break;
      default:
        totalAmount = pinjamAmount;
    }

    // Mapping tempo in years to months
    int tempoMonths = 0;
    switch (tempoYears) {
      case 1:
        tempoMonths = 12;
        break;
      case 2:
        tempoMonths = 24;
        break;
      case 3:
        tempoMonths = 36;
        break;
      case 4:
        tempoMonths = 48;
        break;
      case 5:
        tempoMonths = 60;
        break;
      default:
        tempoMonths = tempoYears * 12;
    }

    // Calculate angsuran
    int angsuran = totalAmount ~/ tempoMonths;

    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('nasabah').doc(widget.nik);

    Map<String, dynamic> nsb = {
      "nik": widget.nik,
      "nama": namaController.text,
      "umur": umurController.text,
      "alamat": alamatController.text,
      "nohp": nohpController.text,
      "pinjam": selectedPinjam,
      "tempo": selectedTempo,
      "angsuran": angsuran.toString(),
      "photoUrl": widget.photoUrl
    };

    // Update data to Firebase
    documentReference
        .update(nsb)
        .whenComplete(() => print('${widget.nik} updated'));
  }

  void deleteData() async {
    DocumentReference nasabahRef =
        FirebaseFirestore.instance.collection('nasabah').doc(widget.nik);
    DocumentReference bayarRef =
        FirebaseFirestore.instance.collection('bayar').doc(widget.nik);

    // Delete data from Firebase
    await nasabahRef
        .delete()
        .whenComplete(() => print('${widget.nik} deleted from nasabah'));
    await bayarRef
        .delete()
        .whenComplete(() => print('${widget.nik} deleted from bayar'));
  }

  void konfirmasi() {
    AlertDialog alertDialog = AlertDialog(
      content: Text("Apakah anda yakin akan menghapus data '${widget.nama}'?"),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text(
            "OK DELETE!",
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            deleteData();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Home()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: Text(
            "CANCEL",
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    nikController = TextEditingController(text: widget.nik);
    namaController = TextEditingController(text: widget.nama);
    umurController = TextEditingController(text: widget.umur);
    alamatController = TextEditingController(text: widget.alamat);
    nohpController = TextEditingController(text: widget.nohp);
    selectedPinjam = widget.pinjam;
    selectedTempo = widget.tempo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EDIT DATA"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Text(
              "Ubah Data Nasabah",
              style: TextStyle(
                color: Colors.red,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(height: 40),
            TextFormField(
              controller: nikController,
              decoration: InputDecoration(
                labelText: "NIK",
              ),
              readOnly: true,
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
              value: selectedPinjam,
              onChanged: (String? value) {
                setState(() {
                  selectedPinjam = value;
                });
              },
              items: ['1500000', '3000000', '5000000', '10000000']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: "Pinjam"),
            ),
            DropdownButtonFormField<String>(
              value: selectedTempo,
              onChanged: (String? value) {
                setState(() {
                  selectedTempo = value;
                });
              },
              items: ['1', '2', '3', '4', '5']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: "Tempo Tahun"),
            ),
            SizedBox(height: 20),
            widget.photoUrl != null
                ? Image.network(
                    widget.photoUrl!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  )
                : Container(),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    editData();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text("Ubah"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    konfirmasi();
                  },
                  child: Text("Hapus"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
