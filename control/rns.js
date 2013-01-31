

Control.ui = { blockSize: 0.085, 
  sliderY: 0.72, 
  xstart    : 0.05,
  ystart    : 0.05,
  trackSelectPrefix : "trackSelect",

  horizOffset : function(num) {
    return( (this.buttonW + this.gapSize ) * num );
  },

vertOffset : function(num) {
               return( (this.buttonH + this.gapSize ) *num );
             },


resetButton : function(x, y) {  return( {
                  "name": "songReset",
                  "type": "Button",
                  "label": "<b>&lt;&lt;&lt;</b>",
                  "bounds": [x, y,  this.buttonW, this.buttonH ],
                  "color": "#000",
                  "backgroundColor": "#d97a0e",
                  "stroke": "#333",
                  "mode":"momentary",
                  "ontouchstart": "oscManager.sendOSC( ['/renoise/song/reset']); ",
                  } );
              },


bpmSlider : function(x, y) { return( {
                "name": "songBpm" ,
                "type": "Slider",
                "bounds": [x, y, (this.buttonW + this.gapSize) * Control.renoise.numOfTracks - Control.ui.gapSize, Control.ui.buttonH],
                "startingValue": 80,
                "color": "#0F3",
                "stroke": "#333",
                "backgroundColor": "#339",
                "min": 40,
                "max": 200,
                "label" : "bpm",
                "isVertical": false,
                "onvaluechange": "oscManager.sendOSC( [ '/renoise/song/bpm2',  'i', Math.round(this.value) ])",      
                }  ); 
            },

keyboardButton : function(idx, x, y) { return( {
                     "name":  "jgbNote" + idx,
                     "type": "Button",
                     "label": Control.renoise.notes[idx],
                     "bounds": [ x, y,  this.buttonW, this.buttonH],
                     "color": "#F33",
                     "backgroundColor": "#F0F",
                     "stroke": "#333",
                     "mode":"momentary",
                     "ontouchstart": "oscManager.sendOSC( [ '/renoise/trigger/note_on',  'iiii', Control.renoise.currentTrack, Control.renoise.currentInstrument, " + Control.renoise.midiNotes[idx] + ", 125])",
                     "ontouchend":   "oscManager.sendOSC( [ '/renoise/trigger/note_off', 'iii',  Control.renoise.currentTrack, Control.renoise.currentInstrument " + Control.renoise.midiNotes[idx] + " ] )",
                     } );
                 },

keyboardArray : function(num, x, y) {
                  var ctrls = [];
                  for (var i=0;i<num;i++) { 
                    ctrls.push( this.keyboardButton(i,  x+((this.gapSize+this.buttonW)*i) , y ));
                  }
                  return(ctrls);
                },

loadSongButton : function(songID, x, y) { return( {
                     "name":  "loadSong" + songID,
                     "type": "Button",
                     "label": songID,
                     "bounds": [ x, y,  this.buttonW, this.buttonH],
                     "color": "#F33",
                     "backgroundColor": "#F0F",
                     "stroke": "#333",
                     "mode":"momentary",
                     "ontouchstart": "oscManager.sendOSC( [ '/renoise/song/load/by_id',  's', '" + songID + "'])",
                     } );
                 },

loadSongArray : function(songIDs, x, y) {
                  var ctrls = [];
                  for (var i=0;i<songIDs.length;i++) { 
                    ctrls.push( this.loadSongButton(songIDs[i],  x+((this.gapSize+this.buttonW)*i) , y ));
                  }
                  return(ctrls);
                },


                ///////////////////////////////////
                // Track delay controls.  Need to fix this:  There needs to be a way to reset the value back to zero, and
                // the slider has to be centered on 0 as a baseline.

trackDelayControl : function(idx, x, y){ return( {
                        "name": "trackDelay" + idx,
                        "type": "Slider",
                        "bounds": [x, y, this.volSliderW , this.volSliderH],
                        "startingValue": 0,
                        "color": "#00ff33",
                        "stroke": "#333",
                        "backgroundColor": "#60f",

                        "min": -100.0,
                        "max": 100.0,
                        "label" : this.value,
                        "isXFader": true,
                        "isVertical": true,
                        "address" :  "/renoise/song/track/" + idx + "/output_delay",
                        }  ); 

                    },

trackDelayControls : function(num, x, y) {
                       var ctrls = [];
                       for (var i=0;i<num;i++) { 
                         ctrls.push(  this.trackDelayControl(i+1, x+((this.gapSize+this.volSliderW)*i) , y )  ); 
                         ctrls.push(  this.trackDelayResetControl(i+1, x+((this.gapSize+ this.volSliderW)*i),  y + this.gapSize + this.volSliderH )  ); 
                       }
                       return ctrls;
                     },

                     ///////////////////////////////////////


trackVolumeControl : function(idx, x, y){ return( {
                         "name": "trackVol" + idx,
                         "type": "Slider",
                         "bounds": [x, y, this.volSliderW , this.volSliderH],
                         "startingValue": 0,
                         "color": "#00ff33",
                         "stroke": "#333",
                         "backgroundColor": "#60f",
                         "min": 0.0,
                         "max": 1.0,
                         "label" : this.value,
                         "isXFader": true,
                         "isVertical": true,
                         "address" :  "/renoise/song/track/" + idx + "/postfx_volume",
                         }  ); 

                     },

trackVolumeControls : function(num, x, y) {
                        var ctrls = [];
                        for (var i=0;i<num;i++) { 
                          ctrls.push(  this.trackVolumeControl(i+1, x+((this.gapSize+this.volSliderW)*i) , y )  ); 
                          ctrls.push(  this.trackSelectControl(i+1, x+((this.gapSize+ this.volSliderW)*i),  y + this.gapSize + this.volSliderH )  ); 
                        }
                        return ctrls;
                      },

trackClearControl : function(idx, x, y){
                      return({ 
                          "name": "trackClear" + idx,
                          "type": "Button",
                          "label" : "!!!!",
                          "x": x,
                          "y": y,
                          "width": this.buttonW,
                          "height": this.buttonH,
                          "color": "#fff",
                          "backgroundColor": "#F00",
                          "stroke": "#000",
                          "mode" : "momentary",
                          "ontouchstart": "oscManager.sendOSC( [ '/renoise/song/track/" + idx + "/clear'])",
                          } );
                    },

trackClearControls : function(num, x, y) {
                       var ctrls = [];
                       for (var i=0;i<num;i++) { 
                         ctrls.push(  this.trackClearControl( i+1, x + this.horizOffset(i), y )  ); 
                       }
                       return ctrls;
                     },

trackDelayResetControl : function(idx, x, y){
                           return( {
                               "name": this.trackSelectPrefix  + "DelayReset" + idx,
                               "type": "Button",
                               "label": "@",
                               "bounds" :[ x, y,  this.buttonW, this.buttonH],
                               "color": "#033",
                               "backgroundColor": "#FF3",
                               "stroke": "#333",
                               "mode":"momentary",
                               "requiresTouchDown": false,
                               "min": 0,
                               "max": 0,
                               "ontouchstart": "trackDelay" + idx + ".setValue(0)",
                               });
                           // Note: It seems that all events send OSC messages.  For this one it sends /trackSelect<idx>. 
                           // It gets ignored by Renoise.
                         },

trackSelectControl : function(idx, x, y){
                       return( {
                           "name": this.trackSelectPrefix  + idx,
                           "type": "Button",
                           "label": "@",
                           "bounds" :[ x, y,  this.buttonW, this.buttonH],
                           "color": "#FF3333",
                           "backgroundColor": "#3F3",
                           "stroke": "#333",
                           "mode":"toggle",
                           "requiresTouchDown": false,
                           "min": 0,
                           "max": 1,
                           "ontouchstart": "if (this.value != this.min)  { Control.selectTrack("+idx+"); } else {Control.unselectTracks();}",
                           });
                       // Note: It seems that all events send OSC messages.  For this one it sends /trackSelect<idx>. 
                       // It gets ignored by Renoise.
                     },

commonControls : function(pageName) { 
                   var ctrls = [];

                   ctrls.push( {
                       "name": pageName + "Refresh",
                       "type": "Button",
                       "bounds": [ this.xstart, this.vertOffset(9) , this.buttonW, this.buttonH ],
                       "startingValue": 0,
                       "isLocal": true,
                       "mode": "contact",
                       "ontouchstart": "interfaceManager.refreshInterface()",
                       "stroke": "#3Cf",
                       "label": "Refresh!",
                       });

                   ctrls.push( {
                       "name": pageName + "Menu",
                       "type": "Button",
                       "bounds": [ this.horizOffset(1)+this.gapSize*4, this.vertOffset(9) , this.buttonW, this.buttonH],
                       "mode": "toggle",
                       "stroke": "#f63",
                       "isLocal": true,
                       "ontouchstart": "if(this.value == this.max) { control.showToolbar(); } else { control.hideToolbar(); }",
                       "label": "Menu",
                       } );

                   ctrls.push( {
                       "name": pageName + "Play",
                       "type": "Button",
                       "bounds": [ this.horizOffset(2) + this.gapSize*4, this.vertOffset(9) , this.buttonW, this.buttonH],
                       "startingValue": 0,
                       "isLocal": true,
                       "mode": "contact",
                       "ontouchstart": "control.changePage(0);",
                       "stroke": "#0F0",
                       "label": "  Play",
                       });

                   ctrls.push( {
                       "name": pageName + "Edit",
                       "type": "Button",
                       "bounds": [ this.horizOffset(3)+this.gapSize*4, this.vertOffset(9) , this.buttonW, this.buttonH],
                       "startingValue": 0,
                       "isLocal": true,
                       "mode": "contact",
                       "ontouchstart": "control.changePage(1);",
                       "stroke": "#F00",
                       "label": "  Edit",
                       });

                   ctrls.push( {
                       "name": pageName + "Load",
                       "type": "Button",
                       "bounds": [ this.horizOffset(4)+this.gapSize*4, this.vertOffset(9) , this.buttonW, this.buttonH],
                       "startingValue": 0,
                       "isLocal": true,
                       "mode": "contact",
                       "ontouchstart": "control.changePage(2);",
                       "stroke": "#00F",
                       "label": "  Load",
                       });

                   return ctrls;

                 },

                 // Need this because we want to define the object properties in terms of other properties
init: function() {
        this.gapSize    = this.blockSize * 0.15; 
        this.buttonW    = this.blockSize*2;
        this.buttonH    = this.blockSize;
        this.volSliderW = this.buttonW;
        this.volSliderH = this.buttonH*5;
        this.trackCtrlsStartY = this.xstart + this.buttonH + this.gapSize;

        return this; 
      }


}.init();

