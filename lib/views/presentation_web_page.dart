import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/widgets/example_image_to_scroll.dart';
import 'package:booker/widgets/feature_item.dart';
import 'package:booker/widgets/header_section.dart';
import 'package:booker/widgets/image_with_description_item.dart';
import 'package:booker/widgets/infinite_automatic_scroll.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PresentationWebPage extends StatefulWidget {
  const PresentationWebPage({Key? key}) : super(key: key);

  @override
  State<PresentationWebPage> createState() => _PresentationWebPageState();
}

class _PresentationWebPageState extends State<PresentationWebPage> {

  bool isLoggedUser = false;

  GlobalKey<InfiniteAutomaticScrollState> featuresScrollGlobalKey = GlobalKey<InfiniteAutomaticScrollState>();
  GlobalKey<InfiniteAutomaticScrollState> userExamplesScrollGlobalKey = GlobalKey<InfiniteAutomaticScrollState>();

  void _pauseAutomaticScroll(GlobalKey<InfiniteAutomaticScrollState> globalKey){
    globalKey.currentState?.pause = true;
    return;
  }

  void _unpauseAutomaticScroll(GlobalKey<InfiniteAutomaticScrollState> globalKey){
    globalKey.currentState?.pause = false;
    return;
  }

  Future<void> showImage(String imagePath,{Object? extraHeroTag}) async {

    await Navigator.push(context, PageRouteBuilder(
        barrierColor: Colors.black.withOpacity(0.7),
        opaque: false,
        barrierDismissible: true,
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        pageBuilder: (context, animation1, animation2){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: Container( // Usa um Container para aplicar o gradiente
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, // Início do gradiente
                    end: Alignment.bottomCenter, // Fim do gradiente
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.only(bottom: kToolbarHeight),
              child: PhotoView(
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.contained * 2,
                backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                heroAttributes: PhotoViewHeroAttributes(tag: extraHeroTag == null ? imagePath : "$imagePath$extraHeroTag"),
                imageProvider: AssetImage(imagePath),
              ),
            ),
          );
        }));
    return;

  }

  Future<void> _pauseScrollAndShowImage(imagePath, heroKey) async {
    _pauseAutomaticScroll(userExamplesScrollGlobalKey);
    await showImage(imagePath, extraHeroTag: heroKey);
    _unpauseAutomaticScroll(userExamplesScrollGlobalKey);
  }

  Widget getActionButtons(){
    return Column(
      children: [
        if(!isLoggedUser)
          Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: GestureDetector(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text("Comece agora",
                        style: TextStyle(color: standartTheme.primaryColor, fontSize: fontSizeMedium, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.arrow_forward, color: standartTheme.primaryColor, size: 24,),
                    )
                  ],
                ),
                onTap: () async {
                  await Navigator.pushNamed(context, RouteGenerator.LOGIN);
                  isLoggedUser = currentAppUser != null;

                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    if(isLoggedUser){
                      Navigator.pushNamedAndRemoveUntil(context, RouteGenerator.INITIAL_EXPLORE_PAGE, (Route<dynamic> route) => false);
                    }
                  });
                },
              )
          ),
        GestureDetector(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text("Agende seu horário",
                  style: TextStyle(color: standartTheme.primaryColor, fontSize: fontSizeMedium, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(Icons.schedule, color: standartTheme.primaryColor, size: 24,),
              )
            ],
          ),
          onTap: () async {
            await Navigator.pushNamed(context, RouteGenerator.INITIAL_EXPLORE_PAGE);
            setState(() {isLoggedUser = currentAppUser != null;});
          },
        )
      ],
    );
  }

  FeatureItem getScrollFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required String longDescription,
  }){
    return FeatureItem(
      icon: icon,
      title: title,
      description: description,
      longDescription: longDescription,
      onTap: (){_pauseAutomaticScroll(featuresScrollGlobalKey);},
      onDismissedDialog: (){_unpauseAutomaticScroll(featuresScrollGlobalKey);},

    );
  }

  @override
  void initState() {
    isLoggedUser = currentAppUser != null;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(initialServiceProviderId != null || isLoggedUser){
        Navigator.pushNamedAndRemoveUntil(context, RouteGenerator.INITIAL_EXPLORE_PAGE, (Route<dynamic> route) => false);
      }
      precacheImage(const AssetImage("assets/presentation_page_appointment_example_1.png"), context);
      precacheImage(const AssetImage("assets/presentation_page_calendar_example_1.jpg"), context);
      precacheImage(const AssetImage("assets/presentation_page_calendar_example_2.png"), context);
      precacheImage(const AssetImage("assets/presentation_page_user_example_1.jpg"), context);
      precacheImage(const AssetImage("assets/presentation_page_user_example_2.jpg"), context);
      precacheImage(const AssetImage("assets/presentation_page_user_example_3.jpg"), context);
      precacheImage(const AssetImage("assets/presentation_page_user_example_4.jpg"), context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const HeaderSection(),
            Padding(
              padding: const EdgeInsets.only(top: 72),
              child: InfiniteAutomaticScroll(
                key: featuresScrollGlobalKey,
                items: [
                  getScrollFeatureItem(
                    icon: Icons.calendar_month,
                    title: 'Agenda Simplificada',
                    description: 'Acompanhe todos\nos seus agendamentos.',
                    longDescription: 'Visualize facilmente todos os seus agendamentos em uma interface clara. Gerencie seu tempo eficientemente, evitando trocas de mensagens desnecessárias e maximizando sua disponibilidade.',
                  ),
                  getScrollFeatureItem(
                    icon: Icons.sync,
                    title: 'Sincronização',
                    description: 'Sincronização\nem Tempo Real.',
                    longDescription: 'Atualizações instantâneas em sua agenda a cada novo agendamento ou alteração, assegurando que você e seus clientes estejam sempre em sincronia, sem conflitos de horários.',
                  ),
                  getScrollFeatureItem(
                    icon: Icons.schedule,
                    title: 'Agendamento Fácil',
                    description: 'Agende em segundos\ncom apenas alguns cliques.',
                    longDescription: 'Agende compromissos rapidamente com poucos cliques, aproveitando um processo simplificado que poupa tempo tanto para você quanto para seus clientes.',
                  ),
                  getScrollFeatureItem(
                    icon: Icons.notifications_active,
                    title: 'Lembretes Automáticos',
                    description: 'Nunca esqueça um compromisso\ncom os lembretes automáticos.',
                    longDescription: 'Evite faltas com lembretes automáticos enviados a você e seus clientes, garantindo que todos estejam preparados e pontuais para os compromissos.',
                  ),
                  getScrollFeatureItem(
                    icon: Icons.group,
                    title: 'Gerenciamento de Clientes',
                    description: 'Administre seus clientes\nem um só lugar.',
                    longDescription: 'Centralize informações de clientes, desde contato até preferências e histórico de agendamentos, facilitando o acompanhamento e a personalização do serviço oferecido.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 72.0),
              child: getActionButtons(),
            ),
            Padding(
              padding: const EdgeInsets.only(top:40.0),
              child: Container(
                color: Colors.grey[100],
                child: const Padding(
                  padding: EdgeInsets.only(top: 32, bottom: 32),
                  child: Center(
                    child: Text("Simples de Agendar", style: textStyleLargeBold,),
                  ),
                ),
              ),
            ),
            ImageWithDescriptionItem(
              title: "Em Apenas 3 Passos",
              description: "Um processo simplificado que te leva do início ao fim em apenas três passos.\n\nSelecione o serviço, escolha o horário e confirme. Tão fácil quanto parece.",
              imagePath: "assets/presentation_page_appointment_example_1.png",
              onTapImage: (imagePath){
                showImage(imagePath);
              },
              invert: true,
              bgColor: Colors.grey[100],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 32, bottom: 30),
              child: Center(
                child: Text("Organize com Facilidade", style: textStyleLargeBold,),
              ),
            ),
            ImageWithDescriptionItem(
              title: "Planeje de Forma Intuitiva",
              description: "Pensado para profissionais que querem estar à frente.\n\nAdaptável ao seu negócio, seja ele qual for.\n\nTudo sincronizado assim que os agendamentos forem realizados.",
              imagePath: "assets/presentation_page_calendar_example_1.jpg",
              onTapImage: (imagePath){
                showImage(imagePath);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: ImageWithDescriptionItem(
                title: "Visualize Seus Dias com Clareza",
                description: "Calendário com visão abrangente da sua agenda e design intuitivo.\n\nIdeal para profissionais autônomos que buscam sempre maximizar seu potencial.",
                imagePath: "assets/presentation_page_calendar_example_2.png",
                onTapImage: (imagePath){
                  showImage(imagePath);
                },
                invert: true,
              ),
            ),
            Container(
              color: Colors.grey[100],
              child: const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(
                  child: Text("Exemplos de Usuários", style: textStyleLargeBold,),
                ),
              ),
            ),
            Container(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 32.0),
                child: InfiniteAutomaticScroll(
                  key: userExamplesScrollGlobalKey,
                  items: [
                    ExampleImageToScroll(imagePath: "assets/presentation_page_user_example_1.jpg", onTap: _pauseScrollAndShowImage),
                    ExampleImageToScroll(imagePath: "assets/presentation_page_user_example_2.jpg", onTap: _pauseScrollAndShowImage),
                    ExampleImageToScroll(imagePath: "assets/presentation_page_user_example_3.jpg", onTap: _pauseScrollAndShowImage),
                    ExampleImageToScroll(imagePath: "assets/presentation_page_user_example_4.jpg", onTap: _pauseScrollAndShowImage),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 48.0, bottom: 48),
              child: getActionButtons(),
            ),
            Container(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 128),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.configurations_about_social_network,
                          style: textStyleMediumBold,
                        ),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: (){
                          Uri? uri = Uri.tryParse(Strings.BOOKER_INSTAGRAM_LINK);
                          if(uri != null){
                            launchUrl(uri);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (4/9)),
                          child: Container(
                            width: MediaQuery.of(context).size.width/8,
                            height: MediaQuery.of(context).size.width/8,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: AssetImage("assets/instagram_logo.png"),
                                )
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32, top: 64),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.configurations_about_contact_email,
                          style: textStyleMediumBold,
                        ),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: (){
                          Utils.sendEmailTo(context, email: Strings.BOOKER_EMAIL);
                        },
                        child: Text(
                          Strings.BOOKER_EMAIL,
                          style: TextStyle(color: standartTheme.primaryColor, fontSize: fontSizeMedium),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}






