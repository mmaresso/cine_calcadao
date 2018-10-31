import 'dart:async';
import 'package:share/share.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

void main() async{
//  DocumentSnapshot snapshot = await Firestore.instance.collection("teste").document("teste").get();
//  print(snapshot.data);
//    Firestore.instance.collection("movies_next").document("movie1").setData({"title" : "Robin Hood","data":"Em Breve", "hora":"", "subtitle":"", "url" : ""});
//    Firestore.instance.collection("movies_next").document("movie2").setData({"title" : "Animais Fantásticos: Os Crimes de Grindelwald","data":"Em Breve", "hora":"", "subtitle":"","url" : ""});
//    Firestore.instance.collection("movies_next").document("movie3").setData({"title" : "O Quebra-Nozes e Os Quatro Reinos","data":"Em Breve", "hora":"", "subtitle":"", "url" : ""});
//    Firestore.instance.collection("movies_next").document("movie4").setData({"title" : "Nasce Uma Estrela","data":"Em Breve", "hora":"", "subtitle":"", "url" : ""});
  runApp(MaterialApp(
    title: "Cine Calçadão",
    home: Home(),
  ));
}


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();


  @override
  void initState() {
    super.initState();
    firebaseCloudMessaging_Listeners();
  }
  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token){
      print("Token:$token");
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        print("Mensagem recebia");
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }

  Future<QuerySnapshot> _getMovie (String title) async{

      QuerySnapshot snapshot = await Firestore.instance.collection(title).getDocuments();
     return (snapshot);
  }

  Future<Null> _info(String title, String tipo) async {
    DocumentSnapshot snapshot = await Firestore.instance.collection(tipo).document(title).get();

    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Chip(label: Text(snapshot.data["title"]), avatar: Icon(Icons.local_movies, color: Colors.red,),),
          content: SingleChildScrollView(
            child: Wrap(direction: Axis.vertical ,

                  children: <Widget>[
                  Chip(label: Text(snapshot.data["data"]), avatar: Icon(Icons.date_range, color: Colors.blueAccent,),),
                  Chip(label: Text(snapshot.data["hora"]), avatar: Icon(Icons.access_time, color: Colors.green,),),
                  Chip(label: Text(snapshot.data["subtitle"]), avatar: Icon(Icons.subtitles, color: Colors.yellowAccent,),),
                  ],
                ),

          )

    );
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(128, 0, 0, 1.0),
            bottom: TabBar(tabs: [
              Tab(
                icon: Icon(Icons.local_movies),
                text: "Em Exibição",
              ),
              Tab(
                icon: Icon(Icons.movie_filter),
                text: "Em breve",
              ),
              Tab(
                icon: Icon(Icons.contacts),
                text: "Contato",
              ),
            ]),
            title: Center(
                child: Image.asset("./images/logo_ccsite.png", scale: 0.1,)
            ),
          ),
          body: TabBarView(children: [
            SingleChildScrollView(
              child: FutureBuilder<QuerySnapshot>(
                  future: _getMovie("movies_now"),
                  builder: (BuildContext context,  AsyncSnapshot<QuerySnapshot> snapshot){
                    switch(snapshot.connectionState){
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Container(
                            width: 200.0,
                            height: 200.0,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              strokeWidth: 5.0,
                            )
                        );
                      default:
                        if(snapshot.hasError){
                          return Center(
                              child: Text("Erro ao Carregar Dados :(",
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 25.0),
                                textAlign: TextAlign.center,)
                          );
                        } else {

                          QuerySnapshot querysnapshot = snapshot.data;

                          DocumentSnapshot doc1 = querysnapshot.documents[0];
                          DocumentSnapshot doc2 = querysnapshot.documents[1];
                          DocumentSnapshot doc3 = querysnapshot.documents[2];



                          return Column(
                            children: <Widget>[
                              _movie(doc1.data["url"], doc1.data["title"],"movie1","movies_now"),
                              _movie(doc2.data["url"],  doc2.data["title"], "movie2","movies_now"),
                              _movie(doc3.data["url"],  doc3.data["title"], "movie3","movies_now"),
                            ],
                          );
                        }
                    }
                  }),
            ),
            SingleChildScrollView(
              child: FutureBuilder<QuerySnapshot>(
                  future: _getMovie("movies_next"),
                  builder: (BuildContext context,  AsyncSnapshot<QuerySnapshot> snapshot){
                    switch(snapshot.connectionState){
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Container(
                            width: 200.0,
                            height: 200.0,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              strokeWidth: 5.0,
                            )
                        );
                      default:
                        if(snapshot.hasError){
                          return Center(
                              child: Text("Erro ao Carregar Dados :(",
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 25.0),
                                textAlign: TextAlign.center,)
                          );
                        } else {

                          QuerySnapshot querysnapshot = snapshot.data;

                          DocumentSnapshot doc1 = querysnapshot.documents[0];
                          DocumentSnapshot doc2 = querysnapshot.documents[1];
                          DocumentSnapshot doc3 = querysnapshot.documents[2];
                          DocumentSnapshot doc4 = querysnapshot.documents[3];


                          return Column(
                            children: <Widget>[
                              _movie(doc1.data["url"], doc1.data["title"],"movie1", "movies_next"),
                              _movie(doc2.data["url"],  doc2.data["title"], "movie2","movies_next"),
                              _movie(doc3.data["url"],  doc3.data["title"], "movie3","movies_next"),
                              _movie(doc4.data["url"],  doc4.data["title"], "movie4","movies_next"),
                            ],
                          );
                        }
                    }
                  }),
            ),
            Padding(padding: EdgeInsets.all(10.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('Cine Caçadão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0),),
                Divider(),
                Text('Rua Presidente Arthur Bernardes,132 Centro ', style: TextStyle(fontSize: 17.0),),
                Text('Shopping Calçadão 2 piso, Viçosa – MG', style: TextStyle(fontSize: 17.0),),
                Divider(),
                Text('Telefone: (31)3891-0316', style: TextStyle(fontSize: 17.0),),
                Divider(),
                Text('Facebook: https://www.facebook.com/cinemavicosa', style: TextStyle(fontSize: 17.0),),
                Divider(),
              ],)
              ,)

          ]),
        ));
  }


  Widget _movie(String _image, String _title, String movie, String tipo) {
    return Card(
        child: Column(children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: _image != "" ? Image.network(_image): Text("$_title (Imagem em breve..)"),
            ),

          ),
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
             FlatButton(
               onPressed:  () => _info(movie,tipo),
               child: Text("+Info", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
               color: Colors.blue,),
             IconButton(icon: Icon(Icons.share),
               color: Colors.lightBlue,
               onPressed: (){Share.share(tipo == "movies_new" ? "Acabou de estrear filme no cinema! Vamos assistir $_title" :"Tá chegando filme novo no cinema, junte uma graninha pra a gente ir assistir $_title" );
               },
             )
           ],
         )
        ],)
    );
  }

}

