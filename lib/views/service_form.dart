import 'package:booker/helper/text_input_formatters.dart';
import 'package:booker/main.dart';
import 'package:booker/models/service_provided.dart';
import 'package:booker/widgets/input_custom.dart';
import 'package:booker/widgets/button_custom.dart';
import 'package:booker/widgets/color_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ServiceForm extends StatefulWidget {

  final ServiceProvided? serviceProvided;

  ServiceForm({this.serviceProvided});

  @override
  _ServiceFormState createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  Color _selectedColor = Colors.blue;

  ServiceProvided _serviceProvided = ServiceProvided();

  final _formKey = GlobalKey<FormState>();

  Future<void> _validateFields() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      await _serviceProvided.updateServiceProvidedInFirestore(context);
      if(widget.serviceProvided != null){
        //to update instantly in the previous page
        widget.serviceProvided!.name = _serviceProvided.name;
        widget.serviceProvided!.description = _serviceProvided.description;
        widget.serviceProvided!.price = _serviceProvided.price;
        widget.serviceProvided!.duration = _serviceProvided.duration;
        widget.serviceProvided!.color = _serviceProvided.color;
      }
      if(mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _deleteConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Tem certeza que deseja excluir esse serviço? Os agendamentos já realizados não serão cancelados, mas os clientes não poderão mais selecionar esse serviço.'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: Text('Voltar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () async {
                await _serviceProvided.deleteServiceProvidedInFirestore(context);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
      _nameController.text = widget.serviceProvided!.name;
      _descriptionController.text = widget.serviceProvided!.description;
      _priceController.text = widget.serviceProvided!.price.toString();
      _durationController.text = widget.serviceProvided!.duration.inMinutes.toString();
      print("widget.serviceProvided!.color = ${widget.serviceProvided!.color}");
      _selectedColor = widget.serviceProvided!.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceProvided == null ? AppLocalizations.of(context)!.service_form_create_service : AppLocalizations.of(context)!.service_form_edit_service)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
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
                  textInputType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [IntegerTextInputFormatter()],
                  onSaved: (durationInMinutes){
                    _serviceProvided.duration = Duration(minutes: (int.tryParse(durationInMinutes ?? "0") ?? 0));
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
                padding: EdgeInsets.only(top: 12, bottom: 8),
                child: Text('Tipo de agendamento para esse serviço:', style: textStyleSmallNormal,),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
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
                  ListTile(
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
                ],
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
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
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
