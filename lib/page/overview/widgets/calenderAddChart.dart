




import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_practice/constants/style.dart';
import 'package:flutter_practice/page/overview/widgets/provider_.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/chartModel.dart';
import 'calendar.dart';

class calendarAddChart extends StatefulWidget {
  const calendarAddChart({Key? key}) : super(key: key);

  @override
  State<calendarAddChart> createState() => _calendarAddChartState();
}

class _calendarAddChartState extends State<calendarAddChart> {


  List<ChartData> stationPressureList=[];
  List<ChartData> TempList=[];
  List<ChartData> precipitationList=[];
  ZoomPanBehavior Zoom=new  ZoomPanBehavior();
    
  Future loadCalendarData()async{
    final String jsonString = await rootBundle.loadString("jsons/C-B0024-001.json") ;
    final dynamic jsonReponse =jsonDecode(jsonString);

    
    var temp=getCalendarData(jsonReponse,"temp");
    var stationPressure=getCalendarData(jsonReponse,"stationPressure");
    var precipitation=getCalendarData(jsonReponse,"precipitation");

    // var a=-1;

    for(Map<String,dynamic> i in temp ){
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
  provider myprovider =Provider.of<provider>(context);
  myprovider.AddPrecipitationData(precipitationList);
  myprovider.AddStationPressureData(stationPressureList);
  myprovider.AddTempData(TempList);

    return Consumer(builder: ((context,provider Chartdata, child) {











      return Container(
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
            Zoom.reset();         
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
          zoomPanBehavior:Zoom=new  ZoomPanBehavior(
            enableMouseWheelZooming: true,
            enableSelectionZooming: true,
            enablePanning: true,
            maximumZoomLevel: 0.3
            
          ),                
        
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
            interval: 20,
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
      );

    }));
  }
}