Control.renoise = {
currentInstrument : -1,
                    numOfTracks : 5,
                    currentTrack : -1,
                    midiNotes :  [48,  50, 52, 53, 55],
                    notes : [ "C", "D", "E", "F", "G" ],

                    init: function() {
                      // Here if we need to create properties using pre-defined properties
                      // Also, if we call this we must return this so the variable has the correct assignment
                      return this;
                    }

}.init();


Control.unselectTracks = function() {
  Control.renoise.currentTrack      = - 1 ;
  Control.renoise.currentInstrument = - 1;
}


// This is unexpected.  When using the JGB object to hold this funtion it was never called.
// Assigning it to Control, though, makes it work when called from a JGB function
Control.selectTrack = function(trkNum) {
  // Select the track as well as the intrument. It seems there is no OSC that just selects a track or intrument,
  // but these can be specified when sending notes
  //    /renoise/trigger/note_on(number, number, number, number)
  //        Trigger a Note-On.
  //        arg#1: instrument (-1 for the currently selected one)
  //        arg#2: track (-1 for the current one)
  // We can set some variables here and then when a note is sent it uses these values.
  // The assumption here is that sending a note will use a contact button; touch-stop sends
  // note off.  This way we ensure that on and off always refer to the same track and intrument

  var ctrlName = "";

  for(var i=0; i < Control.renoise.numOfTracks; i++) {
    // Unselect all tracks
    ctrlName  = Control.ui.trackSelectPrefix + (i+1);
    eval( ctrlName + ".setValue(0);" );
  }

  ctrlName  = Control.ui.trackSelectPrefix + trkNum;
  eval( ctrlName + ".setValue(1);" );

  // Renoise is kind of funny with numbering. The instruments selected off on the right start at 0.
  // The tracks, by default, show a numberng that starts at 1, but when sending OSC they too start at 0.
  Control.renoise.currentTrack      = trkNum - 1 ;
  Control.renoise.currentInstrument = trkNum - 1;

}



