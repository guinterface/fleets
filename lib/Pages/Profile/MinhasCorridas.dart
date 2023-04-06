import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'dart:convert';

import '../../Classes/Corrida.dart';
import '../../Classes/Usuario.dart';
import '../DetalhesCorrida.dart';


class MinhasCorridas extends StatefulWidget {
  final Usuario usuario;
  MinhasCorridas({Key? key, required this.usuario}) : super(key: key);
  @override
  _MinhasCorridasState createState() => _MinhasCorridasState();
}

class _MinhasCorridasState extends State<MinhasCorridas> {

  List<String> itensMenu = [
    "Configurações", "Deslogar"
  ];
  final _controller = StreamController<List<dynamic>>.broadcast();
  List<dynamic> listaCorridas = [];




  _escolhaMenuItem( String escolha ){

    switch( escolha ){
      case "Deslogar" :

        break;
      case "Configurações" :

        break;
    }

  }

  _adicionarListenerRequisicoes(){

    /*final stream = db.collection("requisicoes")
        .where("status", isEqualTo: StatusRequisicao.AGUARDANDO )
        .snapshots();*/
    final _stream = getCorridas(widget.usuario);

    _stream.listen((dados){
      print("chegamos aqui");
      var jsonResponse =
      jsonDecode(dados.body);
      print("controller add : ${jsonResponse['travels']}");
      _controller.add( jsonResponse['travels'] );
      print(_controller.toString());

    });



  }
  void getRaces(List<String> arguments, Usuario _usuario) async {
    print("Ate aqui");
    var url = Uri.parse("https://obdi.com.br/obdigt/api/usuario/ultimas_corridas/${_usuario.id}");

    // You will wait for the response and then decode the JSON string.
    var response = await http.get(url);
    print("resposta : $response");
    if (response.statusCode != 200) {
      print("${response.statusCode}");
    } else {
      var jsonResponse =
      jsonDecode(response.body);
      print("jresposta : $jsonResponse");

      print('Number of books about http: ${jsonResponse['travels']}');
      Stream<List<dynamic>> stream = jsonResponse;

      stream.listen((dados){
        _controller.add( dados );
      });
    }
  }
  bool verifica(int booleano){
    if(booleano == 1){
      return true;
    }
    return false;
  }
  Stream<http.Response> getCorridas(Usuario _usuario) async* {
    yield* Stream.periodic(Duration(seconds: 5), (_) async{
      print("Ate aqui");
      var url = Uri.parse("https://obdi.com.br/obdigt/api/usuario/ultimas_corridas/${_usuario.id}");

      // You will wait for the response and then decode the JSON string.
      var response = await http.get(url);
      print("resposta : $response");
      if (response.statusCode != 200) {
        print("${response.statusCode}");
      } else {
        var jsonResponse =
        jsonDecode(response.body);
        print("jresposta : $jsonResponse");

        print('Number of books about http: ${jsonResponse['travels']}');
        listaCorridas = jsonResponse['travels'];

      }
      return response;
    }).asyncMap((event) async => await event);
  }


  @override
  void initState() {
    super.initState();

    //adiciona listener para recuperar requisições
    _adicionarListenerRequisicoes();

  }

  @override
  Widget build(BuildContext context) {

    var mensagemCarregando = Center(
      child: Column(
        children: <Widget>[
          Text("Carregando corridas...."),
          CircularProgressIndicator(color: Colors.lightGreenAccent,)
        ],
      ),
    );

    var mensagemNaoTemDados = Center(
      child: Text(
        "Você ainda não adicionou nenhuma corrida ",
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text("Ultimas Corridas", style: TextStyle(color: Colors.lightGreenAccent),),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context){

              return itensMenu.map((String item){

                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );

              }).toList();

            },
          )
        ],
      ),
      body:

      StreamBuilder<List<dynamic>>(
          stream: _controller.stream,
          builder: (context, snapshot){
            switch( snapshot.connectionState ){
              case ConnectionState.none:
              case ConnectionState.waiting:
                return mensagemCarregando;
                break;
              case ConnectionState.active:
              case ConnectionState.done:

                if( snapshot.hasError ){
                  return Text("Erro ao carregar os dados!");
                }else {

                  var mapa = snapshot.data;
                  if( listaCorridas.isEmpty){
                    return mensagemNaoTemDados;
                  }else{

                    return
                      Column(

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(padding: EdgeInsets.only(top: 20, left: 10),
                            child:Text("Aqui estão suas", style: TextStyle(fontSize: 18),),
                          ),
                          Padding(padding: EdgeInsets.only(top: 0, left: 10),
                            child: Text("corridas concluídas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
                          ),
                          /*Padding(padding: EdgeInsets.only(top: 0, left: 10, bottom: 16),
                            child: Image.asset("bck1/list1.png", width: 230),
                          ),*/

                          Flexible(child:
                          ListView.separated(

                              itemCount: listaCorridas.length,
                              separatorBuilder: (context, indice) => Divider(
                                height: 2,
                                color: Colors.grey,
                              ),
                              itemBuilder: (context, indice){

                                List<dynamic> requisicoes = listaCorridas;
                                Map<String, dynamic> item = requisicoes[ indice ];


                                var bairroOrigem = item["bairro_partida"];
                                var dataCorrida = item["data"];
                                Corrida corrida = Corrida();
                                corrida.observacoes = item["observacoes"];
                                corrida.endereco_destino = item["endereco_destino"];
                                corrida.endereco_partida = item["endereco_partida"];
                                corrida.pernoite = verifica(item["pernoite"]);
                                corrida.data = item["data"];
                                corrida.hora = item["hora"];





                                return GestureDetector(

                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => DetalhesCorrida(corrida: corrida,)

                                      ));
                                    },
                                    child: Card(
                                        color: Colors.black87,
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child:
                                          Column(

                                            children: [


                                              Row(children: [
                                                Icon(Icons.directions_car_sharp, color: Colors.white,),

                                                Padding(padding: EdgeInsets.only(left: 32, right: 32, ), child:
                                                Column(
                                                  children: [ Text(
                                                    bairroOrigem,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                    Padding(padding: EdgeInsets.only(top: 6),),
                                                    Text(
                                                      dataCorrida,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.lightGreenAccent,

                                                      ),
                                                    ),

                                                  ],
                                                )


                                                  ,),
                                                Icon(Icons.arrow_forward, color: Colors.lightGreenAccent,)
                                              ],


                                              )
                                              ,


                                            ],

                                          )
                                          ,

                                        )
                                    )
                                );

                              }
                          )
                          )
                        ],
                      );


                  }

                }

                break;
            }
          }
      ),
    );
  }
}
