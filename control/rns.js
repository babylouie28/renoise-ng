

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


trackVolumeControls : function(num, x, y) {
                        var ctrls = [];
                        for (var i=0;i<num;i++) { 
                          ctrls.push(  this.trackVolumeControl(i+1, x+((this.gapSize + this.ui.volSliderW)*i) , y )  ); 
                          ctrls.push(  this.trackSelectControl(i+1, x+((this.gapSize + this.volSliderW)*i),  y + this.gapSize + this.volSliderH )  ); 
                        }
                        return ctrls;
                      },

trackVolumeControl : function(idx, x, y){ return( {
                         "name": "trackVol" + idx,
                         "type": "Slider",
                         "bounds": [x, y, Control.ui.volSliderW , Control.ui.volSliderH],
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
                          "width": Control.ui.buttonW,
                          "height": Control.ui.buttonH,
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

trackSelectControl : function(idx, x, y){
                       return( {
                           "name": Control.ui.trackSelectPrefix  + idx,
                           "type": "Button",
                           "label": "@",
                           "bounds" :[ x, y,  Control.ui.buttonW, Control.ui.buttonH],
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


var editPage = [ ]

editPage = editPage.concat( Control.ui.trackClearControls( 
        Control.renoise.numOfTracks, 
        Control.ui.xstart, 
        Control.ui.trackCtrlsStartY+Control.ui.horizOffset(0) + Control.ui.gapSize ) );

editPage.push(Control.ui.resetButton(Control.ui.xstart, Control.ui.ystart));

editPage.push( {
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

editPage.push( {
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

editPage.push( {
    "name": "page1",
    "type": "Button",
    "bounds": [ Control.ui.horizOffset(4)+Control.ui.gapSize*4, 
                Control.ui.vertOffset(9) , 
                Control.ui.buttonW, 
                Control.ui.buttonH],
    "startingValue": 0,
    "isLocal": true,
    "mode": "contact",
    "ontouchstart": "control.changePage('previous');",
    "stroke": "#F00",
    "label": "  Page 1",
    });


pages = [controlPage, editPage];