/**********************************************************

  We want to have a set of controls for global operations
  and then sets for each track.   On the phone there is not enough room to
  have slider and buttons if we go across.  We need them to go top-to-bottom

  [start/stop toggle][getBpm][recToggle]
  [bpmSlider                 ][bpm display?]

  ------- tracks -------
  [ mute  ]             ...
  [ armed ]             ... 
  -volume slider -


  --------- to play notes for selected track ------
  [C][C#][D][D#]......[]




  Selecting a track as active needs to unselect any existing active setting  
However: If user selects track n, then selects it again, it basically unselects
it, leaving no track selected on the UI. What track then is current selected track and intrument?
Right now it remains whatever was last used.  You can only unselect a track by selecting 
a new one.  It would be nice if the UI reflected this.
 ***********************************************************/

loadedInterfaceName = "rns";

interfaceOrientation = "portrait";

var controlPage = [ {
  "name": "bpm",
    "type": "Button",
    "label" : "BPMq",
    "x": Control.ui.xstart,
    "y": Control.ui.ystart,
    "width": Control.ui.buttonW,
    "height": Control.ui.buttonH,
    "color": "#aa0000",
    "backgroundColor": "#FF0",
    "stroke": "#000",
    "mode" : "momentary",
    "value":100,
    "ontouchstart": "oscManager.sendOSC( [ '/renoise/speak/bpm', 'ii', 9, 9])",
    "address" : "/renoise_response/transport/bpm",
}, {
  "name": "startStopTransport",
    "type": "Button",
    "label": "(|)",
    "x": Control.ui.xstart + Control.ui.horizOffset(1),
    "y": Control.ui.ystart,
    "width": Control.ui.buttonW,
    "height": Control.ui.buttonH,
    "color": "#FF3333",
    "backgroundColor": "#3F3",
    "stroke": "#333",
    "mode":"toggle",
    "requiresTouchDown": false,
    "ontouchstart": "if (this.value == this.min) { oscManager.sendOSC( ['/renoise/transport/stop']); } else { oscManager.sendOSC( ['/renoise/transport/start']); }",
}
, {
  "name": "recMode",
    "type": "Button",
    "label": "*",
    "x": Control.ui.xstart + Control.ui.horizOffset(2),
    "y": Control.ui.ystart,
    "width": Control.ui.buttonW,
    "height": Control.ui.buttonH,
    "color": "#ff5e00",
    "backgroundColor": "#038bcf",
    "stroke": "#333",
    "mode":"toggle",
    "requiresTouchDown": false,
    "ontouchstart": "if (this.value == this.min) { oscManager.sendOSC( ['/renoise/song/edit/mode', 'i', 0]); } else { oscManager.sendOSC( ['/renoise/song/edit/mode', 'i', 1]); }",
} , {
  "name": "songUndo",
    "type": "Button",
    "label": "<b>&lt;</b>",
    "x": Control.ui.xstart + Control.ui.horizOffset(3),
    "y": Control.ui.ystart,
    "width": Control.ui.buttonW,
    "height": Control.ui.buttonH,
    "color": "#000",
    "backgroundColor": "#d97a0e",
    "stroke": "#333",
    "mode":"momentary",
    "ontouchstart": "oscManager.sendOSC( ['/renoise/song/undo']); ",
} , {
  "name": "info",
    "type": "Label",
    "value": ".....",
    "x": Control.ui.xstart + Control.ui.horizOffset(4),
    "y": Control.ui.ystart,
    "width": Control.ui.buttonW,
    "height": Control.ui.buttonH,
    "color": "#000",
    "backgroundColor": "#fff",
    "stroke": "#000",
},
  ];





