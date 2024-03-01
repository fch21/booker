import 'package:booker/helper/strings.dart';
import 'package:booker/helper/stripe_functions.dart';
import 'package:booker/main.dart';
import 'package:flutter/material.dart';
import 'dart:html';
import 'dart:ui' as ui;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddPaymentMethodWithStripeElements extends StatefulWidget {



  const AddPaymentMethodWithStripeElements({
    Key? key,

  }) : super(key: key);

  @override
  State<AddPaymentMethodWithStripeElements> createState() => _AddPaymentMethodWithStripeElementsState();
}

class _AddPaymentMethodWithStripeElementsState extends State<AddPaymentMethodWithStripeElements> {

  String htmlContent = "";
  String? clientSecret;

  bool loading = true;
  bool hideIframe = false;

  String getHtmlWithClientSecret(String clientSecret){
    return '''
  <!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Accept a card payment</title>
    <meta name="description" content="A demo of a card payment on Stripe" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link rel="stylesheet" href="style.css" />
    <script src="https://js.stripe.com/v3/"></script>
    <script src="client.js" defer></script>
    
    <style>
      body {
        font-family: "Roboto", sans-serif;
        font-size: 16px;
        color: #333;
      }
  
      .container {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        min-height: 100vh;
        margin: 0 auto;
      }
  
      #submit {
        background-color: #003399;
        border: none;
        color: #ffffff;
        padding: 10px 0px;
        font-size: 16px;
        cursor: pointer;
        border-radius: 18px;
        margin-top: 18px;
        width: 100%;
        transition: background-color 0.2s;
      }
  
      #submit:hover {
        background-color: #002480;
      }
  
      #error-message {
        margin-top: 32px;
        font-size: 16px;
        color: #ff0000;
        text-align: center;
      }
    </style>
  </head>

  <body>
    <!-- Display a payment form -->
    <form id="payment-form">
    <div id="payment-element">
      <!-- Elements will create form elements here -->
    </div>
    <button id="submit">${AppLocalizations.of(context)!.add_credit_card_add}</button>
    <div id="error-message">
      <!-- Display error message to your customers here -->
    </div>
  </form>
  <script>
  var stripe = Stripe('${Strings.STRIPE_PUBLISHABLE_KEY}');
    
    const options = {
      clientSecret: '$clientSecret',
      // Fully customizable with appearance API.
      appearance: {/*...*/},
    };
    
    // Set up Stripe.js and Elements to use in checkout form, passing the client secret obtained in step 3
    const elements = stripe.elements(options);
    
    // Create and mount the Payment Element
    const paymentElement = elements.create('payment');
    paymentElement.mount('#payment-element');
    
    const form = document.getElementById('payment-form');

    form.addEventListener('submit', async (event) => {
      event.preventDefault();
    
      window.parent.postMessage({ type: 'setup_intent_processing' }, '*');
      const {error, setupIntent} = await stripe.confirmSetup({
        //`Elements` instance that was used to create the Payment Element
        elements,
        redirect: 'if_required',
        confirmParams: {
          //return_url: 'https://example.com/account/payments/setup-complete', 
        }
      }); 
    
      if (error) {
        // This point will only be reached if there is an immediate error when
        // confirming the payment. Show error to your customer (for example, payment
        // details incomplete)
        const messageContainer = document.querySelector('#error-message');
        messageContainer.textContent = error.message;
        window.parent.postMessage({ type: 'setup_intent_error' }, '*');
      } else {
        // Your customer will be redirected to your `return_url`. For some payment
        // methods like iDEAL, your customer will be redirected to an intermediate
        // site first to authorize the payment, then redirected to the `return_url`.
        
        if (setupIntent.status === 'succeeded') {
          // Envie uma mensagem para o Flutter informando que a configuração foi concluída com sucesso
          window.parent.postMessage({ type: 'setup_intent_success' }, '*');
        } 
        
      }
    });
  </script>
  
  </body>
</html>
  ''';
  }

  Future<void> _onMessage(dynamic event) async {
    if (event is MessageEvent) {
      final eventType = event.data['type'];

      if (eventType == 'setup_intent_processing') {
        print('Stripe setup intent processing');
        setState(() {
          loading = true;
        });
      }
      else if (eventType == 'setup_intent_error') {
        print('Stripe setup intent ERROR');
        setState(() {
          loading = false;
        });
      }
      else if (eventType == 'setup_intent_success') {
        print('Stripe setup intent succeeded');
        setState(() {
          hideIframe = true;
        });
        await _openDialogPaymentMethodCreated();
        setState(() {
          loading = false;
        });
        if(mounted) Navigator.of(context).pop();
      }
    }
  }

  Future<void> _openDialogPaymentMethodCreated() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            //title: Text(AppLocalizations.of(context)!.confirm),
              content: Text(AppLocalizations.of(context)!.payment_method_created_message, style: textStyleSmallNormal,),
              actions: <Widget>[
                TextButton(
                  child: const Text("Continuar"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ]);
        });
    return;
  }


  @override
  void initState() {
    // TODO: implement initState

    window.addEventListener('message', _onMessage);
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('create-payment-method',
      (int viewId) => IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..srcdoc = htmlContent
        //..src = "https://www.youtube.com/embed/5VbAwhBBHsg"
        ..style.border = 'none'
    );


  WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    final secrets = await StripeFunctions.fetchSetupIntent();

    if(secrets != null && secrets.containsKey("clientSecret")){
      setState(() {
        clientSecret = secrets["clientSecret"];
        loading = false;
      });
    }
  });

    super.initState();
  }



  @override
  void dispose() {
    window.removeEventListener('message', _onMessage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(clientSecret != null){
      htmlContent = getHtmlWithClientSecret(clientSecret!);
    }

    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.credit_cards_add_credit_card)),
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: clientSecret != null
                  ? Padding(
                    padding: const EdgeInsets.fromLTRB(24,48,24,0),
                    child: Center(
                      child: hideIframe
                          ? Container()
                          : const HtmlElementView(viewType: 'create-payment-method')
                    ),
                  )
                  : Container()
            ),
            if(loading)
              Container(
                color: Colors.white,
                child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: standartTheme.primaryColor,
                      ),
                    )
                ),
              )
          ],
        )
    );
  }
}
