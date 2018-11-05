'**********************************************************
'**  Rotube
'**  Simple Youtube plugin for Roku channel application.
'**
'**  @copyright     Copyright (c) Christopher M. Natan
'**  @author        Christopher M. Natan
'**  @version       1.1
'**********************************************************
'**  This .brs file contains the example on how to use Rotube plugin
'**********************************************************

Function Main()
   YourGridScreen()
End Function 
  
Function YourGridScreen()
    
    port       = CreateObject("roMessagePort")
    gridScreen = CreateObject("roGridScreen")
    gridScreen.SetMessagePort(port)
    gridScreen.SetDisplayMode("scale-to-fill")
        
    ' Rotube plugin implementation.
    ' Note: You need to get your own Youtube key.
    '**********************************************************
    options                         = { maxResults:20, key:"AIzaSyAL3MhQSCFMRyq8u4mlwL8PvuPxxNhCEDo"} 
    theseItems                      = {}
    theseItems["Category Action"]   = "action"
    theseItems["Category Drama"]    = "drama"
    theseItems["Category Adventure"]= "adventure"
    rotubeItems = Rotube().Search(theseItems).Options(options).CreateGridScreen(gridScreen)
    '**********************************************************
    
    
    ' Grid Screen Event
    '**********************************************************    
     while true
        msg = wait(0, port)
        if type(msg) = "roGridScreenEvent" then
            if msg.isListItemFocused() then
            else if msg.isListItemSelected() then
               row       = msg.GetIndex()
               selection = msg.getData()
                
            ' Select the item and assign to rotubeToPlay variable 
            '**********************************************************    
                rotubeToPlay = rotubeItems[row][selection]
            '********************************************************** 
                
                YourVideoScreen(rotubeToPlay)                    
            else if msg.isScreenClosed() then
            end if
        end If
    end while
    
End Function  
  
Function YourVideoScreen(rotubeToPlay as Object)
        
    port        = CreateObject("roMessagePort")
    videoScreen = CreateObject("roVideoScreen")
    videoScreen.SetMessagePort(port)
    videoScreen.SetPositionNotificationPeriod(30)
    
   ' Play the video
   '**********************************************************     
    Rotube().Play(videoScreen, rotubeToPlay)
   '********************************************************** 
    
   ' Video Screen Event
   '**********************************************************   
    while true
        msg = wait(0, port)
        if type(msg) = "roVideoScreenEvent" then
            if msg.isScreenClosed()
                exit while
            else if msg.isButtonPressed()
            else if msg.isPlaybackPosition() then
            else
            end if
        else
        end if
   end while
    
End Function