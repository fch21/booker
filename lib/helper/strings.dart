class Consts{
  //premium subscription price
  static const double SUBSCRIPTION_PRICE = 9.99;
}

class Strings {

  static const List<String> WEEK_DAYS = ['Dom','Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb',];
  static const List<String> FULL_WEEK_DAYS = ['domingo','segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado',];
  static const String BOOKER = "Booker";
  static const String BOOKER_DOMAIN = "https://bookerweb.com/";
  static const String BOOKER_EMAIL = "central.booker@gmail.com";
  static const String BOOKER_INSTAGRAM_LINK = "https://instagram.com/app.booker";

  //Stripe
  //test
  static const String STRIPE_PUBLISHABLE_KEY = "pk_test_51OmofUAnghrwvGGzW6bDqfKqZr9ztV0KcyZ5kpP5yqw5Y1dpA4y4uCgtKpIQTul9io9YtCIqobKYlzgXENYZxXat00TiOHKMaa";
  //live
  //static const String STRIPE_PUBLISHABLE_KEY = "pk_live_51OmofUAnghrwvGGz1lBeZQnetZC0BcxeOJUHKMk17BsgZX1GDviRYFG9cvVwIICAN4XQZ8hGjAXfSbuRG0B3t7YO00bHtPXe5p";

  //google
  static const String GOOGLE_SIGN_CLIENT_ID = "1060470892593-46d486l7p1knpkeglnu2ccqqvl9igjbi.apps.googleusercontent.com";

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
  static const String USER_PHONE = "phone";
  static const String USER_TUTORIAL_DONE = "tutorial_done";
  static const String USER_WANT_NOTIFICATIONS = "want_notifications";
  static const String USER_LANGUAGE = "language";
  static const String USER_PASSWORD = "password";
  static const String USER_URL_PROFILE_USER_IMAGE = "url_profile_user_image";
  static const String USER_URL_PROFILE_BG_IMAGE = "url_profile_bg_image";
  static const String USER_TOKENS = "tokens";
  static const String USER_COLOR = "color";
  //static const String USER_SUBSCRIPTION_ID = "subscription_id";

  static const String USER_IS_SERVICE_PROVIDER = "is_service_provider";
  static const String USER_BLOCKED_CLIENTS_IDS = "blocked_clients_ids";
  static const String USER_AVAILABILITY_MAP = "availability_map";
  static const String USER_BLOCKED_PERIODS = "blocked_periods";

  //Blocked period
  static const String BLOCKED_PERIOD_START_DATE = "start_date";
  static const String BLOCKED_PERIOD_END_DATE = "end_date";

  //strings Service
  static const String SERVICE_ID = "id";
  static const String SERVICE_USER_ID = "user_id";
  static const String SERVICE_NAME = "name";
  static const String SERVICE_DESCRIPTION = "description";
  static const String SERVICE_DURATION = "duration";
  static const String SERVICE_PRICE = "price";
  static const String SERVICE_COLOR = "color";
  static const String SERVICE_HAS_PERIODIC_APPOINTMENTS = "has_periodic_appointments";
  static const String SERVICE_NUMBER_OF_PERIODIC_APPOINTMENTS = "number_of_periodic_appointments";
  static const String SERVICE_MINIMUM_SCHEDULING_DELAY_IN_MINUTES = "minimum_scheduling_delay_in_minutes";
  static const String SERVICE_SCHEDULING_INTERVAL_IN_MINUTES = "scheduling_interval_in_minutes";
  static const String SERVICE_FURTHEST_APPOINTMENT_ALLOWED_IN_DAYS = "furthest_appointment_allowed_in_days";

  static const String SUBSCRIPTION_ID = "id";
  static const String SUBSCRIPTION_USER_ID = "user_id";
  static const String SUBSCRIPTION_PAYMENT_METHOD_ID = "payment_method_id";
  static const String SUBSCRIPTION_DISCOUNT_CODE_ID = "discount_code_id";
  static const String SUBSCRIPTION_STATUS = "status";
  static const String SUBSCRIPTION_CREATION_DATE = "creation_date";
  static const String SUBSCRIPTION_NEXT_RENEWAL_DATE = "next_renewal_date";

  static const String DISCOUNT_CODE_ID = "id";
  static const String DISCOUNT_CODE_SALES_REP_ID = "sales_rep_id";
  static const String DISCOUNT_CODE_CODE = "code";
  static const String DISCOUNT_CODE_DISCOUNT_PERCENTAGE = "discount_percentage";
  static const String DISCOUNT_CODE_STATUS = "status";
  static const String DISCOUNT_CODE_DURATION = "duration";
  static const String DISCOUNT_CODE_DURATION_UNIT = "duration_unit";

