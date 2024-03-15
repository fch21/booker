import 'package:booker/helper/route_generator.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/widgets/client_card.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:flutter/material.dart';

class MyClients extends StatefulWidget {

  Function(AppUser)? onTapUser;

  MyClients({
    Key? key,
    this.onTapUser,
  }) : super(key: key);

  @override
  State<MyClients> createState() => _MyClientsState();
}

class _MyClientsState extends State<MyClients> {

  List<AppUser> clients = [];
  bool clientsAreLoaded = false;
  DateTime currentDateTime = DateTime.now();


  _getClientsList() async {
    clients.clear();
    List<AppUser> clientsList = await currentAppUser!.getClients();
    setState(() {
      clients = clientsList;
      clientsAreLoaded = true;
    });
  }

  @override
  void initState() {
    _getClientsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Meus clientes"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if(!clientsAreLoaded)
              Padding(
                padding: const EdgeInsets.only(top: 64.0),
                child: LoadingData(),
              ),
            if(clientsAreLoaded)
              clients.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(top: 32.0, bottom: 16),
                      child: Center(
                          child: Text("Nenhum cliente registrado até o momento", style: textStyleSmallNormal,)
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0), // Adicionado o padding lateral
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: clients.length,
                        itemBuilder: (BuildContext context, int index) {

                          AppUser client = clients[index];

                          //print("appointmentDetails.from = ${appointmentDetails.from}");
                          return Opacity(
                            opacity: 1.0,
                            child: ClientCard(
                              client: client,
                              onTap: (){
                                if(widget.onTapUser != null){
                                  widget.onTapUser!(client);
                                }
                                else{
                                  Navigator.pushNamed(context, RouteGenerator.CLIENT_PAGE, arguments: client).then((value){
                                    _getClientsList();
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}