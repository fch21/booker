import 'package:booker/views/configurations_home.dart';
import 'package:booker/views/explore.dart';
import 'package:booker/widgets/custom_slider_drawer.dart';
import 'package:flutter/material.dart';
import 'package:booker/main.dart';
import 'package:booker/helper/Strings.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

class InitialExplorePage extends StatefulWidget {

  InitialExplorePage({super.key});

  @override
  _InitialExplorePageState createState() => _InitialExplorePageState();
}

class _InitialExplorePageState extends State<InitialExplorePage> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //_tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Widget body = Explore();
    PreferredSizeWidget? appBar = AppBar(
      title: const Text(Strings.BOOKER, style: TextStyle(color: Colors.white, fontSize: fontSizeLarge)),
      elevation: 0,
    );


    if(!(currentAppUser?.isServiceProvider ?? false)){
      appBar = null;
      body = CustomSliderDrawer(
        appBar: SliderAppBar(
          appBarColor: standartTheme.primaryColor,
          appBarPadding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          appBarHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
          drawerIconColor: Colors.white,
          title: const Text(Strings.BOOKER, style: TextStyle(color: Colors.white, fontSize: fontSizeLarge)),
          trailing: Navigator.canPop(context) ? IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: (){Navigator.pop(context);},
          ) : null,
        ),
        slider: ConfigurationsHome(),
        child: Container(
          color: Colors.white,
          child: body,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: body
    );
  }
}