  static const String SALES_REP_ID = "id";
  static const String SALES_REP_NAME = "name";
  static const String SALES_REP_NUMBER_OF_CLIENTS = "number_of_clients";



  //Appointment
  static const String APPOINTMENT_ID = "id";
  static const String APPOINTMENT_USER_NAME = "user_name";
  static const String APPOINTMENT_SERVICE_PROVIDER_NAME = "service_provider_name";
  static const String APPOINTMENT_SERVICE_NAME = "service_name";
  static const String APPOINTMENT_USER_ID = "user_id";
  static const String APPOINTMENT_SERVICE_ID = "service_id";
  static const String APPOINTMENT_SERVICE_PROVIDER_USER_ID = "service_provider_user_id";
  static const String APPOINTMENT_STATUS = "status";
  static const String APPOINTMENT_CANCELED_BY = "canceled_by";
  static const String APPOINTMENT_CANCEL_MESSAGE = "cancel_message";
  static const String APPOINTMENT_PERIODICAL_WEEK_DAY = "periodical_week_day";
  static const String APPOINTMENT_STATUS_PENDING = "pending";
  static const String APPOINTMENT_STATUS_CONFIRMED = "confirmed";
  static const String APPOINTMENT_STATUS_CANCELED = "canceled";
  static const String APPOINTMENT_CANCELED_BY_CLIENT = "client";
  static const String APPOINTMENT_CANCELED_BY_SERVICE_PROVIDER = "service_provider";
  static const String APPOINTMENT_DAY = "day";
  static const String APPOINTMENT_FROM = "from";
  static const String APPOINTMENT_TO = "to";
  //static const String APPOINTMENT_IS_ALL_DAY = "is_all_day";
  static const String APPOINTMENT_REMINDER_SENT = "reminder_sent";
  static const String APPOINTMENT_CHANGES = "changes";

  // appointment change
  static const String APPOINTMENT_CHANGE_INDEX = "index";
  static const String APPOINTMENT_CHANGE_NEW_FROM = "new_from";
  static const String APPOINTMENT_CHANGE_NEW_TO = "new_to";
  static const String APPOINTMENT_CHANGE_CANCELED = "canceled";
  static const String APPOINTMENT_CHANGE_CHANGE_FOLLOWING = "change_following";

  //

  static const String STRIPE_MAP_AMOUNT = "amount";
  static const String STRIPE_MAP_CURRENCY = "currency";
  static const String STRIPE_MAP_EVENT_ID = "event_id";
  static const String STRIPE_MAP_BUYER_USER_ID = "buyer_user_id";
  static const String STRIPE_MAP_USER_EMAIL = "user_email";
  static const String STRIPE_MAP_CUSTOMER_ID = "customer_id";
  static const String STRIPE_MAP_PAYMENT_METHOD_ID = "payment_method_id";
  static const String STRIPE_MAP_PROMOTION_CODE = "promotion_code";
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
  static const String COLLECTION_SUBSCRIPTIONS = "subscriptions";
  static const String COLLECTION_DISCOUNT_CODES = "discount_codes";
  static const String COLLECTION_SALES_REPS = "sales_reps";
  static const String COLLECTION_CLIENTS = "clients";
  static const String COLLECTION_USERS_PUBLIC = "users_public";
  static const String COLLECTION_SERVICES_PROVIDED = "services_provided";
  static const String COLLECTION_APPOINTMENTS_DETAILS = "appointments_details";
  static const String COLLECTION_APPOINTMENTS_DETAILS_PUBLIC = "appointments_details_public";