controlPage.push( Control.ui.bpmSlider( Control.ui.xstart , Control.ui.trackCtrlsStartY ) );
controlPage = controlPage.concat( Control.ui.keyboardArray( Control.renoise.numOfTracks, Control.ui.xstart , Control.ui.trackCtrlsStartY+Control.ui.vertOffset(1)  ) );
controlPage = controlPage.concat( Control.ui.trackVolumeControls(Control.renoise.numOfTracks, Control.ui.xstart , Control.ui.trackCtrlsStartY+Control.ui.vertOffset(2) ) );

controlPage = controlPage.concat( Control.ui.commonControls("playPage") );
/*

   controlPage.push(  {
   "name": "refresh",
   "type": "Button",
   "bounds": [ Control.ui.xstart, 
   Control.ui.vertOffset(9) , 
   Control.ui.buttonW, 
   Control.ui.buttonH],
   "startingValue": 0,
   "isLocal": true,
   "mode": "contact",
   "ontouchstart": "interfaceManager.refreshInterface()",
   "stroke": "#fff",
   "label": "Refresh!",
   });

   controlPage.push( {
   "name": "tabButton",
   "type": "Button",
   "bounds": [ Control.ui.horizOffset(1)+Control.ui.gapSize*4, 
   Control.ui.vertOffset(9) , 
   Control.ui.buttonW, 
   Control.ui.buttonH],
   "mode": "toggle",
   "stroke": "#0F0",
   "isLocal": true,
   "ontouchstart": "if(this.value == this.max) { control.showToolbar(); } else { control.hideToolbar(); }",
   "label": "Menu",
   } );

   controlPage.push( {
   "name": "page2",
   "type": "Button",
   "bounds": [ Control.ui.horizOffset(4)+Control.ui.gapSize*4, 
   Control.ui.vertOffset(9) , 
   Control.ui.buttonW, 
   Control.ui.buttonH],
   "startingValue": 0,
   "isLocal": true,
   "mode": "contact",
   "ontouchstart": "control.changePage('next');",
   "stroke": "#F00",
   "label": "  Page 2",
   });
   */

