import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'gif_page.dart';

const urlTrending =
    'https://api.giphy.com/v1/gifs/trending?api_key=ZAiDiEFLdCOoqhD1Q8FzJoQc52C37Q3P&limit=20&rating=G';
const urlSearch =
    'https://api.giphy.com/v1/gifs/search?api_key=ZAiDiEFLdCOoqhD1Q8FzJoQc52C37Q3P&q=[term]&limit=19&offset=[offset]&rating=G&lang=en';

const urlLogo = 'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dio = Dio();
  String _search = '';
  int _offset = 0;

  Future<dynamic> _getGifs() async {
    Response response;

    if (_search.isEmpty) {
      response = await _dio.get(urlTrending);
    }
    else {
      final urlFinal = urlSearch.replaceFirst('[term]', _search).replaceFirst('[offset]', _offset.toString());
      response = await _dio.get(urlFinal);
    }

    return response.data;
  }

  @override
  void initState(){
    super.initState();

    _getGifs();
  }

  Widget _buildInputSearch(){
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Pesquise aqui',
          labelStyle: TextStyle(
              color: Colors.white
          ),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.white
              )
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.white
              )
          ),
        ),
        style: TextStyle(
            color: Colors.white,
            fontSize: 18
        ),
        textAlign: TextAlign.center,
        onSubmitted: (value){
          setState(() {
            _search = value;
          });
        },
      )
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10
      ),
      itemCount: _getCount(snapshot),
      itemBuilder: (context, index){
        if (_search.isEmpty || index < snapshot.data['data'].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              image: snapshot.data['data'][index]['images']['fixed_height']['url'],
              placeholder: kTransparentImage,
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GifPage(snapshot.data['data'][index])
              ));
            },
            onLongPress: (){
              Share.share(snapshot.data['data'][index]['images']['fixed_height']['url']);
            },
          );
        }
        else {
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white, size: 70),
                  Text('Carregar mais...', style: TextStyle(
                    color: Colors.white,
                    fontSize: 22
                  ))
                ],
              ),
              onTap: (){
                setState(() {
                  _offset += 19;
                });
              },
            )
          );
        }
      }
    );
  }

  int _getCount(AsyncSnapshot snapshot){
    if (_search.isEmpty){
      return snapshot.data['data'].length;
    }
    else {
      return snapshot.data['data'].length + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(urlLogo),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          _buildInputSearch(),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot){
                switch (snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                    );
                  default:
                    if (snapshot.hasError){
                      return Container();
                    }
                    return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      )
    );
  }
}