  static const String FIREBASE_DYNAMIC_LINK_URL = "https://drinqr.page.link";
  static const String HTTPS_LINK_CREATE_DRINK_UNIT_AFTER_PAYMENT_METHOD_SET = "https://us-central1-drinqr-context"".cloudfunctions.net/createDrinkUnitAfterPaymentMethodSet";
  static const String HTTPS_LINK_VALIDATE_DRINK_UNIT = "https://us-central1-drinqr-context"".cloudfunctions.net/validateDrinkUnit";
  //static const String HTTPS_LINK_STRIPE_PAYMENT_AUTOMATIC = "https://us-central1-drinqr-context"".cloudfunctions.net/stripePaymentAutomatic";
  //static const String HTTPS_LINK_STRIPE_PAYMENT_MANUAL = "https://us-central1-drinqr-context"".cloudfunctions.net/stripePaymentManual";
  //static const String HTTPS_LINK_GET_STRIPE_CONNECT_ACCOUNT_LOGIN_LINK = "https://us-central1-drinqr-context"".cloudfunctions.net/getStripeConnectAccountLoginLink";
  //static const String HTTPS_LINK_GET_STRIPE_ACCOUNT_STATUS = "https://us-central1-drinqr-context"".cloudfunctions.net/getStripeAccountStatus";
  //static const String HTTPS_LINK_GET_STRIPE_ACCOUNT_PENDING_BALANCE = "https://us-central1-drinqr-context"".cloudfunctions.net/getStripeAccountPendingBalance";
  //static const String HTTPS_LINK_CREATE_STRIPE_CONNECTED_ACCOUNT = "https://us-central1-drinqr-context"".cloudfunctions.net/createStripeConnectedAccount";
  //static const String HTTPS_LINK_ATTACH_PAYMENT_METHOD_TO_CUSTOMER = "https://us-central1-drinqr-context"".cloudfunctions.net/attachPaymentMethodToCustomer";
  //static const String HTTPS_LINK_DETACH_PAYMENT_METHOD_FROM_CUSTOMER = "https://us-central1-booker-context.cloudfunctions.net/detachPaymentMethodFromCustomer";
  static const String HTTPS_LINK_GET_COUPON_FROM_PROMOTION_CODE = "https://us-central1-booker-context.cloudfunctions.net/getCouponFromPromotionCode";
  static const String HTTPS_LINK_CREATE_SUBSCRIPTION_FOR_CUSTOMER = "https://us-central1-booker-context.cloudfunctions.net/createSubscriptionForCustomer";
  static const String HTTPS_LINK_GET_CUSTOMER_SUBSCRIPTION = "https://us-central1-booker-context.cloudfunctions.net/getCustomerSubscription";
  static const String HTTPS_LINK_CANCEL_CUSTOMER_SUBSCRIPTION = "https://us-central1-booker-context.cloudfunctions.net/cancelCustomerSubscription";
  static const String HTTPS_LINK_REACTIVATE_CUSTOMER_SUBSCRIPTION = "https://us-central1-booker-context.cloudfunctions.net/reactivateCustomerSubscription";
  static const String HTTPS_LINK_CREATE_SETUP_INTENT = "https://us-central1-booker-context.cloudfunctions.net/createSetupIntent";
  //static const String HTTPS_LINK_CHARGE_CARD_OFF_SESSION = "https://us-central1-drinqr-context"".cloudfunctions.net/chargeCardOffSession";
  static const String HTTPS_LINK_GET_CUSTOMER_PAYMENT_METHODS = "https://us-central1-booker-context.cloudfunctions.net/getCustomerPaymentMethods";
  static const String HTTPS_LINK_GET_CUSTOMER_PAYMENT_INTENTS = "https://us-central1-booker-context.cloudfunctions.net/getCustomerPaymentIntents";
  //static const String HTTPS_LINK_GET_USER_BY_EMAIL = "https://us-central1-drinqr-context"".cloudfunctions.net/getUserByEmail";


