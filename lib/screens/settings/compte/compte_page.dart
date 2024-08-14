// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_interpolation_to_compose_strings

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/settings/compte/image_piker.dart';
import 'package:flutter_application_stage_project/screens/settings/settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/shared/config.dart';
import '../../../models/profil/Profile.dart';
import '../../../providers/langue_provider.dart';
import '../../../services/ApiGetProfile.dart';
import '../../loading.dart';

class ComptePage extends StatefulWidget {
  const ComptePage({Key? key}) : super(key: key);

  @override
  State<ComptePage> createState() => _ComptePageState();
}

class _ComptePageState extends State<ComptePage> {
  Uint8List? _image;
  Map<String, dynamic> fieldValues = {};
  final TextEditingController myController = TextEditingController();
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 100, maxWidth: 100);
    if (pickedImage != null) {
      setState(() {
        _imageFile = pickedImage;
      });
      final imageBytes = await _imageFile!.readAsBytes();
      String fileName = _imageFile!.path.split('/').last;
      setState(() {
        fieldValues["field[39]"] =
            MultipartFile.fromBytes(imageBytes, filename: fileName);
        isFormEdited = true;
      });

      log(fieldValues.toString());
    }
  }

  late String _imageUrl;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchProfile();
    _loadImageUrl();
  }

  Future<void> _loadImageUrl() async {
    try {
      _imageUrl = await Config.getApiUrl("urlImage");
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load image URL: $e')),
        );
      }
    }
  }

  Profile? _profile;
  Future<void> fetchProfile() async {
    try {
      Profile profileResponse = await ApiProfil.getProfil();
      log(profileResponse.toString());

      setState(() {
        _profile = profileResponse;
        loading = false;
      });
      log(_profile.toString());
      if (_profile!.avatar.label.length > 1) {
        fieldValues["field[39]"] = _profile!.avatar.label;
      }
      if (_profile!.email.label.isNotEmpty) {
        email.text = _profile!.email.label;
      }
      if (_profile!.name.label.isNotEmpty) {
        name.text = _profile!.name.label;
        fieldValues["field[33]"] = _profile!.name.label;
      }
      if (_profile!.phone_number.label != []) {
        for (String number in _profile!.phone_number.label) {
          if (!number.contains('+')) {
            phone.text = number;

            break;
          }
        }

        log("phone ====" + phone.text);

        _convertPhoneCode();
      }
    } catch (e) {
      print('Failed to fetch Profile: $e');
    }
  }

  String? validateEmail(String? value) {
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(pattern);
    if (value == null || !regExp.hasMatch(value)) {
      return AppLocalizations.of(context)!.enterValidEmail;
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.fieldRequired;
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.fieldRequired;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.fieldRequired;
    }
    return null;
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  bool loading = true;
  final Map<String, String> phoneCodeToCountryCode = {
    '+1': 'US',
    '+1-264': 'AI',
    '+1-268': 'AG',
    '+1-284': 'VG',
    '+1-340': 'VI',
    '+1-345': 'KY',
    '+1-441': 'BM',
    '+1-473': 'GD',
    '+1-649': 'TC',
    '+1-664': 'MS',
    '+1-670': 'MP',
    '+1-671': 'GU',
    '+1-684': 'AS',
    '+1-758': 'LC',
    '+1-767': 'DM',
    '+1-784': 'VC',
    '+1-787': 'PR',
    '+1-809': 'DO',
    '+1-829': 'DO',
    '+1-849': 'DO',
    '+1-868': 'TT',
    '+1-869': 'KN',
    '+1-876': 'JM',
    '+7': 'RU',
    '+7-6': 'KZ',
    '+20': 'EG',
    '+27': 'ZA',
    '+30': 'GR',
    '+31': 'NL',
    '+32': 'BE',
    '+33': 'FR',
    '+34': 'ES',
    '+36': 'HU',
    '+39': 'IT',
    '+40': 'RO',
    '+41': 'CH',
    '+43': 'AT',
    '+44': 'GB',
    '+45': 'DK',
    '+46': 'SE',
    '+47': 'NO',
    '+48': 'PL',
    '+49': 'DE',
    '+51': 'PE',
    '+52': 'MX',
    '+53': 'CU',
    '+54': 'AR',
    '+55': 'BR',
    '+56': 'CL',
    '+57': 'CO',
    '+58': 'VE',
    '+60': 'MY',
    '+61': 'AU',
    '+62': 'ID',
    '+63': 'PH',
    '+64': 'NZ',
    '+65': 'SG',
    '+66': 'TH',
    '+81': 'JP',
    '+82': 'KR',
    '+84': 'VN',
    '+86': 'CN',
    '+90': 'TR',
    '+91': 'IN',
    '+92': 'PK',
    '+93': 'AF',
    '+94': 'LK',
    '+95': 'MM',
    '+98': 'IR',
    '+212': 'MA',
    '+213': 'DZ',
    '+216': 'TN',
    '+218': 'LY',
    '+220': 'GM',
    '+221': 'SN',
    '+222': 'MR',
    '+223': 'ML',
    '+224': 'GN',
    '+225': 'CI',
    '+226': 'BF',
    '+227': 'NE',
    '+228': 'TG',
    '+229': 'BJ',
    '+230': 'MU',
    '+231': 'LR',
    '+232': 'SL',
    '+233': 'GH',
    '+234': 'NG',
    '+235': 'TD',
    '+236': 'CF',
    '+237': 'CM',
    '+238': 'CV',
    '+239': 'ST',
    '+240': 'GQ',
    '+241': 'GA',
    '+242': 'CG',
    '+243': 'CD',
    '+244': 'AO',
    '+245': 'GW',
    '+246': 'IO',
    '+248': 'SC',
    '+249': 'SD',
    '+250': 'RW',
    '+251': 'ET',
    '+252': 'SO',
    '+253': 'DJ',
    '+254': 'KE',
    '+255': 'TZ',
    '+256': 'UG',
    '+257': 'BI',
    '+258': 'MZ',
    '+260': 'ZM',
    '+261': 'MG',
    '+262': 'RE',
    '+262': 'YT',
    '+263': 'ZW',
    '+264': 'NA',
    '+265': 'MW',
    '+266': 'LS',
    '+267': 'BW',
    '+268': 'SZ',
    '+269': 'KM',
    '+290': 'SH',
    '+291': 'ER',
    '+297': 'AW',
    '+298': 'FO',
    '+299': 'GL',
    '+350': 'GI',
    '+351': 'PT',
    '+352': 'LU',
    '+353': 'IE',
    '+354': 'IS',
    '+355': 'AL',
    '+356': 'MT',
    '+357': 'CY',
    '+358': 'FI',
    '+359': 'BG',
    '+370': 'LT',
    '+371': 'LV',
    '+372': 'EE',
    '+373': 'MD',
    '+374': 'AM',
    '+375': 'BY',
    '+376': 'AD',
    '+377': 'MC',
    '+378': 'SM',
    '+380': 'UA',
    '+381': 'RS',
    '+382': 'ME',
    '+383': 'XK',
    '+385': 'HR',
    '+386': 'SI',
    '+387': 'BA',
    '+389': 'MK',
    '+420': 'CZ',
    '+421': 'SK',
    '+423': 'LI',
    '+500': 'FK',
    '+501': 'BZ',
    '+502': 'GT',
    '+503': 'SV',
    '+504': 'HN',
    '+505': 'NI',
    '+506': 'CR',
    '+507': 'PA',
    '+508': 'PM',
    '+509': 'HT',
    '+590': 'GP',
    '+591': 'BO',
    '+592': 'GY',
    '+593': 'EC',
    '+594': 'GF',
    '+595': 'PY',
    '+596': 'MQ',
    '+597': 'SR',
    '+598': 'UY',
    '+599': 'CW',
    '+670': 'TL',
    '+672': 'NF',
    '+673': 'BN',
    '+674': 'NR',
    '+675': 'PG',
    '+676': 'TO',
    '+677': 'SB',
    '+678': 'VU',
    '+679': 'FJ',
    '+680': 'PW',
    '+681': 'WF',
    '+682': 'CK',
    '+683': 'NU',
    '+685': 'WS',
    '+686': 'KI',
    '+687': 'NC',
    '+688': 'TV',
    '+689': 'PF',
    '+690': 'TK',
    '+691': 'FM',
    '+692': 'MH',
    '+850': 'KP',
    '+852': 'HK',
    '+853': 'MO',
    '+855': 'KH',
    '+856': 'LA',
    '+880': 'BD',
    '+886': 'TW',
    '+960': 'MV',
    '+961': 'LB',
    '+962': 'JO',
    '+963': 'SY',
    '+964': 'IQ',
    '+965': 'KW',
    '+966': 'SA',
    '+967': 'YE',
    '+968': 'OM',
    '+970': 'PS',
    '+971': 'AE',
    '+972': 'IL',
    '+973': 'BH',
    '+974': 'QA',
    '+975': 'BT',
    '+976': 'MN',
    '+977': 'NP',
    '+992': 'TJ',
    '+993': 'TM',
    '+994': 'AZ',
    '+995': 'GE',
    '+996': 'KG',
    '+998': 'UZ',
    '+1242': 'BS',
    '+1246': 'BB',
    '+1264': 'AI',
    '+1268': 'AG',
    '+1284': 'VG',
    '+1340': 'VI',
    '+1345': 'KY',
    '+1441': 'BM',
    '+1473': 'GD',
    '+1649': 'TC',
    '+1664': 'MS',
    '+1670': 'MP',
    '+1671': 'GU',
    '+1684': 'AS',
    '+1758': 'LC',
    '+1767': 'DM',
    '+1784': 'VC',
    '+1787': 'PR',
    '+1809': 'DO',
    '+1829': 'DO',
    '+1849': 'DO',
    '+1868': 'TT',
    '+1869': 'KN',
    '+1876': 'JM',
    '+1939': 'PR'
  };

  String _resultCountryCode = '';
  String phoneCode = "";

  void _convertPhoneCode() {
    setState(() {
      phoneCode = _getPhoneCode(_profile!.phone_number.label);
      _resultCountryCode = phoneCodeToCountryCode[phoneCode] ?? "TN";
      fieldValues["field[40][0]"] = phoneCode;
      fieldValues["field[40][1]"] = phone.text;
    });
    log("phone number" + fieldValues.toString());
    log("result code***************** =" + _resultCountryCode);
  }

  String _getPhoneCode(List<dynamic> phoneNumbers) {
    for (String number in phoneNumbers) {
      if (number.startsWith('+')) {
        return number;
      }
    }
    return '+216'; // Default to Tunisia code if no phone code is found
  }

  String countryCode = "";
  String countryName = "";
  bool isFormEdited = false;

  @override
  Widget build(BuildContext context) {
    final providerLangue = Provider.of<LangueProvider>(context);
    log(providerLangue.locale.toString() + "***************************");
    return loading
        ? Scaffold(
            body: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context).myaccount),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SizedBox(
                              width: 200,
                              height: 100,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Center(
                                      child: _imageFile != null
                                          ? CircleAvatar(
                                              radius: 50,
                                              backgroundImage: FileImage(
                                                  File(_imageFile!.path)),
                                            )
                                          : _profile!.avatar.label.length == 1
                                              ? CircleAvatar(
                                                  backgroundColor: Colors
                                                      .blue, // Choisissez une couleur de fond appropriée
                                                  child: Text(
                                                    _profile!.avatar.label,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            50), // Choisissez une couleur de texte appropriée
                                                  ),
                                                  radius: 50,
                                                )
                                              : CircleAvatar(
                                                  radius: 50,
                                                  backgroundImage: NetworkImage(
                                                      "$_imageUrl//${_profile!.avatar.label}"),
                                                ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -10,
                                    left: 130,
                                    child: IconButton(
                                      onPressed: _pickImage,
                                      icon: Icon(
                                        Icons.add_a_photo_rounded,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            onChanged: (value) {
                              setState(() {
                                isFormEdited = true;
                              });
                              log("isFormEdited telephone:" +
                                  isFormEdited.toString());
                            },
                            controller: name,
                            decoration: InputDecoration(
                              hintText: "Nom et prénom",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Color.fromARGB(255, 46, 90, 249)
                                  .withOpacity(0.1),
                              filled: true,
                              prefixIcon: const Icon(
                                Icons.person,
                              ),
                            ),
                            validator: validateName,
                          ),
                          SizedBox(height: 30),
                          TextFormField(
                            readOnly: true,
                            controller: email,
                            decoration: InputDecoration(
                              hintText: "Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Color.fromARGB(255, 15, 65, 245)
                                  .withOpacity(0.1),
                              filled: true,
                              prefixIcon: const Icon(
                                Icons.mail,
                              ),
                            ),
                            validator: validateEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 30),
                          IntlPhoneField(
                            initialCountryCode: _resultCountryCode,
                            controller: phone,
                            decoration: InputDecoration(
                              hintText: "Téléphone",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Color.fromARGB(255, 15, 65, 245)
                                  .withOpacity(0.1),
                              filled: true,
                              prefixIcon: const Icon(
                                Icons.phone,
                              ),
                            ),
                            languageCode: providerLangue.localeString,
                            onChanged: (phone) {
                              log(phone.countryCode);
                              setState(() {
                                countryCode = phone.countryCode;

                                isFormEdited = true;
                              });
                            },
                            onCountryChanged: (country) {
                              setState(() {
                                countryName = country.code;
                                isFormEdited = true;
                              });
                              log('Country changed to: ' + country.code);
                            },
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: isFormEdited
                                ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        loading = true;
                                      });
                                      log("formulaire validé");
                                      log(email.text);
                                      log(phone.text);
                                      log(name.text);

                                      fieldValues["field[33]"] = name.text;
                                      fieldValues["field[40][1]"] = [
                                        phone.text,
                                      ];
                                      fieldValues["field[40][0]"] =
                                          countryCode == ""
                                              ? phoneCode
                                              : countryCode;

                                      log("dans buttons " +
                                          fieldValues.toString());

                                      try {
                                        final profileModify =
                                            await ApiProfil.modifyProfile(
                                                fieldValues);
                                        setState(() {
                                          loading = false;
                                          _resultCountryCode = countryName;
                                        });
                                        if (profileModify == 200) {
                                          //fetchProfile();
                                          // ignore: use_build_context_synchronously
                                          Navigator.pushAndRemoveUntil<dynamic>(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) =>
                                                  Settings(),
                                            ),
                                            (route) =>
                                                false, //if you want to disable back feature set to false
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.green,
                                              action: SnackBarAction(
                                                  label: "Ok",
                                                  onPressed: () {}),
                                              content: Text(
                                                  'Profile modifier avec succès !'),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        print("Error $e");
                                      }
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 16),
                              backgroundColor:
                                  Color.fromARGB(255, 228, 246, 250),
                            ),
                            child: Text(
                              AppLocalizations.of(context).save,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 40, 5, 243),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
