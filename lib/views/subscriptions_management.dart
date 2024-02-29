import 'dart:async';

import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/stripe_functions.dart';
import 'package:booker/helper/user_sign.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/coupon.dart';
import 'package:booker/models/subscription.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:booker/widgets/payment_method_preview.dart';
import 'package:booker/widgets/payment_method_preview_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SubscriptionManagementPage extends StatefulWidget {
  SubscriptionManagementPage({Key? key}) : super(key: key);

  @override
  _SubscriptionManagementPageState createState() => _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends State<SubscriptionManagementPage> {

  Subscription? _subscription;
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
        bool? promotionCodeIsValid;
        String? promotionCode;
        Coupon? coupon;

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
                    if(promotionCodeIsValid != true)
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: InputCustom(
                              controller: codeController,
                              label: "Código",
                              onChanged: (value){
                                promotionCodeIsValid = null;
                                codeFormKey.currentState?.validate();
                              },
                              validator: (value) {
                                if(value == "" || value == null){
                                  return AppLocalizations.of(context)!.required_field;
                                }
                                if(promotionCodeIsValid != null && !promotionCodeIsValid!) return "Código inválido";
                                return null;
                              },
                            ),
                          ),
                          if(isVerifyingCode)
                            Container(color: Colors.white, child: LoadingData()),
                        ],
                      ),
                    if(promotionCodeIsValid == true)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text('Código validado com sucesso!', style: TextStyle(color: Colors.green, fontSize: fontSizeMedium),),
                        )
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: ButtonCustom(
                        text: (promotionCodeIsValid ?? false)? 'Continuar' : 'Verificar',
                        onPressed: () async {
                          if (!(promotionCodeIsValid ?? false)) {
                            if(codeController.text.isNotEmpty && promotionCodeIsValid == null){
                              promotionCode = codeController.text;
                              isVerifyingCode = true;
                              isVerifyingCodeStreamController.add(true);
                              coupon = await StripeFunctions.getCouponFromPromotionCode(promotionCode: promotionCode);
                              //codeIsValid = await DiscountCode.verifyDiscountCode(context: context, code: codeController.text);
                              promotionCodeIsValid = coupon != null;
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
                            _showSubscriptionDialog(coupon: coupon, promotionCode: promotionCode);
                            //Navigator.of(context).pop();//pop subscription_management
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

  Future<void> _showSubscriptionDialog({Coupon? coupon, String? promotionCode}) async {

    StreamController<bool> isLoadingStreamController = StreamController.broadcast();
    List? paymentMethods;

    StripeFunctions.getCustomerPaymentMethods(userId: currentAppUser!.id).then((value){
      paymentMethods = value;
      isLoadingStreamController.add(false);
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: MediaQuery.of(context).size.height/10),
          content: SingleChildScrollView(
            child: Column(
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
                if(coupon != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(child: Text('Cupom Aplicado:', style: textStyleSmallBold,)),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text('Desconto: ${coupon.percentOff}%\nDuração: ${coupon.getDurationString()}', style: textStyleSmallNormal,),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(child: Text('Assine agora por ${Subscription.getSubscriptionPriceString(coupon)}/mês ${coupon != null ? '(com desconto)' : ''}', style: textStyleSmallBold,)),
                ),
                StreamBuilder<bool>(
                  stream: isLoadingStreamController.stream,
                  initialData: true,
                  builder: (context, snapshot) {

                    bool isLoading = snapshot.data ?? false;

                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if(paymentMethods?.isNotEmpty ?? false)
                                Padding(
                                  padding: const EdgeInsets.only(top:16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Pagamento:', style: textStyleSmallBold,),
                                      GestureDetector(
                                        child: const Text(
                                          "Alterar",
                                          style: TextStyle(color: Colors.blue, fontSize: fontSizeVerySmall),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.pushNamed(context, RouteGenerator.ADD_PAYMENT_METHOD_WITH_STRIPE_ELEMENTS).then((value) => _showSubscriptionDialog());
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              if(paymentMethods?.isNotEmpty ?? false)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: PaymentMethodPreview(paymentMethodMap: paymentMethods!.first),
                                ),

                              if(coupon == null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 24.0),
                                  child: Center(
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
                                ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(24,24,16,0),
                                child: ButtonCustom(
                                  text: (paymentMethods?.isNotEmpty ?? false) ? 'Assinar' : 'Adicionar forma de pagamento' ,
                                  onPressed: (paymentMethods?.isNotEmpty ?? false)
                                      ? () async {
                                        isLoadingStreamController.add(true);
                                        bool success = await StripeFunctions.createSubscriptionForCustomer(promotionCode: promotionCode);

                                        if(success) {
                                          _getSubscription();
                                          if(mounted) Navigator.pop(context);
                                        }
                                        else{
                                          isLoadingStreamController.add(false);
                                          if(mounted) Utils.showSnackBar(context, "Erro ao fazer assinatura.");
                                        }
                                      }
                                      : () {
                                        Navigator.pop(context);
                                        Navigator.pushNamed(context, RouteGenerator.ADD_PAYMENT_METHOD_WITH_STRIPE_ELEMENTS).then((value) => _showSubscriptionDialog());
                                        //_showNotAvailableDialog();
                                      },
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(isLoading)
                          Positioned.fill(
                            child: Container(
                              color: Colors.white,
                              //child: Center(
                                child: LoadingData()
                             // )
                            ),
                          )
                      ],
                    );
                  }
                ),
              ],
            ),
          ),
        );
      },
    );
    return;
  }

  Future<void> _subscriptionCanceledDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Assinatura Cancelada'),
          content: Text('Seu cancelamento foi realizado com sucesso. Você continuará a ter acesso aos benefícios premium até o final do seu período de faturamento atual.'),
          actionsAlignment: MainAxisAlignment.end,
          actions: <Widget>[
            TextButton(
              child: Text('Entendi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return;
  }

  Future<void> _cancelSubscriptionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmar cancelamento'),
          content: Text('Tem certeza que deseja cancelar a sua assinatura?\nApós o cancelamento, você vai perder todos os benefícios da sua conta premium.'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: Text('Voltar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Cancelar Assinatura', style: TextStyle(color: Colors.red),),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                setState(() {
                  subscriptionLoaded = false;
                });
                bool canceled = await StripeFunctions.cancelCustomerSubscription();
                //await _subscription!.cancelSubscription(context);
                if(canceled) {
                  await _subscriptionCanceledDialog();
                  await _getSubscription();
                }
                else{
                  if(mounted) Utils.showSnackBar(context, "Erro ao cancelar assinatura");
                  setState(() {
                    subscriptionLoaded = true;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getSubscription() async {
    setState(() {
      subscriptionLoaded = false;
    });
    Subscription? userSubscription = await StripeFunctions.getCustomerSubscription();
    _subscription = userSubscription;

    setState(() {
      subscriptionLoaded = true;
    });
    return;
  }

  List<Widget> getChildren(){
    List<Widget> children = [];

    if(_subscription == null){
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
          content: _subscription!.isValid
              ? 'Ativa - Renova em ${Utils.formatDateTimeToVisualize(_subscription!.currentPeriodEnd, onlyDate: true)}'
              : _subscription!.isCanceled
                ? 'Expirada - Clique para renovar sua asssinatura'
                : 'Suspensa - Erro no pagamento',
        ),
        const SubscriptionDetailCard(
          title: 'Detalhes da Assinatura',
          // Detalhes da assinatura atual ou disponível
          content: 'Plano Premium - Acesso ilimitado a todos os recursos',
        ),
        SubscriptionDetailCard(
          title: 'Método de Pagamento',
          // Detalhes do método de pagamento
          content: 'paymentMethodId: ${_subscription!.id}'//'Cartão de Crédito **** **** **** 1234',
        ),
        if(_subscription!.isValid)
          Padding(
            padding: const EdgeInsets.only(top: 48.0),
            child: Center(
              child: TextButton(
                onPressed: _cancelSubscriptionDialog,
                child: const Text('Cancelar assinatura', style: TextStyle(color: Colors.red, fontSize: fontSizeVerySmall),),
              ),
            ),
          ),
        if(!_subscription!.isValid)
          Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 16, right: 16),
            child: ButtonCustom(
              onPressed: () {
                _showSubscriptionDialog();
              },
              text: 'Renovar Assinatura',
            ),
          ),
      ];
    }

    return children;
  }

  @override
  void initState() {
    _getSubscription();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {





    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: Text('Assinatura'),
      ),
      body: subscriptionLoaded
          ? ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: getChildren()
          )
          : LoadingData(),
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
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title),
        subtitle: Text(content),
      ),
    );
  }
}
