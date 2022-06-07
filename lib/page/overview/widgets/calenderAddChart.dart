




import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_practice/constants/style.dart';
import 'package:flutter_practice/page/overview/widgets/provider_.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../model/chartModel.dart';


class calendarAddChart extends StatefulWidget {
  const calendarAddChart({Key? key}) : super(key: key);

  @override
  State<calendarAddChart> createState() => _calendarAddChartState();
}

class _calendarAddChartState extends State<calendarAddChart> {
  List<ChartData> newTempList=[];
  List<ChartData> newprecipitationList=[];
  List<ChartData> newstationPressureList=[];
  
  List<String> dropButtonItem=['請選擇','每6小時','每12小時','每24小時'];
  String? selectedItem='請選擇';
  List<ChartData> stationPressureList=[];
  List<ChartData> TempList=[];
  List<ChartData> precipitationList=[];
  ZoomPanBehavior Zoom=new  ZoomPanBehavior(
    enableMouseWheelZooming: true,
    enableSelectionZooming: true,
    enablePanning: true,
    maximumZoomLevel: 0.1,
    zoomMode: ZoomMode.x,  
  );
  
  Future loadCalendarData()async{
    final String jsonString = await rootBundle.loadString("jsons/C-B0024-001.json") ;
    final dynamic jsonReponse =jsonDecode(jsonString);

    
    var temp=getCalendarData(jsonReponse,"temp");
    var stationPressure=getCalendarData(jsonReponse,"stationPressure");
    var precipitation=getCalendarData(jsonReponse,"precipitation");

    // var a=-1;

    for(Map<String,dynamic> i in temp  ){
      // a++;
      i['time']=DateTime.parse(i['time']);
      i['time']='${i['time'].month}/${i['time'].day}\n${i['time'].hour}點';
      TempList.add(ChartData.fromJson(i));
    }
    for(Map<String,dynamic> i in stationPressure ){
      i['time']=DateTime.parse(i['time']);
      i['time']='${i['time'].month}/${i['time'].day}\n${i['time'].hour}點';
      stationPressureList.add(ChartData.fromJson(i));
    }
    for(Map<String,dynamic> i in precipitation ){
      i['time']=DateTime.parse(i['time']);
      i['time']='${i['time'].month}/${i['time'].day}\n${i['time'].hour}點';
      precipitationList.add(ChartData.fromJson(i));
    }    
 
  }

   getCalendarData(jsonData,key){
     
     List<Map<String,dynamic>> ListMapData=[];
    var content=jsonData['cwbdata']['resources']['resource']['data']['surfaceObs']['location'][3]['stationObsTimes']['stationObsTime'];
    var dataLenth=content.length;


    var count=0;
    double sum=0;
    for(int i=0 ;i<dataLenth ; i++){
      var time=content[i]['dataTime'];

      if(key =="temp"){
        var temp =double.parse(content[i]['weatherElements']['temperature'])  ;
        sum=sum+temp;
        count++;
        if(count==6){
          sum=sum/6;
          count=0;
        ListMapData.add({"time":time,"value":sum});

        }

        
      }
      if(key =="stationPressure"){
        var stationPressure=double.parse(content[i]['weatherElements']['stationPressure']) ;

          sum=sum+stationPressure;
          count++;
          if(count==6){
            count=0;
            sum=sum/6;
             ListMapData.add({"time":time,"value":sum});
          }
       

      }
      if(key == "precipitation"){
        var precipitation= content[i]['weatherElements']['precipitation'];
        if(precipitation=='T' || precipitation=='0.0'){
          precipitation='0';
        }
        sum=sum+double.parse(precipitation) ;
        count++;
        if(count==6){
          count=0;
          sum=sum/6;
          ListMapData.add({"time":time,"value":sum});
        }
        


        
      }
    }
    return ListMapData;




  }

    @override
    void initState(){
        loadCalendarData();
        super.initState();

    }
  






