// Copyright (c) 2017 Amber-Marie Tracey @ OSgrid / AmberMarieTracey @ SecondLife
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense copies of the
// Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
integer timering = 300; //Define the global integer variable for the polling rate, put the speed you wish, in seconds
integer UNIX; // Define the global integer variable for times
string _buffer; // Define the global string variable for the display output
list log; // Define the global list variable for holding the dates for reboots or crashes
integer span = 0; // Define the global integer variable for the number of days the record spans
float fps; // Define the global float variable for the sims frame per second
float dilation; // Define the global float variable for the sims dilation
integer crash = 0; //Define the global integer variable for the number of crashes
string date; // Define the global string variable for the date of the crashes

string right(string src, string divider) {
    integer index = llSubStringIndex( src, divider );
    if(~index)
        return llDeleteSubString( src, 0, index + llStringLength(divider) - 1);
    return src;
}

default
{
    // reset script when the object is rezzed
    on_rez(integer start_param)
    {
        // This has been addded to do away with the need to have a texture in the prim
        llSetPrimitiveParams([ PRIM_TEXTURE, ALL_SIDES, TEXTURE_TRANSPARENT, <0.0, 0.0, 0.0>, <0.0, 0.0, 0.0>, 0.0 ]); // Make all sides transparent
        llResetScript();
    }

    changed(integer change)
    {
        // reset script when the owner or the inventory changed
        if (change & (CHANGED_OWNER | CHANGED_INVENTORY))
        {
            // This has been addded to do away with the need to have a texture in the prim
            llSetPrimitiveParams([ PRIM_TEXTURE, ALL_SIDES, TEXTURE_TRANSPARENT, <0.0, 0.0, 0.0>, <0.0, 0.0, 0.0>, 0.0 ]); // Make all sides transparent
            llResetScript();
        }
    }

    state_entry()
    {
        llSay(0, "Sim Status Script Running");
        llSetPrimitiveParams([ PRIM_TEXTURE, ALL_SIDES, TEXTURE_TRANSPARENT, <0.0, 0.0, 0.0>, <0.0, 0.0, 0.0>, 0.0 ]); // Make all sides transparent
        llSetPrimitiveParams([ PRIM_TEXTURE, 1, osGetMapTexture(), <-1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0 ]); // This is the back face, facing away from the TP point. Fliped to match
        llSetPrimitiveParams([ PRIM_TEXTURE, 3, osGetMapTexture(), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0 ]); // This is the front of our prim
        llSetTimerEvent(timering); // starting the timer using the contents of 'timering'
    }
    
    timer()
    {
        string simver = (string)osGetSimulatorVersion(); // Set the local string variable to the version of software being used
        string value = right(simver, "OSgrid"); // Set the local string variable to the actual version number we are using
        string timestamp = llGetTimestamp(); // Set the local string variable to the current time
        list temp = llParseString2List(timestamp,["T",":",":","."],[]); // Set the local list to all the elements of the time stamp
        integer _hour = llList2Integer(temp,1) + 4; // Set the local integer to the hours
        if(_hour > 24) //getting the hours
            _hour = _hour - 24 ;
        string _date = llList2String(temp,0); // Set the local string to the date
        integer _min = llList2Integer(temp,2); // Set the local integer to the number of minutes
        integer _sec = llList2Integer(temp,3); // Set the local integer to the number of seconds
        string buffer; // Define the local string for the display output

        if(date == _date) //daily reset of the average fps and dilation
            span++;
        else
        {
            span = 1;
            date = _date;
            fps = 0;
            dilation = 0;
        }

        fps += llGetRegionFPS(); // Read and set the frames per second
        dilation += llGetRegionTimeDilation(); // Read and set the sim dilation
        integer avg_FPS = (integer)(fps/span); // Define the local integer for the average frames per second based on date
        string avg_dilation= llGetSubString((string)(dilation/span),0,3); // define the local string for the average dilation based on date

        integer _UNIX = _sec + _min * 60 + _hour * 3600; // Define and set the local integer to our current timestamp
       
        if (_UNIX - UNIX > timering + 5 && UNIX != 0)  // The delay has been waaay too long, it probably crashed or rebooted
        {
            crash++;
            log += (string)_date + " - " + (string)_hour+ ":"+(string)_min+":"+(string)_sec;
            if(llGetListLength(log) > 9)
                log = llDeleteSubList(log,0,0);
        }
        buffer += (string)crash + ". The last crash or restart was " + llDumpList2String(log,"\n");
        if(_buffer != buffer); // Check on what the buffer is displaying
        {
            llSetText(buffer,<1,1,1>,1.0);
            llSetText("Welcome to "+ (string)llGetRegionName() + " on " + (string)osGetGridName() + ".\n" + "The sim is running OSgrid " + value + "\n Reported Crashes: " + buffer,<0,1,0>,1);
            _buffer = buffer;   
        }
        UNIX = _UNIX;
    }

    touch_start(integer num_detected)
    {
        // This section will report more details when the map is clicked
        string simver = (string)osGetSimulatorVersion(); // Define the local string variable which containes the version information
        string value = right(simver, "OSgrid"); // Define and set the local string variable  to get the version number
        list Stats = osGetRegionStats(); // Define and set the local list where the stats will be stored
        string s = "\nSim FPS: " + (string) llList2Float( Stats, STATS_SIM_FPS ) + "\n"; // Define and set the local string that the information will be put into
        s += "Physics FPS: " + (string) llList2Float( Stats, STATS_PHYSICS_FPS ) + "\n";
        s += "Time Dilation: " + (string) llList2Float( Stats, STATS_TIME_DILATION ) + "\n";
        s += "Root Agents: " + (string) llList2Integer( Stats, STATS_ROOT_AGENTS ) + "\n";
        s += "Child Agents: " + (string) llList2Integer( Stats, STATS_CHILD_AGENTS ) + "\n";
        s += "Total Prims: " + (string) llList2Integer( Stats, STATS_TOTAL_PRIMS ) + "\n";
        s += "Active Scripts: " + (string) llList2Integer( Stats, STATS_ACTIVE_SCRIPTS ) + "\n";
        s += "Script LPS: " + (string) llList2Float( Stats, STATS_SCRIPT_LPS );
        llSay(0,(string)osGetGridName() + " " + value);; // Use the set grid name, and then the version from the server software
        llSay(0, s + "\n"); // Display the full list of stats
        string data = "\n Creation Date: " + osLoadedCreationDate(); // Define the local string variable to hold the sim creation details
        data += "\n Creation Time: " + osLoadedCreationTime();
        data += "\n Creation ID: " + osLoadedCreationID();
        llSay(0, data);  
        }
}
