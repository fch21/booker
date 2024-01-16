import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:flutter/material.dart';

class SubscriptionManagementPage extends StatefulWidget {
  SubscriptionManagementPage({Key? key}) : super(key: key);

  @override
  _SubscriptionManagementPageState createState() => _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends State<SubscriptionManagementPage> {


  Future<void> _showSubscriptionModal() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 20),
              const Text('Ainda nao estamos aceitando assinaturas premium, mas vamos te notificar em breve assim que for possível.'),
              const SizedBox(height: 20),
              ButtonCustom(
                text: 'Ok',
                onPressed: () {
                  Navigator.pop(context);
                },
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
              const SizedBox(height: 20),
              const Text('Selecione o método de pagamento que será utilizado para '),
              const SizedBox(height: 20),
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

  @override
  Widget build(BuildContext context) {

    int userSubscriptionLevel = currentAppUser!.subscriptionLevel;

    List<Widget> children = [];

    switch(userSubscriptionLevel){
      case 0:
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
            padding: EdgeInsets.only(top: 16.0),
            child: ButtonCustom(
              onPressed: () {
                _showSubscriptionModal();
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
        break;
      case 1:
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
        break;
      default:
        children = [];
        break;
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
