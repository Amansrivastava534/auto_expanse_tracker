import 'package:flutter/material.dart';
import 'package:sms_tracker1/components/customScaffold.dart';
import 'package:sms_tracker1/constants.dart';

import '../components/customSaveButton.dart';
import '../services/pdfReport.dart';
import '../utils.dart';

class GenerateReport extends StatefulWidget {
  const GenerateReport({super.key});

  @override
  State<GenerateReport> createState() => _GenerateReportState();
}

class _GenerateReportState extends State<GenerateReport> {
  String? dropdownvalue = "All";
  String? selectFileType;

  List<String> fileTypeList = [
    "PDF","EXCEL"
  ];

  @override
  void initState() {
    // TODO: implement initState
    dropdownvalue = months.first;
    selectFileType = fileTypeList.first;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        title: "Report",
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Select Month:"),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color:Colors.grey.shade400)
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: dropdownvalue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize:20,
                    elevation: 2,
                    // focusNode: pageData.f4,
                    onChanged: (s){
                      setState(() {
                        dropdownvalue= s;
                      });
                    },
                    items: months.map((String item){
                      return DropdownMenuItem(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(item,softWrap: true,style: TextStyle(color: Colors.black),),
                          ),value: item);
                    }).toList(),
                  ),
                ),
              ),


              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Select File type:"),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(color:Colors.grey.shade400)
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectFileType,
                    icon: Icon(Icons.arrow_downward),
                    iconSize:20,
                    elevation: 2,
                    // focusNode: pageData.f4,
                    onChanged: (s){
                      setState(() {
                        selectFileType= s;
                      });
                    },
                    items: fileTypeList.map((String item){
                      return DropdownMenuItem(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(item,softWrap: true,style: TextStyle(color: Colors.black),),
                          ),value: item);
                    }).toList(),
                  ),
                ),
              ),
            ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GradientButton(
              onPressed:()async{
                Navigator.pop(context);
              },
              cancelButton: true,
              label: "BACK",
            ),
            GradientButton(
              onPressed: () async {
                int month = months.indexWhere((value) => value == dropdownvalue) - 1;
                if(selectFileType == fileTypeList.first){
                  await generatePDFReport([]);
                }else {
                  await generateExcel(context,month);
                }
              } ,
              label: "GENERATE",
            ),
          ],
        ),
      ),
    );
  }
}
