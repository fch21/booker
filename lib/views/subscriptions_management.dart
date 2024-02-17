import 'dart:async';

import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/subscription.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SubscriptionManagementPage extends StatefulWidget {
  SubscriptionManagementPage({Key? key}) : super(key: key);

  @override
  _SubscriptionManagementPageState createState() => _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends State<SubscriptionManagementPage> {

  Subscription? subscription;
  bool subscriptionLoaded = false;

  Future<void> _showNotAvailableDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text('Ainda nao estamos aceitando assinaturas premium sem um código promocional, mas vamos te notificar em breve assim que for possível.'),
              ),
              ButtonCustom(
                text: 'Ok',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
    return;
  }

  Future<void> _showAddSubscriptionCodeDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {

        final codeFormKey = GlobalKey<FormState>();
        final TextEditingController codeController = TextEditingController();
        StreamController<bool> isVerifyingCodeStreamController = StreamController.broadcast();
        bool isVerifyingCode = false;
        bool? codeIsValid;

        return AlertDialog(
          title: const Center(
            child: Text(
              'Inserir Código Promocional',
              style: textStyleMediumBold,
            ),
          ),
          content: StreamBuilder<bool>(
            stream: isVerifyingCodeStreamController.stream,
            builder: (context, snapshot) {
              return Form(
                key: codeFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text('Adicione o seu código de desconto abaixo para ativar a sua assinatura Premium.\n\nApós a aplicação do código, você terá acesso imediato a todos os recursos exclusivos.'),
                    ),
                    if(codeIsValid != true)
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: InputCustom(
                              controller: codeController,
                              label: "Código",
                              onChanged: (value){
                                codeIsValid = null;
                                codeFormKey.currentState?.validate();
                              },
                              validator: (value) {
                                if(value == "" || value == null){
                                  return AppLocalizations.of(context)!.required_field;
                                }
                                if(codeIsValid != null && !codeIsValid!) return "Código inválido";
                                return null;
                              },
                            ),
                          ),
                          if(isVerifyingCode)
                            Container(color: Colors.white, child: LoadingData()),
                        ],
                      ),
                    if(codeIsValid == true)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text('Código validado com sucesso!', style: TextStyle(color: Colors.green, fontSize: fontSizeMedium),),
                        )
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: ButtonCustom(
                        text: (codeIsValid ?? false)? 'Continuar' : 'Confirmar',
                        onPressed: () async {
                          if (!(codeIsValid ?? false)) {
                            if(codeController.text.isNotEmpty && codeIsValid == null){
                              isVerifyingCode = true;
                              isVerifyingCodeStreamController.add(true);
                              codeIsValid = await Utils.verifyDiscountCode(context: context, code: codeController.text);
                              codeFormKey.currentState?.validate();
                              isVerifyingCode = false;
                              isVerifyingCodeStreamController.add(true);
                            }
                            else{
                              codeFormKey.currentState?.validate();
                            }
                          }
                          else{
                            //code is valid
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();//pop subscription_management
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
        );
      },
    );
    return;
  }

  Future<void> _showSubscriptionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: MediaQuery.of(context).size.height/10),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 12.0, bottom: 16.0),
                child: Text(
                  'Eleve Sua Experiência com o Premium',
                  style: textStyleMediumBold,
                  textAlign: TextAlign.center,
                ),
              ),
              const ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text('Eficiência completa com o calendário avançado'),
                leading: Icon(Icons.calendar_month),
              ),
              const ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text('Facilidade de cancelamentos por périodo'),
                leading: Icon(Icons.cancel),
              ),
              const ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text('Comunicação personalizada com seus clientes'),
                leading: Icon(Icons.message),
              ),
              const ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text('E muito mais...'),
                leading: Icon(Icons.diamond_outlined),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: Text('Escolha Como Começar:', style: textStyleSmallBold,)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16,24,16,16),
                child: ButtonCustom(
                  text: 'Adicionar forma de pagamento',
                  onPressed: () {
                    Navigator.pop(context);
                    _showNotAvailableDialog();
                  },
                ),
              ),
              Center(
                child: GestureDetector(
                  child: const Text(
                    "Inserir Código Promocional",
                    style: TextStyle(color: Colors.blue, fontSize: fontSizeVerySmall),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddSubscriptionCodeDialog();
                  },
                ),
              ),
            ],
          ),
        );


        /*
        return AlertDialog(
          title: const Text(
            'Confirme sua assinatura',
            style: textStyleMediumBold,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text('Selecione o método de pagamento que será utilizado para '),
              ),
              ButtonCustom(
                text: 'Cadastrar cartão',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, RouteGenerator.ADD_PAYMENT_METHOD_WITH_STRIPE_ELEMENTS, arguments: currentAppUser!);
                  //_navigateToCardRegistration(context); // Navega para a tela de registro do cartão
                },
              ),
            ],
          ),
        );

         */
      },
    );
    return;
  }


  Future<void> _getSubscription() async {
    if(currentAppUser!.subscriptionId.isNotEmpty){
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(Strings.COLLECTION_SUBSCRIPTIONS)
          .doc(currentAppUser!.subscriptionId)
          .get();

      Subscription userSubscription = Subscription.fromDocumentSnapshot(documentSnapshot);

      subscription = userSubscription;
    }
    setState(() {
      subscriptionLoaded = true;
    });
    return;
  }


  @override
  void initState() {
    _getSubscription();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    List<Widget> children = [];

    if(subscription == null){
      children = [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Aproveite ao máximo com a assinatura Premium',
            style: textStyleMediumBold,
            textAlign: TextAlign.center,
          ),
        ),
        const ListTile(
          title: Text('Acesso ao calendário com todos os agendamentos'),
          leading: Icon(Icons.calendar_month),
        ),
        const ListTile(
          title: Text('Possibilidade de cancelar todos os agendamentos em um périodo'),
          leading: Icon(Icons.cancel),
        ),
        const ListTile(
          title: Text('Envio de mensagens personalizadas aos seus clientes'),
          leading: Icon(Icons.message),
        ),
        const ListTile(
          title: Text('Acesso a todos os recursos'),
          leading: Icon(Icons.star),
        ),
        // Adicione mais benefícios aqui
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
          child: ButtonCustom(
            onPressed: () {
              _showSubscriptionDialog();
            },
            text: 'Assine Agora',
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
          child: Text(
            'A assinatura é renovada automaticamente e pode ser cancelada a qualquer momento.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: Wrap(
                children: [
                  const Text(
                    'Para mais informações entre em contato conosco pelo email: ',
                    style: TextStyle(fontSize: fontSizeVerySmall, color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: (){
                      Utils.sendEmailTo(context, email: Strings.BOOKER_EMAIL);
                    },
                    child: const Text(
                      Strings.BOOKER_EMAIL,
                      style: TextStyle(fontSize: fontSizeVerySmall, color: Colors.grey),
                    ),
                  ),
                ]
            )


        ),
      ];
    }
    else{
      children = [
        SubscriptionDetailCard(
          title: 'Status da Assinatura',
          // Aqui você pode inserir os detalhes do status da assinatura
          content: 'Ativa - Renova em 30 dias',
        ),
        SubscriptionDetailCard(
          title: 'Detalhes da Assinatura',
          // Detalhes da assinatura atual ou disponível
          content: 'Plano Premium - Acesso ilimitado a todos os recursos',
        ),
        SubscriptionDetailCard(
          title: 'Método de Pagamento',
          // Detalhes do método de pagamento
          content: 'Cartão de Crédito **** **** **** 1234',
        ),
        SizedBox(height: 20),
        ButtonCustom(
          onPressed: () {
            // Lógica para gerenciar assinatura
          },
          text: 'Gerenciar Assinatura',
        ),
      ];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: Text('Gerenciamento de Assinaturas'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: children
      ),
    );
  }
}

class SubscriptionDetailCard extends StatelessWidget {
  final String title;
  final String content;

  const SubscriptionDetailCard({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title),
        subtitle: Text(content),
      ),
    );
  }
}
