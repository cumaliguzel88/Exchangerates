import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final String _apiKey = "04ffb4cc92524d2593239f73adaab981";

  final String _baseUrl =
      "http://api.exchangeratesapi.io/v1/latest?access_key=";

  Map<String, double> _oranlar = {};

  String _secilenKur = "USD";
  double _sonuc = 0;
  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verileriInternettenCek();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text(
          "Exchangerates",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _builtKurDonusturucuRow(),
            SizedBox(height: 16),
            Text(
              "${_sonuc.toStringAsFixed(2)} ₺",
              style: TextStyle(fontSize: 35),
            ),
            SizedBox(height: 10),
            Container(
              height: 2,
              color: Colors.black,
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _oranlar.keys.length,
                itemBuilder: _buildListItem,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _builtKurDonusturucuRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (String yeniDeger) {
              _hesapla();
            },
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.money)),
          ),
        ),
        SizedBox(width: 25),
        DropdownButton<String>(
          underline: SizedBox(),
          icon: Icon(Icons.arrow_circle_down_sharp),
          value: _secilenKur,
          items: _oranlar.keys.map((String kur) {
            return DropdownMenuItem<String>(
              value: kur,
              child: Text(kur),
            );
          }).toList(),
          onChanged: (String? yeniDeger) {
            if (yeniDeger != null) {
              _secilenKur = yeniDeger;
              _hesapla();
            }
          },
        ),
      ],
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return Card(
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: ListTile(
        title: Text(_oranlar.keys.toList()[index]),
        trailing: Text(
          _oranlar.values.toList()[index].toStringAsFixed(2),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _hesapla() {
    double? deger = double.tryParse(_controller.text);
    double? oran = _oranlar[_secilenKur];
    if (deger != null && oran != null) {
      setState(() {
        _sonuc = deger * oran;
      });
    }
  }

  void _verileriInternettenCek() async {
    Uri uri = Uri.parse(_baseUrl + _apiKey);
    http.Response response = await http.get(uri);

    Map<String, dynamic> parsedResponse = jsonDecode(response.body);

    Map<String, dynamic> rates = parsedResponse["rates"];

    double? baseTlKuru = rates["TRY"];

    if (baseTlKuru != null) {
      for (String ulkeKuru in rates.keys) {
        double? baseKur = double.tryParse(rates[ulkeKuru].toString());
        if (baseKur != null) {
          double tlKuru = baseTlKuru / baseKur;
          _oranlar[ulkeKuru] = tlKuru;
        }
      }
    }

    setState(() {});
  }
}
