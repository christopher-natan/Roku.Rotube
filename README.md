## Rotube
Simple Youtube plugin for Roku channel application.

#### Version
- Version 1.1 supports Grid Screen only.

#### Requirements
- Roku 2 firmware version 5.+

#### Installation
- Have a clone to Rotube repository or download Rotube.brs
- Extract or drop Rotube.brs file to your Roku source folder.

#### How To Use
With just few lines of codes, Rotube plugin will work smoothly.
  ```php
    options                         = { maxResults:20, key:"AIzaSyAL3MhQSCFMRyq8u4mlwL8PvuPxxNhCEDo"} 
    theseItems                      = {}
    theseItems["Category Action"]   = "action"
    theseItems["Category Drama"]    = "drama"
    theseItems["Category Adventure"]= "adventure"
    rotubeItems = Rotube().Search(theseItems).Options(options).CreateGridScreen(gridScreen)
 ```
 Please be advised that you need to have your own Youtube Key. The example key will work but limited only.
 
 #### Example
 I included example file and codes on this repo with the detailed explanation. For more information on how to use this Rotube plugin please refer to the example file.
Please report any bug. Thank You