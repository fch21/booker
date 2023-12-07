class Strings {

  static const List<String> WEEK_DAYS = ['Dom','Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb',];
  static const String BOOKER = "Booker";
  static const String BOOKER_DOMAIN = "https://drinqr.app/";
  static const String BOOKER_EMAIL = "contact.booker@gmail.com";
  static const String BOOKER_INSTAGRAM_LINK = "https://instagram.com/app.booker";

  //Stripe
  static const String STRIPE_TEST_PUBLISHABLE_KEY = "pk_test_51N1eo7AP3Df2AKXCoAuo8wFeOZ7vHChGB1Q74v4bxyXsHhod4tEhIbnwsFtgO3bdqvmPAUjVY3mfoOfrPYTv9ilH00tDrRrMgN";
  static const String STRIPE_LIVE_PUBLISHABLE_KEY = "pk_live_51N1eo7AP3Df2AKXCkOZSYNo7wivBmQsczpHcrBxxzZ1Rrdzsgok8g3nien2iwpqkfKB6opRfCNpPb2kVSVa9olBo008KUMiRE6";

  //languages
  static const String ENGLISH = "English";
  static const String PORTUGUES = "Português";
  static const String FRANCAIS = "Français";

  static const String ENGLISH_CODE = "en";
  static const String PORTUGUES_CODE = "pt";
  static const String FRANCAIS_CODE = "fr";

  static const String CAMERA = "Camera";
  static const String GALLERY = "Gallery";

  static const String DATE_EXEMPLE = "21/08/20";
  static const String TIME_EXEMPLE = "09:00";

  //Strings User
  static const String USER_ID = "user_id";
  static const String USER_NAME = "name";
  static const String USER_USERNAME = "user_name";
  static const String USER_DESCRIPTION = "description";
  static const String USER_EMAIL = "email";
  static const String USER_TUTORIAL_DONE = "tutorial_done";
  static const String USER_WANT_NOTIFICATIONS = "want_notifications";
  static const String USER_LANGUAGE = "language";
  static const String USER_PASSWORD = "password";
  static const String USER_URL_PROFILE_USER_IMAGE = "url_profile_user_image";
  static const String USER_URL_PROFILE_BG_IMAGE = "url_profile_bg_image";
  static const String USER_TOKENS = "tokens";
  static const String USER_COLOR = "color";

  static const String USER_IS_SERVICE_PROVIDER = "is_service_provider";
  static const String USER_AVAILABILITY_MAP = "availability_map";

  //strings Service Category
  static const String SERVICE_ID = "id";
  static const String SERVICE_USER_ID = "user_id";
  static const String SERVICE_NAME = "name";
  static const String SERVICE_DESCRIPTION = "description";
  static const String SERVICE_DURATION = "duration";
  static const String SERVICE_PRICE = "price";
  static const String SERVICE_COLOR = "color";



  //Drink Unit
  static const String APPOINTMENT_ID = "id";
  static const String APPOINTMENT_USER_NAME = "user_name";
  static const String APPOINTMENT_SERVICE_PROVIDER_NAME = "service_provider_name";
  static const String APPOINTMENT_SERVICE_NAME = "service_name";
  static const String APPOINTMENT_USER_ID = "user_id";
  static const String APPOINTMENT_SERVICE_ID = "service_id";
  static const String APPOINTMENT_SERVICE_PROVIDER_USER_ID = "service_provider_user_id";
  static const String APPOINTMENT_STATUS = "status";
  static const String APPOINTMENT_STATUS_PENDING = "pending";
  static const String APPOINTMENT_STATUS_CONFIRMED = "confirmed";
  static const String APPOINTMENT_STATUS_CANCELED = "canceled";
  static const String APPOINTMENT_DAY = "day";
  static const String APPOINTMENT_FROM = "from";
  static const String APPOINTMENT_TO = "to";
  static const String APPOINTMENT_IS_ALL_DAY = "is_all_day";


  static const String STRIPE_MAP_AMOUNT = "amount";
  static const String STRIPE_MAP_CURRENCY = "currency";
  static const String STRIPE_MAP_EVENT_ID = "event_id";
  static const String STRIPE_MAP_BUYER_USER_ID = "buyer_user_id";
  static const String STRIPE_MAP_USER_EMAIL = "user_email";
  static const String STRIPE_MAP_CUSTOMER_ID = "customer_id";
  static const String STRIPE_MAP_PAYMENT_METHOD_ID = "payment_method_id";
  static const String STRIPE_MAP_CARD_DETAILS = "card_details";

  static const String STRIPE_CURRENCY_BRL = "brl";
  static const String STRIPE_HTTP_RESPONSE_STATUS = "status";
  static const String STRIPE_HTTP_RESPONSE_PAYMENT_METHODS = "payment_methods";
  static const String STRIPE_HTTP_RESPONSE_PAYMENT_INTENTS = "payment_intents";
  static const String STRIPE_HTTP_RESPONSE_ERROR = "ERROR";
  static const String STRIPE_HTTP_RESPONSE_SUCCEEDED = "SUCCEEDED";
  static const String STRIPE_HTTP_RESPONSE_SUCCESS = "SUCCESS";
  static const String STRIPE_HTTP_RESPONSE_UNKNOWN_ERROR = "UNKNOWN ERROR";
  //static const String STRIPE_HTTP_RESPONSE_PAYMENT_INTENT_STATUS = "payment_intent_status";

  static const String STRIPE_REQUIRES_CAPTURE = "requires_capture";
  static const String STRIPE_CANCELED = "canceled";

  static const String STRIPE_MAP_PAYMENT_INTENT_CLIENT_SECRET = "client_secret";
  static const String STRIPE_MAP_PAYMENT_INTENT_MERCHANT_COUNTRY_CODE = "BR";
  static const String STRIPE_MAP_PAYMENT_INTENT_MERCHANT_DISPLAY_NAME = "Pars";
  static const String STRIPE_MAP_PAYMENT_INTENT_ID = "id";

  static const String STRIPE_REQUEST_PAYMENT_INTENT_ID = "payment_intent_id";
  static const String STRIPE_REQUEST_DRINK_UNIT = "drink_unit";
  static const String STRIPE_REQUEST_DRINK_UNITS = "drink_units";
  static const String STRIPE_REQUEST_DRINK_ORDER = "drink_order";

  static const String STRIPE_REQUEST_ORDER = "order";

  //Firestore
  static const String COLLECTION_USERS = "users";
  static const String COLLECTION_USERS_PUBLIC = "users_public";
  static const String COLLECTION_SERVICES_PROVIDED = "services_provided";
  static const String COLLECTION_APPOINTMENTS_DETAILS = "appointments_details";
  static const String COLLECTION_APPOINTMENTS_DETAILS_PUBLIC = "appointments_details_public";

  static const String FIREBASE_DYNAMIC_LINK_URL = "https://drinqr.page.link";
  static const String HTTPS_LINK_CREATE_DRINK_UNIT_AFTER_PAYMENT_METHOD_SET = "https://us-central1-drinqr-context"".cloudfunctions.net/createDrinkUnitAfterPaymentMethodSet";
  static const String HTTPS_LINK_VALIDATE_DRINK_UNIT = "https://us-central1-drinqr-context"".cloudfunctions.net/validateDrinkUnit";
  //static const String HTTPS_LINK_STRIPE_PAYMENT_AUTOMATIC = "https://us-central1-drinqr-context"".cloudfunctions.net/stripePaymentAutomatic";
  //static const String HTTPS_LINK_STRIPE_PAYMENT_MANUAL = "https://us-central1-drinqr-context"".cloudfunctions.net/stripePaymentManual";
  static const String HTTPS_LINK_GET_STRIPE_CONNECT_ACCOUNT_LOGIN_LINK = "https://us-central1-drinqr-context"".cloudfunctions.net/getStripeConnectAccountLoginLink";
  static const String HTTPS_LINK_GET_STRIPE_ACCOUNT_STATUS = "https://us-central1-drinqr-context"".cloudfunctions.net/getStripeAccountStatus";
  static const String HTTPS_LINK_GET_STRIPE_ACCOUNT_PENDING_BALANCE = "https://us-central1-drinqr-context"".cloudfunctions.net/getStripeAccountPendingBalance";
  static const String HTTPS_LINK_CREATE_STRIPE_CONNECTED_ACCOUNT = "https://us-central1-drinqr-context"".cloudfunctions.net/createStripeConnectedAccount";
  //static const String HTTPS_LINK_ATTACH_PAYMENT_METHOD_TO_CUSTOMER = "https://us-central1-drinqr-context"".cloudfunctions.net/attachPaymentMethodToCustomer";
  static const String HTTPS_LINK_DETACH_PAYMENT_METHOD_FROM_CUSTOMER = "https://us-central1-drinqr-context"".cloudfunctions.net/detachPaymentMethodFromCustomer";
  static const String HTTPS_LINK_CREATE_SETUP_INTENT = "https://us-central1-drinqr-context"".cloudfunctions.net/createSetupIntent";
  //static const String HTTPS_LINK_CHARGE_CARD_OFF_SESSION = "https://us-central1-drinqr-context"".cloudfunctions.net/chargeCardOffSession";
  static const String HTTPS_LINK_GET_CUSTOMER_PAYMENT_METHODS = "https://us-central1-drinqr-context"".cloudfunctions.net/getCustomerPaymentMethods";
  static const String HTTPS_LINK_GET_CUSTOMER_PAYMENT_INTENTS = "https://us-central1-drinqr-context"".cloudfunctions.net/getCustomerPaymentIntents";
  static const String HTTPS_LINK_GET_USER_BY_EMAIL = "https://us-central1-drinqr-context"".cloudfunctions.net/getUserByEmail";


  static const String TERMS_OF_USE = '''
1- Aceitação dos Termos

Ao acessar e usar o aplicativo ("Aplicativo"), você concorda em cumprir e estar legalmente vinculado a estes Termos de Uso ("Termos"). Caso não concorde com estes Termos, você não está autorizado a utilizar o Aplicativo. Ao utilizar o Aplicativo, você também concorda com a nossa Política de Privacidade, que pode ser encontrada abaixo.

2 - Elegibilidade

O Aplicativo é destinado a usuários com idade igual ou superior a 18 anos. Ao usar o Aplicativo, você declara e garante que tem idade suficiente para utilizar o Aplicativo e cumprir todos os requisitos de elegibilidade e residência.

3 - Conta do usuário

Para acessar e usar o Aplicativo, você deverá criar uma conta de usuário ("Conta"). Você concorda em fornecer informações verdadeiras, precisas e completas ao se registrar e manter essas informações atualizadas. Você é responsável por manter a confidencialidade de sua senha e é totalmente responsável por todas as atividades que ocorram sob sua Conta. Você concorda em notificar-nos imediatamente sobre qualquer uso não autorizado de sua Conta ou qualquer outra violação de segurança.

4 - Uso permitido

Você concorda em usar o Aplicativo apenas para fins legais e de acordo com estes Termos e todas as leis e regulamentações aplicáveis. Você concorda em não usar o Aplicativo de maneira que possa causar danos, inutilização, sobrecarga ou prejudicar o Aplicativo ou interferir no uso e aproveitamento do Aplicativo por terceiros.

5 - Propriedade intelectual

O Aplicativo, incluindo seu conteúdo, funcionalidades e design, é protegido por leis de direitos autorais, marcas registradas e outras leis de propriedade intelectual aplicáveis. Você concorda em não copiar, distribuir, modificar, criar trabalhos derivados ou explorar comercialmente qualquer parte do Aplicativo sem nossa permissão prévia por escrito.

6 - Isenção de responsabilidade e limitação de responsabilidade

O Aplicativo é fornecido "no estado em que se encontra" e "conforme disponível", sem qualquer garantia expressa ou implícita, incluindo, mas não se limitando a, garantias de comercialização, adequação a um propósito específico e não violação. Nós não garantimos que o Aplicativo atenderá às suas necessidades ou estará disponível ininterruptamente, pontualmente, de forma segura ou livre de erros. Em nenhuma circunstância seremos responsáveis por danos diretos, indiretos, incidentais, consequentes ou punitivos decorrentes do uso ou incapacidade de usar o Aplicativo.

7 - Indenização

Você concorda em defender, indenizar e isentar-nos de todas as reivindicações, responsabilidades, danos, perdas e despesas, incluindo honorários advocatícios razoáveis, decorrentes de ou relacionados ao seu uso do Aplicativo, sua violação destes Termos, ou sua violação de qualquer lei ou direito de terceiros, incluindo, mas não se limitando a, direitos de propriedade intelectual. 

8 - Modificação e rescisão

Reservamo-nos o direito de modificar ou encerrar o Aplicativo e estes Termos a qualquer momento e por qualquer motivo, sem aviso prévio. Você concorda em revisar periodicamente estes Termos para garantir que está ciente de quaisquer alterações. Seu uso continuado do Aplicativo após qualquer modificação destes Termos constituirá sua aceitação de tais modificações.

9 - Disposições gerais

Estes Termos constituem o acordo completo entre você e nós em relação ao uso do Aplicativo e substituem todas as comunicações e propostas anteriores e contemporâneas, sejam eletrônicas, orais ou escritas, entre você e nós com relação ao Aplicativo. Se qualquer disposição destes Termos for considerada inválida, ilegal ou inexequível por qualquer motivo, tal disposição será considerada separada dos demais Termos e não afetará a validade e aplicabilidade das demais disposições.

10 - Lei aplicável e jurisdição

Estes Termos são regidos e interpretados de acordo com as leis do Brasil. Você concorda em se submeter à jurisdição exclusiva dos tribunais do Brasil para resolver qualquer disputa decorrente do uso do Aplicativo ou destes Termos.

11 - Alterações nos Termos de Uso

Podemos alterar estes Termos de Uso a qualquer momento, a nosso exclusivo critério. Se fizermos alterações, iremos notificá-lo atualizando a data no início destes Termos e, em alguns casos, podemos fornecer um aviso adicional, como enviar um e-mail ou atualizar nosso aplicativo. É importante que você revise estes Termos de Uso sempre que os atualizarmos ou usar nosso aplicativo.

12 - Contato

Se você tiver alguma dúvida sobre estes Termos de Uso, entre em contato conosco pelo e-mail: ${Strings.BOOKER_EMAIL}.
  ''';
  static const String PRIVACY_POLICY = '''
1 - Informações coletadas

Coletamos informações pessoais quando você se registra e usa o Aplicativo, incluindo seu endereço de e-mail, nome de usuário e informações de pagamento. Também coletamos informações sobre suas transações, como as bebidas compradas e os eventos frequentados. Para organizadores de eventos, coletamos informações adicionais necessárias para a criação de uma conta conectada no Stripe.

2 - Uso das informações

Usamos as informações coletadas para fornecer, manter e melhorar o Aplicativo, processar transações, comunicar-se com você e cumprir nossas obrigações legais.

3 - Compartilhamento de informações

Compartilhamos suas informações com o serviço de pagamento Stripe para processar transações e com os organizadores de eventos para fornecer informações sobre as vendas de bebidas. Não compartilhamos suas informações com terceiros para fins de marketing.

4 - Segurança

Implementamos medidas de segurança razoáveis para proteger suas informações, incluindo o uso de criptografia e medidas de segurança do Firebase.

5 - Retenção de dados

Retemos suas informações pelo tempo necessário para cumprir os propósitos descritos nesta Política de Privacidade, a menos que um período de retenção mais longo seja exigido ou permitido por lei.

6 - Seus direitos

Você tem o direito de acessar, corrigir ou excluir suas informações pessoais, bem como o direito de limitar ou opor-se ao processamento de suas informações. Para exercer esses direitos, entre em contato conosco pelo e-mail: [email protected]

7 - Alterações na Política de Privacidade

Podemos atualizar esta Política de Privacidade a qualquer momento, a nosso exclusivo critério. Se fizermos alterações, iremos notificá-lo atualizando a data no início desta Política e, em alguns casos, podemos fornecer um aviso adicional, como enviar um e-mail ou atualizar nosso aplicativo. É importante que você revise esta Política de Privacidade sempre que a atualizarmos ou usar nosso aplicativo.

8 - Transferências de dados internacionais

Suas informações podem ser transferidas para, armazenadas e processadas em países fora do Brasil, onde nossos servidores estão localizados. Ao usar nosso aplicativo, você concorda com a transferência de suas informações para esses países.

9 - Direitos dos usuários e responsabilidade do controlador de dados

No caso de uma violação de dados, conforme exigido por lei, informaremos as autoridades competentes dentro de 72 horas após a descoberta da violação. Também notificaremos os usuários afetados assim que possível.

10 - Política de cookies

Nosso aplicativo utiliza cookies para melhorar sua experiência de navegação. Os cookies são pequenos arquivos de texto que são armazenados no seu dispositivo e nos ajudam a entender como você interage com nosso aplicativo. Você pode gerenciar suas preferências de cookies nas configurações do seu dispositivo.

11 - Links para outros sites

Nosso aplicativo pode conter links para outros sites que não são operados por nós. Se você clicar em um link de terceiros, será direcionado ao site desse terceiro. Recomendamos que você reveja a política de privacidade de cada site que visitar. Não temos controle e não assumimos nenhuma responsabilidade pelo conteúdo, políticas de privacidade ou práticas de sites ou serviços de terceiros.

12 - Contato

Se você tiver alguma dúvida sobre esta Política de Privacidade, entre em contato conosco pelo e-mail: ${Strings.BOOKER_EMAIL}.
  ''';

}
