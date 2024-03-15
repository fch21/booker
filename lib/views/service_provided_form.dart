import 'package:booker/helper/text_input_formatters.dart';
import 'package:booker/main.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/color_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ServiceProvidedForm extends StatefulWidget {

  final ServiceProvided? serviceProvided;

  ServiceProvidedForm({this.serviceProvided});

  @override
  _ServiceProvidedFormState createState() => _ServiceProvidedFormState();
}

class _ServiceProvidedFormState extends State<ServiceProvidedForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _schedulingIntervalController = TextEditingController();
  final TextEditingController _minSchedulingDelayController = TextEditingController();
  final TextEditingController _maxSchedulingDelayController = TextEditingController();
  //final TextEditingController _numberOfPeriodicAppointmentsController = TextEditingController();
  Color _selectedColor = Colors.blue;

  ServiceProvided _serviceProvided = ServiceProvided();

  final _formKey = GlobalKey<FormState>();

  Future<void> _validateFields() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      //to reset the numberOfPeriodicAppointments value if is not a periodic service
      //if(!_serviceProvided.hasPeriodicAppointments && _serviceProvided.numberOfPeriodicAppointments != null){
      //  _serviceProvided.numberOfPeriodicAppointments = null;
      //}

      await _serviceProvided.updateServiceProvidedInFirestore(context);
      if(widget.serviceProvided != null){
        //to update instantly in the previous page
        widget.serviceProvided!.name = _serviceProvided.name;
        widget.serviceProvided!.description = _serviceProvided.description;
        widget.serviceProvided!.price = _serviceProvided.price;
        widget.serviceProvided!.duration = _serviceProvided.duration;
        widget.serviceProvided!.color = _serviceProvided.color;
        //widget.serviceProvided!.hasPeriodicAppointments = _serviceProvided.hasPeriodicAppointments;
        //widget.serviceProvided!.numberOfPeriodicAppointments = _serviceProvided.numberOfPeriodicAppointments;
      }
      if(mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _deleteConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Tem certeza que deseja excluir esse serviço? Os agendamentos já realizados não serão cancelados, mas os clientes não poderão mais selecionar esse serviço.'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Voltar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () async {
                await _serviceProvided.deleteServiceProvidedInFirestore(context);
                if(mounted) Navigator.of(context).pop();
                if(mounted) Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.serviceProvided != null) {
      _serviceProvided = widget.serviceProvided!.copy();
      _nameController.text = _serviceProvided.name;
      _descriptionController.text = _serviceProvided.description;
      _priceController.text = _serviceProvided.price.toString();
      _durationController.text = _serviceProvided.duration.inMinutes.toString();
      //_numberOfPeriodicAppointmentsController.text = (_serviceProvided.numberOfPeriodicAppointments ?? "").toString();
      //print("widget.serviceProvided!.color = ${widget.serviceProvided!.color}");
      _selectedColor = _serviceProvided.color;
    }
    _schedulingIntervalController.text = _serviceProvided.schedulingIntervalInMinutes.toString();
    _minSchedulingDelayController.text = _serviceProvided.minSchedulingDelayInMinutes.toString();
    _maxSchedulingDelayController.text = _serviceProvided.maxSchedulingDelayInDays.toString();
  }

  @override
  Widget build(BuildContext context) {

    bool greaterWidthLayout = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceProvided == null ? AppLocalizations.of(context)!.service_form_create_service : AppLocalizations.of(context)!.service_form_edit_service)),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: greaterWidthLayout ? MediaQuery.of(context).size.width/4 : 16 , vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InputCustom(
                label: 'Nome do Serviço',
                controller: _nameController,
                onSaved: (name){
                  _serviceProvided.name = name ?? "";
                  return;
                },
                validator: (value) {
                  if(value == "" || value == null ){
                    return AppLocalizations.of(context)!.required_field;
                  }
                  else{
                    return null;
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InputCustom(
                  label: 'Descrição',
                  controller: _descriptionController,
                  onSaved: (description){
                    _serviceProvided.description = description ?? "";
                    return;
                  },
                  validator: (value) {
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InputCustom(
                  label: 'Preço em R\$',
                  controller: _priceController,
                  textInputType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [DecimalTextInputFormatter()],
                  onSaved: (price){
                    _serviceProvided.price = double.tryParse(price?.replaceAll(',','.') ?? "") ?? 0.0;
                    return;
                  },
                  validator: (value) {
                    if(value == "" || value == null ){
                      return AppLocalizations.of(context)!.required_field;
                    }
                    else{
                      return null;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InputCustom(
                  label: 'Duração (em minutos)',
                  controller: _durationController,
                  textInputType: const TextInputType.numberWithOptions(),
                  inputFormatters: [IntegerTextInputFormatter()],
                  onSaved: (durationInMinutes){
                    _serviceProvided.duration = Duration(minutes: (int.tryParse(durationInMinutes ?? "0") ?? 0));
                    return;
                  },
                  validator: (value) {
                    if(value == "" || value == null ){
                      return AppLocalizations.of(context)!.required_field;
                    }
                    else{
                      return null;
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Intervalo entre as opções de agendamento (em minutos):', style: textStyleVerySmallNormal,),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InputCustom(
                  label: '',
                  controller: _schedulingIntervalController,
                  textInputType: const TextInputType.numberWithOptions(),
                  inputFormatters: [IntegerTextInputFormatter()],
                  onSaved: (durationInMinutes){
                    _serviceProvided.schedulingIntervalInMinutes = int.tryParse(durationInMinutes ?? "10") ?? 10;
                    return;
                  },
                  validator: (value) {
                    if(value == "" || value == null ){
                      return AppLocalizations.of(context)!.required_field;
                    }
                    else{
                      return null;
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Antecedência mínima para agendamento (em minutos):', style: textStyleVerySmallNormal,),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InputCustom(
                  label: '',
                  controller: _minSchedulingDelayController,
                  textInputType: const TextInputType.numberWithOptions(),
                  inputFormatters: [IntegerTextInputFormatter()],
                  onSaved: (durationInMinutes){
                    _serviceProvided.minSchedulingDelayInMinutes = int.tryParse(durationInMinutes ?? "30") ?? 30;
                    return;
                  },
                  validator: (value) {
                    if(value == "" || value == null ){
                      return AppLocalizations.of(context)!.required_field;
                    }
                    else{
                      return null;
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Período visível da sua agenda para o cliente (em dias):', style: textStyleVerySmallNormal,),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InputCustom(
                  label: '',
                  controller: _maxSchedulingDelayController,
                  textInputType: const TextInputType.numberWithOptions(),
                  inputFormatters: [IntegerTextInputFormatter()],
                  onSaved: (value){
                    _serviceProvided.maxSchedulingDelayInDays = int.tryParse(value ?? "30") ?? 30;
                    return;
                  },
                  validator: (value) {
                    if(value == "" || value == null ){
                      return AppLocalizations.of(context)!.required_field;
                    }
                    else{
                      return null;
                    }
                  },
                ),
              ),
              /*
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 8),
                child: Text('Tipo de agendamento para esse serviço:', style: textStyleSmallNormal,),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Opacity(
                    opacity: _serviceProvided.hasPeriodicAppointments ? 0.5 : 1.0,
                    child: ListTile(
                      leading: Radio<bool>(
                        activeColor: standartTheme.primaryColor,
                        value: false,
                        groupValue: _serviceProvided.hasPeriodicAppointments,
                        onChanged: (bool? value) {
                          setState(() {
                            _serviceProvided.hasPeriodicAppointments = value!;
                          });
                        },
                      ),
                      title: const Text('Agendamento único'),
                    ),
                  ),
                  Opacity(
                    opacity: _serviceProvided.hasPeriodicAppointments ? 1.0 : 0.5,
                    child: ListTile(
                      leading: Radio<bool>(
                        activeColor: standartTheme.primaryColor,
                        value: true,
                        groupValue: _serviceProvided.hasPeriodicAppointments,
                        onChanged: (bool? value) {
                          setState(() {
                            _serviceProvided.hasPeriodicAppointments = value!;
                          });
                        },
                      ),
                      title: const Text('Agendamento Periódico\n(Se repete todas as semanas no mesmo horário)'),
                    ),
                  ),
                  if(_serviceProvided.hasPeriodicAppointments)
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 16, bottom: 12),
                          child: Text('Configurações de Agendamento Periódico:', style: textStyleSmallNormal,),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Opacity(
                            opacity: _serviceProvided.numberOfPeriodicAppointments != null ? 1.0 : 0.5,
                            child: ListTile(
                              leading: Radio<bool>(
                                activeColor: standartTheme.primaryColor,
                                value: true,
                                groupValue: _serviceProvided.numberOfPeriodicAppointments != null,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _serviceProvided.numberOfPeriodicAppointments = int.tryParse(_numberOfPeriodicAppointmentsController.text) ?? 0;
                                  });
                                },
                              ),
                              title: AbsorbPointer(
                                absorbing: _serviceProvided.numberOfPeriodicAppointments == null,
                                child: InputCustom(
                                  label: 'Número de vezes:',
                                  controller: _numberOfPeriodicAppointmentsController,
                                  textInputType: const TextInputType.numberWithOptions(),
                                  inputFormatters: [IntegerTextInputFormatter()],
                                  //onSaved: (value){}, //done in Radio onChanged
                                  onChanged: (value){
                                    setState(() {
                                      _serviceProvided.numberOfPeriodicAppointments = int.tryParse(_numberOfPeriodicAppointmentsController.text) ?? 0;
                                    });
                                  },
                                  validator: (value) {
                                    if(_serviceProvided.numberOfPeriodicAppointments != null){
                                      if(value == "" || value == null ){
                                        return AppLocalizations.of(context)!.required_field;
                                      }
                                      else if((int.tryParse(value) ?? 0) <= 1){
                                        return "Número inválido (deve ser maior que 1)";
                                      }
                                      else{
                                        return null;
                                      }
                                    }
                                  },
                                ),
                              )
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Opacity(
                            opacity: _serviceProvided.numberOfPeriodicAppointments == null ? 1.0 : 0.5,
                            child: ListTile(
                              leading: Radio<bool>(
                                activeColor: standartTheme.primaryColor,
                                value: true,
                                groupValue: _serviceProvided.numberOfPeriodicAppointments == null,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _serviceProvided.numberOfPeriodicAppointments = null;
                                  });
                                },
                              ),
                              title: const Text('Repetir indefinidamente'),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

               */
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Cor que os agendamentos desse serviço vão ter no seu calendário:', style: textStyleVerySmallNormal,),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InkWell(
                  onTap: () async {
                    Color? color = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ColorPickerDialog(initialColor: _selectedColor);
                      },
                    );
                    print("cor = $color");
                    if (color != null) {
                      setState(() {
                        _selectedColor = color;
                        _serviceProvided.color = _selectedColor;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('Escolher Cor', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.65)),),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              borderRadius: BorderRadius.circular(4.0),  // Bordas arredondadas
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.chevron_right, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: ButtonCustom(
                  onPressed: _validateFields,
                  text: 'Salvar Serviço',
                ),
              ),
              if(widget.serviceProvided != null)
                Padding(
                  padding: const EdgeInsets.only(top: 48.0),
                  child: Center(
                    child: TextButton(
                      onPressed: _deleteConfirmationDialog,
                      child: const Text('Excluir serviço', style: TextStyle(color: Colors.red, fontSize: fontSizeVerySmall),),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
