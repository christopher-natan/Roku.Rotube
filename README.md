## Rotube
Simple brightScript plugin that use Youtube API to play youtube video on a Roku Channel.

#### Version
- Version 1.1 supports Grid Screen only.

#### Requirements
- Roku 2 firmware version 5 (RSG not supported)

#### Installation
- Clone Rotube repository
- Extract or drop Rotube.brs file to your Roku source folder.

#### How To Use
With just few lines of codes, Rotube plugin will work smoothly.
  ```php
    options                         = { maxResults:20, key:"AIzaSyAL3MhQSCFMRyq8u4mlwL8PvuPxxNhCEDo"} 
    theseItems                      = {}
    theseItems["Category Action"]   = "action"
    theseItems["Category Drama"]    = "drama"
    theseItems["Category Adventure"]= "adventure"
 ```
   ```php
    rotubeItems = Rotube().Search(theseItems).Options(options).CreateGridScreen(gridScreen)
 ```
 Please be advised that you need to have your own Youtube Key configuratio. The example key will going to work but limited only.
 
#### Example
For more information on how to use this Rotube plugin please refer to the example files.