  @override
  Widget build(BuildContext context) {

    
  double _width=MediaQuery.of(context).size.width;
  double _height=MediaQuery.of(context).size.height;



    return Consumer(builder: ((context,provider Chartdata, child) {



      return Column(
        children: [
          Row(
            children: [

              SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                  disabledHint: Text('$selectedItem'),
                  elevation: 10,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(width: 2,color: Colors.blue)
                    )
                  ),
                  value: selectedItem,
                  items: dropButtonItem
                        .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item,style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),)))
                        .toList(),

                  onChanged: (select){

                    if(select =='每6小時'){
                      
                      for(int i= 0 ;i<TempList.length;i++){
                        newTempList.add(TempList[i]) ;
                        newprecipitationList.add(precipitationList[i]);
                        newstationPressureList.add(stationPressureList[i]);
                      }
                        Zoom.reset() ;
                        Zoom.zoomByRect(Rect.fromLTRB(_width/2+900, _height/2+200, _width, _height/2+200));
                    }
                    if(select =='每12小時'){
                      
                      for(int i= 0 ;i<TempList.length;i=i+2){
                        newTempList.add(TempList[i]) ;
                        newprecipitationList.add(precipitationList[i]);
                        newstationPressureList.add(stationPressureList[i]);
                      }
                        Zoom.reset() ;
                        Zoom.zoomByRect(Rect.fromLTRB(_width/2+600, _height/2+200, _width, _height/2+200));

                    }
                    if(select =='每24小時'){  
                      for(int i= 0 ;i<TempList.length;i=i+4){
                        newTempList.add(TempList[i]) ;
                        newprecipitationList.add(precipitationList[i]);
                        newstationPressureList.add(stationPressureList[i]);
                      }
                        Zoom.reset() ;
                        Zoom.zoomByRect(Rect.fromLTRB(_width/2+300, _height/2+200, _width, _height/2+200));
                    }
                      Chartdata.AddTempData(newTempList);
                      Chartdata.AddStationPressureData(newstationPressureList);
                      Chartdata.AddPrecipitationData(newprecipitationList);
                      newTempList=[];
                      newprecipitationList=[];
                      newstationPressureList=[];


                    setState(() {
                      selectedItem=select;
                    });
                      
                  }),
              ),

              Container(
                margin: EdgeInsets.only(left: 10),
                
                child: Text(
                  '6/7 作業進度加入下拉式選單',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  )),
              )  
              // Container(
              //   margin: EdgeInsets.only(left: 10),
              //   color: Colors.yellow[100],
              //   child: OutlinedButton(
              //     onPressed: (){
              //     Zoom.reset();
              //   }, child: SizedBox(
                          
              //             height: 50,              
              //             child: Center(
              //                 child: Text('顯示大範圍的曲線'),
              //               ))),
              // )
            ],
          ),

  




          Container(
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                offset: Offset(0,6),
                color: lightGrey.withOpacity(0.1),
                blurRadius: 12
              )
            ],
            border: Border.all(color: lightGrey,width: 4)),
           
            child:SfCartesianChart(
              backgroundColor:light ,
              margin: EdgeInsets.symmetric(horizontal: 40),
              plotAreaBackgroundColor: light,
              
              plotAreaBorderColor: Colors.black54,
          
              onLegendTapped: (LegendTapArgs args){
                // Zoom.zoomByRect(Rect.fromLTRB(1000, 0, 0, 0));
                 
                   
              },
                  
              legend:Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                // toggleSeriesVisibility: false
              ) ,
              palette: [Colors.teal,Colors.red,Colors.blue],
              title: ChartTitle(
              text: "過去30天的天氣數據統整",

              borderWidth: 2,
              textStyle: TextStyle(
                    color: Colors.blue[200],
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    )    
              ),

              tooltipBehavior: TooltipBehavior(enable: true),
              zoomPanBehavior:Zoom,        
              primaryYAxis: NumericAxis(
                labelStyle: TextStyle(
                  color: lightGrey,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Roboto',
                  fontSize: 13


                ),
                decimalPlaces: 0,
              ),
              primaryXAxis: CategoryAxis(
                interval: 1,
                labelStyle: TextStyle(
                  color: lightGrey,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Roboto',
                  fontSize: 13
                ),
             
              ),        
                series:<ChartSeries>[        
                LineSeries<ChartData,String>(
                              name: '平均溫度',
                              dataSource:  Chartdata.TempData, 
                              xValueMapper: (ChartData data,_)=>data.time, 
                              yValueMapper: (ChartData data,_)=>data.value,
                              isVisible: true
                            ),     
                LineSeries<ChartData,String>(
                  name: '平均降雨量',
                  dataSource:Chartdata.PrecipitationData,
                  xValueMapper: (ChartData data,_)=>data.time, 
                  yValueMapper: (ChartData data,_)=>data.value,
                  isVisible: false
                  ),
                LineSeries<ChartData,String>(
                  name: '平均氣壓',
                  dataSource: Chartdata.StationPressureData,
                  xValueMapper: (ChartData data,_)=>data.time, 
                  yValueMapper: (ChartData data,_)=>data.value, 
                isVisible: false

                      )            
                    ]
              )   
          ),
        ],
        
      );
        
    }));
  }
}