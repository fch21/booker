import 'package:booker/helper/text_input_formatters.dart';
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
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _durationController = TextEditingController();
  Color _selectedColor = Colors.blue;

  ServiceProvided _serviceProvided = ServiceProvided();

  final _formKey = GlobalKey<FormState>();

  final _decimalInputFormatter = DecimalTextInputFormatter();
  final _integerInputFormatter = IntegerTextInputFormatter();

  _validateFields() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      _serviceProvided.updateServiceProvidedInFirestore(context);
      Navigator.of(context).pop();
    }
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
                    return "required_field";
                  }
                  else{
                    return null;
                  }
                },
              ),
              SizedBox(height: 12),
              InputCustom(
                label: 'Descrição',
                controller: _descriptionController,
                onSaved: (description){
                  _serviceProvided.description = description ?? "";
                },
                validator: (value) {
                  return null;
                },
              ),
              SizedBox(height: 12),
              InputCustom(
                label: 'Preço em R\$',
                controller: _priceController,
                textInputType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_decimalInputFormatter],
                onSaved: (price){
                  _serviceProvided.price = double.tryParse(price?.replaceAll(',','.') ?? "") ?? 0.0;
                },
                validator: (value) {
                  if(value == "" || value == null ){
                    return "required_field";
                  }
                  else{
                    return null;
                  }
                },
              ),
              SizedBox(height: 12),
              InputCustom(
                label: 'Duração (em minutos)',
                controller: _durationController,
                textInputType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_integerInputFormatter],
                onSaved: (durationInMinutes){
                  _serviceProvided.duration = Duration(minutes: (int.tryParse(durationInMinutes ?? "0") ?? 0));
                },
                validator: (value) {
                  if(value == "" || value == null ){
                    return "required_field";
                  }
                  else{
                    return null;
                  }
                },
              ),
              SizedBox(height: 12),
              InkWell(
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
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: ButtonCustom(
                  onPressed: _validateFields,
                  text: 'Salvar Serviço',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
