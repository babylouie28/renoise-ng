// This is the real one
// This is supposed to send OSC messages that the server should in turn use to trigger
// keyboard events so as to manipulate Adobe Illustrator

Control.ui = { blockSize: 0.085, 
  sliderY: 0.72, 
  xstart    : 0.05,
  ystart    : 0.05,
  trackSelectPrefix : "trackSelect",
  addressPrefix: '/ng/keyboard',

  horizOffset : function(num) {
    return( (this.buttonW + this.gapSize ) * num  );
  },

 horizNavOffset : function(num) {
    return( (this.navButtonW + this.gapSize ) * num + this.xstart);
  },

vertOffset : function(num) {
               return( (this.buttonH + this.gapSize ) *num );
             },

vertNavOffset : function(num) {
               return( (this.navButtonH + this.gapSize ) *num );
             },

resetModKeys : function() {
                /// hard coded for ease but not really good if we alter page count
                altMod0.setValue(0);
                ctrlMod0.setValue(0);

                altMod1.setValue(0);
                ctrlMod1.setValue(0);

               },
  
keyButton : function(key, x, y) {  return( {
                  "name": "_" + key + "Key",
                  "type": "Button",
                  "label": key,
                  "bounds": [x, y,  this.buttonW, this.buttonH ],
                  "color": "#fff",
                  "backgroundColor": "#cF9",
                  "stroke": "#000",
                  "mode":"momentary",
                  "ontouchstart": "oscManager.sendOSC( ['" + this.addressPrefix + "/key', 's', '" + key + "']);",
                  "ontouchend":  "Control.ui.resetModKeys();"
                  } );
              }, 

modButton : function(pageNum, key, x, y) {  return( {
                  "name":  key + "Mod" + pageNum,
                  "type": "Button",
                  "label": key,
                           "min": 0,
                           "max": 1,

                  "foo": 0,
                  "bounds": [x, y,  this.buttonW, this.buttonH ],
                  "color": "#36f",
                  "backgroundColor": "#333",
                  "stroke": "#fff",
                  "mode":"toggle",
//                  "onvaluechange": "this.foo = this.value; oscManager.sendOSC( [ '/ng/test',  'i', this.value ]); ",      
                  "address": this.addressPrefix + "/mod/" + key,
//                  "ontouchstart": " alert( this.name + '  = ' + this.value)"
                  } );
              },


keyArray : function(keys, x, y) {
                  var ctrls = [];

                  for (var i=0; i < keys.length; i++) { 
                    ctrls.push( this.keyButton(keys[i],  x+((this.gapSize+this.buttonW)*i) , y ));
                  }
                  return(ctrls);
                },

    modArray : function(pageNum, mods, x, y) {
                  var ctrls = [];

                  for (var i=0; i < mods.length; i++) { 
                    ctrls.push( this.modButton(pageNum, mods[i],  x+((this.gapSize+this.buttonW)*i) , y ));
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
                     "ontouchstart": "oscManager.sendOSC( [ '/renoise/song/load/by_number',  's', '" + songID + "'])",
                     } );
                 },


                
commonControls : function(pageName) { 
                   var ctrls = []; 
                   var vOffset = this.vertOffset(0);
                   ctrls.push( {
                       "name": pageName + "Refresh",
                       "type": "Button",
                       "bounds": [ this.xstart, vOffset, this.navButtonW, this.navButtonH ],
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
                       "bounds": [ this.horizNavOffset(1), vOffset, this.navButtonW, this.navButtonH  ],
                       "mode": "toggle",
                       "stroke": "#f63",
                       "isLocal": true,
                       "ontouchstart": "if(this.value == this.max) { control.showToolbar(); } else { control.hideToolbar(); }",
                       "label": "Menu",
                       } );

                      ctrls.push( {
                       "name": pageName + "Actions",
                       "type": "Button",
                       "bounds": [ this.horizNavOffset(2), vOffset, this.navButtonW, this.navButtonH  ],
                       "mode": "contact",
                       "stroke": "#0f3",
                       "isLocal": true,
                       "ontouchstart": "control.changePage(0); ",

                       "label": "Actions",
                       } );

                      ctrls.push( {
                       "name": pageName + "File",
                       "type": "Button",
                       "bounds": [ this.horizNavOffset(3), vOffset, this.navButtonW, this.navButtonH  ],
                       "mode": "contact",
                       "stroke": "#963",
                       "isLocal": true,
                       "ontouchstart": "control.changePage(1);",
                       "label": "File",
                       } );

                   return ctrls;

                 },

                 // Need this because we want to define the object properties in terms of other properties
init: function() {
        this.gapSize    = this.blockSize * 0.2; 
        this.buttonW    = this.blockSize * 5;
        this.buttonH    = this.blockSize * 1.5;

        this.navButtonW    = this.blockSize*2.5;
        this.navButtonH    = this.blockSize;

        this.trackCtrlsStartY = this.xstart + this.buttonH + this.gapSize;

        return this; 
      }


}.init();



// This is unexpected.  When using the JGB object to hold this funtion it was never called.
// Assigning it to Control, though, makes it work when called from a JGB function
Control.selectTrack = function(trkNum) {

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

loadedInterfaceName = "ill";
interfaceOrientation = "portrait";

var controlPage = [ ];
var filePage    = [ ];

controlPage = controlPage.concat( Control.ui.commonControls("keyPage") );
filePage = filePage.concat( Control.ui.commonControls("filePage") );

var actions1 = ['v', 'b'];
var actions2 = ['f', '0'];
var actions3 = ['z', 'u'];

var actions4 = ['DEL', 'ESC'];

var file1 = ['s', 'n'];
var file2 = ['ENTER', 'ESC'];

var mods = ['alt', 'ctrl'];


controlPage = controlPage.concat( Control.ui.keyArray( actions1 , 
                                                       Control.ui.xstart, 
                                                       Control.ui.vertOffset(1)  ) ); 

controlPage = controlPage.concat( Control.ui.keyArray( actions2 , 
                                                       Control.ui.xstart, 
                                                       Control.ui.vertOffset(2)  ) );

controlPage = controlPage.concat( Control.ui.keyArray( actions3 , 
                                                       Control.ui.xstart, 
                                                       Control.ui.vertOffset(3)  ) );

controlPage = controlPage.concat( Control.ui.keyArray( actions4 , 
                                                       Control.ui.xstart, 
                                                       Control.ui.vertOffset(4)  ) );

controlPage = controlPage.concat( Control.ui.modArray( 0, mods , 
                                                       Control.ui.xstart, 
                                                       Control.ui.vertOffset(6)  ) );



filePage = filePage.concat( Control.ui.keyArray( file1 , 
                                                       Control.ui.xstart, 
                                                       Control.ui.vertOffset(1)  ) );


filePage = filePage.concat( Control.ui.keyArray( file2 , 
                                                       Control.ui.xstart, 
                                                       Control.ui.vertOffset(2)  ) );

filePage = filePage.concat( Control.ui.modArray( 1, mods , 
                                                       Control.ui.xstart, 
                                                       Control.ui.vertOffset(6)  ) );


pages = [controlPage, filePage];

