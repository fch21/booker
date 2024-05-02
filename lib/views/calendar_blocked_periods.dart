import 'package:booker/helper/necessary_subscription_levels.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/period.dart';
import 'package:booker/widgets/blocked_period_card.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarBlockedPeriods extends StatefulWidget {
  //bool showOnlyPastBlockedPeriods;

  CalendarBlockedPeriods({
    Key? key,
    //this.showOnlyPastBlockedPeriods = false,
  }) : super(key: key);

  @override
  State<CalendarBlockedPeriods> createState() => _CalendarBlockedPeriodsState();
}

class _CalendarBlockedPeriodsState extends State<CalendarBlockedPeriods> {

  Future<void> _confirmDeletionDialog(Period blockedPeriod) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Tem certeza que deseja excluir esse período de bloqueio?\nApós a exclusão, os clientes poderão marcar agendamentos normalmente.'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Voltar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red),),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                setState(() {
                  currentAppUser!.blockedPeriods.remove(blockedPeriod);
                });
                await currentAppUser!.updateAppUserInFirestore(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createBlockedPeriod({Period? blockedPeriod}) async {
    // Exibir o SfDateRangePicker para o usuário selecionar um intervalo de datas
    await showDialog(
      context: context,
      builder: (context) {

        DateTime? startDate;
        DateTime? endDate;

        PickerDateRange? initialSelectedRange;
        if(blockedPeriod != null){
          initialSelectedRange = PickerDateRange(blockedPeriod.startDate, blockedPeriod.endDate);
        }

        return AlertDialog(
          title: const Text('Selecione o intervalo de bloqueio'),
          content: SingleChildScrollView(
            child: SizedBox(
              height: 350, // Ajuste conforme necessário
              width: 50,
              child: SfDateRangePicker(
                enablePastDates: false,
                showNavigationArrow: true,
                selectionMode: DateRangePickerSelectionMode.range,
                initialSelectedRange: initialSelectedRange,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is PickerDateRange) {
                    final PickerDateRange range = args.value;
                    print("range startDate= ${range.startDate}");
                    print("range endDate= ${range.endDate}");
                    startDate = range.startDate;
                    endDate = range.endDate;
                  }
                },
                // Personalize o tema conforme necessário
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: (){
                if(startDate != null) {
                  if(startDate!.isBefore(DateTime.now())){
                    Utils.showSnackBar(context, "Intervalo inválido");
                  }
                  else{
                    Navigator.of(context).pop();
                    _confirmAndAddBlockedPeriod(startDate!, endDate, initialBlockedPeriod: blockedPeriod);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAndAddBlockedPeriod(DateTime startDate, DateTime? endDate, {Period? initialBlockedPeriod}) async {
    endDate ??= startDate;
    final bool confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar bloqueio'),
          content: Text(endDate == startDate
              ? 'Você quer bloquear a data ${DateFormat('dd/MM/yyyy').format(startDate)}?\nNessa data, os clientes não poderão marcar agendamentos.'
              : 'Você quer bloquear o período de ${DateFormat('dd/MM/yyyy').format(startDate)} até ${DateFormat('dd/MM/yyyy').format(endDate!)}?\nDurante este período, os clientes não poderão marcar agendamentos.',
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      bool canAccess = await Utils.showSubscriptionNeededDialogIfNecessary(context: context, subscriptionNeeded: NecessarySubscriptionLevels.BLOCK_CALENDAR_PERIOD);
      if(canAccess){
        setState(() {
          if(initialBlockedPeriod != null){
            currentAppUser!.blockedPeriods.remove(initialBlockedPeriod);
          }
          currentAppUser!.blockedPeriods.add(Period(
            startDate: startDate,
            endDate: endDate!.add(const Duration(hours: 23, minutes: 59, seconds: 59)),// we must add one day to include the endDate day in the period
          ));
        });
        await currentAppUser!.updateAppUserInFirestore(context);
      }
    }
  }


  void orderBlockedPeriods(List<Period> blockedPeriods) {
    final now = DateTime.now();
    blockedPeriods.sort((a, b) {
      // Se ambos os períodos estão no futuro ou no passado, ordenamos pela startDate
      if ((a.endDate.isAfter(now) && b.endDate.isAfter(now)) ||
          (a.endDate.isBefore(now) && b.endDate.isBefore(now))) {
        return a.startDate.compareTo(b.startDate);
      }
      // Se um período está no passado e outro no futuro, o período futuro vem primeiro
      if (a.endDate.isBefore(now) && b.endDate.isAfter(now)) {
        return 1;
      }
      if (a.endDate.isAfter(now) && b.endDate.isBefore(now)) {
        return -1;
      }
      return 0;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    bool greaterWidthLayout = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    List<Period> blockedPeriods = currentAppUser!.blockedPeriods;
    orderBlockedPeriods(blockedPeriods);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Períodos bloqueados"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: greaterWidthLayout ? MediaQuery.of(context).size.width/4 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if(blockedPeriods.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 64, bottom: 16),
                child: Center(
                    child: Text("Nenhum período de bloqueio criado", style: textStyleSmallNormal,)
                )
              ),
            if(blockedPeriods.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0), // Adicionado o padding lateral
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: blockedPeriods.length,
                  itemBuilder: (BuildContext context, int index) {

                    Period blockedPeriod = blockedPeriods[index];

                    bool isPastPeriod = DateTime.now().isAfter(blockedPeriod.endDate);

                    return Opacity(
                      opacity: isPastPeriod ? 0.5 : 1.0,
                      child: BlockedPeriodCard(
                        blockedPeriod: blockedPeriod,
                        onTap: isPastPeriod ? (){} : (){
                          _createBlockedPeriod(blockedPeriod: blockedPeriod);
                        },
                        onTapTrailing: (){
                          _confirmDeletionDialog(blockedPeriod);
                        },
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: ButtonCustom(
                text: "Adicionar período",
                onPressed: _createBlockedPeriod,
              ),
            ),
            /*
            Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: Center(
                child: TextButton(
                  onPressed: (){
                    Navigator.pushNamed(context, RouteGenerator.CALENDAR_BLOCKED_PERIOD, arguments: true);
                  },
                  child: const Text("Histórico de periodos bloqueados"),
                ),
              ),
            ),

             */
          ],
        ),
      ),
    );
  }
}