var editPage = [ ]

editPage = editPage.concat( Control.ui.trackClearControls( 
      Control.renoise.numOfTracks, 
      Control.ui.xstart, 
      Control.ui.trackCtrlsStartY+Control.ui.horizOffset(0) + Control.ui.gapSize ) );

editPage.push(Control.ui.resetButton(Control.ui.xstart, Control.ui.ystart));
// The Edit page needs some controls for other actions, such as altering the delay
// up or down on each track.  THe trick to put suitbale controls on each page
// while not making things too small and crowdy, and not making it easy to
// screw up.
//
// The Edit page has comtrols that will clear an entire trakc as well as exeucte 
// a massive series of undo, wiping out all changes.
//


editPage = editPage.concat( Control.ui.trackDelayControls(Control.renoise.numOfTracks, Control.ui.xstart , Control.ui.trackCtrlsStartY+Control.ui.vertOffset(1) ) );

editPage = editPage.concat( Control.ui.commonControls("editPage") );

loadPage = [];
// Need to add controls for loading songs based on an index number. 
// The plan is that GlobalOscActions.lua handles a message that requests
// a song be loaded given some number, such as "002"
// The handler looks at the current song file path and swaps out the number in that
// file name to get the name of the file to load.
//
// For exaple, if you are currently playing /some/file/path/folder/song__002.xrns
//
// and request /renoise/song/load/by_id "004"
//
// then the handler come computes the file name  /some/file/path/folder/song__004.xrns
// and loads it.
loadPage = loadPage.concat( Control.ui.commonControls("loadPage") );
loadPage = loadPage.concat( Control.ui.loadSongArray( ["001", "002", "003", "004", "005"], 
        Control.ui.xstart, 
        Control.ui.vertOffset(1))  );

loadPage.push( {
    "name": "saveVersion",
    "type": "Button",
    "bounds": [ Control.ui.xstart, 
    Control.ui.vertOffset(2) , 
    Control.ui.buttonW, 
    Control.ui.buttonH ],
    "startingValue": 0,
    "isLocal": true,
    "mode": "momentary",
    "stroke": "#F00",
    "label":   "Save!",
    "ontouchstart": "oscManager.sendOSC( ['/renoise/song/save_version']); ",
    } );

pages = [controlPage, editPage, loadPage];