  static const String TERMS_OF_USE = '''
1. Introdução e Aceitação:

Bem-vindo ao Booker! Ao acessar nosso aplicativo e website, você aceita estar vinculado por estes Termos de Uso, inclusive quaisquer atualizações futuras. Estes Termos regem sua utilização da Plataforma Booker, que inclui agendar e oferecer serviços. A utilização da Plataforma também implica consentimento com nossa Política de Privacidade.


2. Elegibilidade e Consentimento:

A Plataforma é destinada a usuários com 18 anos ou mais. Usuários menores de idade devem obter consentimento dos pais ou responsáveis legais antes de usar a Plataforma. Ao utilizar a Plataforma, você afirma ter a capacidade legal necessária para aderir a estes Termos.


3. Contas de Usuário:

Você deve fornecer informações precisas e atualizadas ao criar sua conta. Você é responsável pela segurança de sua conta e deve notificar-nos imediatamente sobre qualquer uso não autorizado. A Plataforma se reserva o direito de suspender ou encerrar contas que violem estes Termos.


4. Licença de Uso:

Concedemos a você uma licença limitada, não exclusiva, revogável e pessoal para acessar e usar a Plataforma, exclusivamente para fins de agendamento ou oferta de serviços profissionais. É proibido o uso da Plataforma para quaisquer fins ilegais ou não autorizados.


5. Propriedade Intelectual:

O conteúdo da Plataforma é protegido por direitos autorais e marcas registradas. Qualquer uso não autorizado do conteúdo pode violar direitos de propriedade intelectual. Você concorda em respeitar todos os direitos de propriedade intelectual relacionados à Plataforma.


6. Modificações e Terminação:

A Plataforma se reserva o direito de modificar ou descontinuar qualquer aspecto ou recurso a qualquer momento, com aviso prévio. Seu uso contínuo após tais alterações constitui aceitação dos Termos modificados.


7. Limitação de Responsabilidade:

A Plataforma não garante que os serviços atenderão suas necessidades específicas ou estarão sempre disponíveis sem interrupções. Até o limite máximo permitido por lei, a Plataforma não será responsável por danos diretos ou indiretos resultantes do uso da Plataforma.


8. Indenização:

Você concorda em indenizar e isentar a Plataforma de quaisquer reivindicações resultantes do seu uso da Plataforma, violação destes Termos ou violação de qualquer direito de terceiros.


9. Lei Aplicável:

Estes Termos são regidos pelas leis do Brasil. Quaisquer disputas serão resolvidas nos tribunais brasileiros, salvo disposição em contrário na legislação aplicável.


10. Contato:

Para dúvidas ou comentários sobre estes Termos, entre em contato conosco em ${Strings.BOOKER_EMAIL}.
''';
  static const String PRIVACY_POLICY = '''
1. Informações Coletadas:

Detalhamos aqui os tipos específicos de dados pessoais coletados pela Plataforma, incluindo, mas não limitado a, nome, e-mail, número de telefone, e informações de pagamento processadas pela Stripe.


2. Finalidade do Processamento:

Explicamos como utilizamos suas informações, incluindo para facilitar o agendamento de serviços, enviar notificações relevantes e cumprir obrigações legais. Seu consentimento será solicitado conforme aplicável.


3. Compartilhamento de Informações:

Descrevemos com quais terceiros suas informações podem ser compartilhadas, como a Stripe para processamento de pagamentos, e sob quais condições, sempre protegendo sua privacidade.


4. Direitos dos Titulares:

Fornecemos instruções claras sobre como você pode exercer seus direitos de acesso, correção, exclusão, e oposição ao processamento de seus dados.


5. Segurança dos Dados:

Detalhamos as medidas de segurança adotadas para proteger seus dados, incluindo criptografia e procedimentos de segurança rigorosos.


6. Violação de Dados
Estabeleclecemos procedimentos específicos para notificação de violações de dados, incluindo a comunicação imediata a usuários afetados e autoridades competentes, conforme exigido por lei, detalhando as ações tomadas para mitigar o incidente.


7. Transferências Internacionais de Dados:

Clarificamos as medidas de proteção implementadas para dados transferidos internacionalmente, garantindo que todas as transferências cumpram com as normas de proteção de dados aplicáveis, utilizando mecanismos aprovados como Cláusulas Contratuais Padrão.


8. Política de Cookies e Tecnologias Similares:

Explicamos o uso de cookies e tecnologias similares pela Plataforma, incluindo os propósitos para os quais são usados. Fornecemos orientações sobre como você pode gerenciar suas preferências de cookies nas configurações do seu navegador.


9. Atualizações da Política de Privacidade:

Comprometemo-nos a comunicar quaisquer alterações significativas nesta Política, enviando notificações diretas aos usuários, além de atualizar a data de "última modificação" no documento. Incentivamos a revisão periódica desta Política para se manter informado sobre a proteção de seus dados.


10. Links para Outros Sites:

Advertimos sobre os links para sites externos presentes na Plataforma, recomendando que os usuários revisem as políticas de privacidade desses sites antes de compartilhar quaisquer informações pessoais, destacando que não nos responsabilizamos pelas práticas de privacidade de terceiros.


11. Exercício de Seus Direitos:

Detalhamos o processo para você exercer seus direitos relacionados aos dados pessoais sob nossa custódia, incluindo como fazer solicitações de acesso, correção, exclusão ou portabilidade dos dados, além de como retirar o consentimento para o processamento de seus dados.


12. Contato:

Para quaisquer questões ou preocupações relativas à sua privacidade e aos seus dados pessoais, encorajamos o contato direto conosco através do e-mail ${Strings.BOOKER_EMAIL}. Estamos comprometidos em responder prontamente e de forma transparente.
''';

}
