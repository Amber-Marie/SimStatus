integer timering = 300;//the polling rate, put the speed you wish, in seconds

//there we go...
integer UNIX;
string _buffer;
list log;
integer span = 0;
float fps;
float dilation;
integer crash = 0;
string date;
string right(string src, string divider) {
    integer index = llSubStringIndex( src, divider );
    if(~index)
        return llDeleteSubString( src, 0, index + llStringLength(divider) - 1);
    return src;
}

default
{
    state_entry()
    {
        llSay(0, "Script running");
        //key map = osGetRegionMapTexture(llGetRegionName());
        //llSetTexture(map, 1);
        //key map = osGetMapTexture(llGetRegionName());
        llSetPrimitiveParams([ PRIM_TEXTURE, ALL_SIDES, TEXTURE_TRANSPARENT, <0.0, 0.0, 0.0>, <0.0, 0.0, 0.0>, 0.0 ]); // Make all sides transparent
        //llSetTexture(osGetMapTexture(),1); //This is the back face, facing away from the TP point
        llSetPrimitiveParams([ PRIM_TEXTURE, 1, osGetMapTexture(), <-1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0 ]); //This is the back face, facing away from the TP point. Fliped tomatch front
        llSetPrimitiveParams([ PRIM_TEXTURE, 3, osGetMapTexture(), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0 ]);
        //llSetTexture(osGetMapTexture(),3); // This is the front, facing the TP point
                llSetTimerEvent(timering);//starting our timer
   
    }
        timer()
    {
        
        string simver = (string)osGetSimulatorVersion();
        string value = right(simver, "OSgrid"); //value == "OSgrid"
        
        string timestamp = llGetTimestamp();
        list temp = llParseString2List(timestamp,["T",":",":","."],[]);
        integer _hour = llList2Integer(temp,1) + 4;
        if(_hour > 24) //getting the hours
            _hour = _hour - 24 ;

        string _date = llList2String(temp,0);
        integer _min = llList2Integer(temp,2);
        integer _sec = llList2Integer(temp,3);
        string buffer;

        if(date == _date) //daily reset of the average fps and dilation
            span++;
        else
        {
            span = 1;
            date = _date;
            fps = 0;
            dilation = 0;
        }

        fps += llGetRegionFPS();
        dilation += llGetRegionTimeDilation();
        integer avg_FPS = (integer)(fps/span);
        string avg_dilation= llGetSubString((string)(dilation/span),0,3);

        //buffer += llGetRegionName();
        //buffer += "\n FPS:"+(string)avg_FPS;
        //buffer += " dil. :"+(string)avg_dilation;
        //buffer += "\n" + llDumpList2String(log,"\n");

        integer _UNIX = _sec + _min * 60 + _hour * 3600;//making our timestamp
       
        if (_UNIX - UNIX > timering + 5 && UNIX != 0)//okay the delay has been waaay too olong, it probably crashed or rebooted
        {
            crash++;
            log += (string)_date + " - " + (string)_hour+ ":"+(string)_min+":"+(string)_sec;
            if(llGetListLength(log) > 9)
                log = llDeleteSubList(log,0,0);
        }
        buffer += (string)crash + ". The last crash or restart was " + llDumpList2String(log,"\n");
        if(_buffer != buffer); //display
        {
            // llSetText(buffer,<1,1,1>,1.0);
            llSetText("Welcome to "+ (string)llGetRegionName() + " on " + (string)osGetGridName() + ".\n" + "The sim is running OSgrid " + value + "\n Reported Crashes: " + buffer + "\nTouch an area to TP.",<0,1,0>,1);
            _buffer = buffer;   
        }
        UNIX = _UNIX;
    }

    touch_start(integer num_detected) {

        string simver = (string)osGetSimulatorVersion();
        string value = right(simver, "OSgrid"); //value == "Brown"
        
                list Stats = osGetRegionStats();
        string s = "Sim FPS: " + (string) llList2Float( Stats, STATS_SIM_FPS ) + "\n";
        s += "Physics FPS: " + (string) llList2Float( Stats, STATS_PHYSICS_FPS ) + "\n";
        s += "Time Dilation: " + (string) llList2Float( Stats, STATS_TIME_DILATION ) + "\n";
        s += "Root Agents: " + (string) llList2Integer( Stats, STATS_ROOT_AGENTS ) + "\n";
        s += "Child Agents: " + (string) llList2Integer( Stats, STATS_CHILD_AGENTS ) + "\n";
        s += "Total Prims: " + (string) llList2Integer( Stats, STATS_TOTAL_PRIMS ) + "\n";
        s += "Active Scripts: " + (string) llList2Integer( Stats, STATS_ACTIVE_SCRIPTS ) + "\n";
        s += "Script LPS: " + (string) llList2Float( Stats, STATS_SCRIPT_LPS );
       // llSetText( s, <0.0,1.0,0.0>, 1.0 );
       //llSetText("Welcome to "+ (string)llGetRegionName() + " on " + (string)osGetGridName() + ".\n" + "The sim is running OSgrid " + value + "\n Reported Crashes: " + buffer,<0,1,0>,1);
       
        //string simver = (string)osGetSimulatorVersion();
            //llSetText("Grid Name: " + (string)osGetGridName() + "\n Welcome Page: " + (string)osGetGridCustom("welcome") + "\n Simulator Version: " + (string)osGetSimulatorVersion(),<0,1,0>,1);
            //string value = right(simver), "OpenSim"); //value == "Brown"
             //string value = right("Colour=Brown", "="); //value == "Brown"

            llSay(0,"OSgrid " + value);
 
                       llSay(0, s);
            //Grid Welcome Page = " + osGetGridCustom("welcome"));
                 string data = "\n\n Creation Date: " + osLoadedCreationDate();
        data += "\n Creation Time: " + osLoadedCreationTime();
        data += "\n Creation ID: " + osLoadedCreationID();
        llSay(0, data);  

            // llSetText("Grid Name: " + (string)osGetGridName() + "\n Version: " + (string)osGetSimulatorVersion() + "\n Dilation: " + (string)llGetRegionTimeDilation() + "\n Host: " + (string)llGetSimulatorHostname() + "\n Touch to update...",<0,1,0>,1);
        }

}
