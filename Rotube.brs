'**********************************************************
'**  Rotube
'**  Simple Youtube plugin for Roku channel application.
'**
'**  @copyright     Copyright (c) Christopher M. Natan
'**  @author        Christopher M. Natan
'**  @version       1.1
'**********************************************************


'***********************************************************
'** Base Rotube method.
'** 
'** @return object this
'***********************************************************  
Function Rotube() as Object
    this         = {}
    this.Search  = RotubeSearch
    this.Play    = RotubePlay
    return this
End Function

'***********************************************************
'**  Initialize search settings.
'** 
'**  @param  object q
'**  @return object m.Rotube
'**
'**  example:
'**  theseItems["Category Action"] = "action movies"
'**  theseItems["Category Drama"]  = "drama"
'**  Rotube().Search(theseItems)
'***********************************************************  
Function RotubeSearch(q as Object) as Object  
     m.Rotube   = {}
     m.Rotube.q = q
     m.Rotube.Options = RotubeOptions
     
     return m.Rotube
End Function

'***********************************************************
'**  Set Rotube options.
'** 
'**  @param  object options
'**  @return object m
'**
'**  example:
'**  key  = "BIzaSyAL3MhQSCtyq8u4mlwL8PvuPxxNhCEDo"   
'**  Rotube().Search(theseItems).Options({ maxResults:20, key:key })
'***********************************************************  
Function RotubeOptions(options as Object) as Object
    
    m.Rotube            = {}
    m.Rotube.results    = []
    m.Rotube.categories = []
    m.CreateGridScreen  = RotubeCreateGridScreen
    
    index = 0 
    for each key in m.q
        url  = RotubeParameter(m.q[key], options)
        searchResults = []
        response = RotubeConnect(url)
        results  = ParseJSON(response)
     
        for each result in results.items
            searchResults.Push(RotubeGetInformation(result)) 
        next
        
        m.Rotube.results[index] = searchResults 
        m.Rotube.categories.Push(key)
        index = index + 1
    next
    
    return m
End Function

'***********************************************************
'**  Assemble all the parameters and return the final url.
'** 
'**  @param  object q
'**  @param  object options
'**  @return string url
'***********************************************************  
Function RotubeParameter(q, options) as String
   p = {
        baseUrl       : "https://content.googleapis.com/youtube/v3/search"
        part          : "snippet",
        maxResults    : options.maxResults.toStr(),
        q             : q
        key           : options.key
   }
   url = p.baseUrl + "?" + "part=" + p.part + "&maxResults=" + p.maxResults + "&q=" + p.q + "&key=" + p.key
   
   return url
End Function

'***********************************************************
'**  Return all the necessary information.
'** 
'**  @param  object result
'**  @return object information
'***********************************************************  
Function RotubeGetInformation(result) As Object
    snippet     = result.snippet
    thumbnails  = snippet.thumbnails
    information = {
        videoId         : result.id.videoId,
        Description     : snippet.description,
        Title           : snippet.title,
        HDPosterUrl     : thumbnails.high.url,
        SDPosterUrl     : thumbnails.medium.url
    }
    
    return information
End Function

'***********************************************************
'**  Using an Asynchronous transfer to url and return the results.
'** 
'**  @param  string url 
'**  @return string results
'***********************************************************  
Function RotubeConnect (url as String) as String
    this             = {}
    this.url         = url
    this.m           = m
    
    DSCONFIG                   = Function() as Object
        config                 = {}
        config.EnableEncodings = true 
        config.Header          = "application/x-www-form-urlencoded"
        config.Certificate     = "common:/certs/ca-bundle.crt"
        config.Retry           = 20
        config.TimeOut         = 2000
        config.Method          = "GET"
        
        return config
    End Function 
    
    DSTRANSFER                 = Function(this) as Object
       this.transfer           = CreateObject("roUrlTransfer")
       this.port               = CreateObject("roMessagePort")
       this.transfer.SetUrl(this.url)
       this.transfer.SetPort(this.port)
       this.transfer.AddHeader("Content-Type", this.config.Header)
       this.transfer.SetCertificatesFile(this.config.Certificate)
       this.transfer.InitClientCertificates() 
       this.transfer.EnableEncodings(this.config.EnableEncodings)
       this.transfer.SetRequest(this.config.Method)
       this.m.Transfer = this.transfer
       
       Print "-connecting to url: ";this.url
       return this
    End Function
    
    DSCONNECT                    = Function(this) as Object
        results                  = invalid
        retry                    = this.config.Retry
        timeout                  = this.config.TimeOut
        while true
            this                 = this.dsTransfer(this)
            if (this.transfer.AsyncGetToString())
                event            = wait(timeout, this.transfer.GetPort()) 
                if type(event)   = "roUrlEvent"    
                    results      = event.GetString()
                    if RotubeIsValidString(results) then exit while
                else if event    = invalid
                     this.transfer.AsyncCancel()
                     timeout     = 2 * timeout
                end if
            endif
            
            retry    = retry - 1
            if retry = 0 then  exit while
            print "-retry: "; retry  
       end while
       if RotubeIsValidString(results) = false then results = invalid
       
       return results
   End Function
   
   this.config      =  dsConfig()
   this.dsTransfer  =  dsTransfer
   results          =  dsConnect(this)
   
   return results 
End Function   

'***********************************************************
'**  Check string validity .
'** 
'**  @param  dynamic obj
'**  @return boolean
'*********************************************************** 
Function RotubeIsValidString(obj As Dynamic) As Boolean
    if type(obj) = "<uninitialized>" then return false
    if obj       = invalid return false
    if Len(obj)  = 0 return false
    if GetInterface(obj, "ifString") = invalid return false
    
    return true
End Function

'***********************************************************
'**  Create Grid screen and set the content.
'** 
'**  @param  roGridScreen gridScreen
'**  @return object
'*********************************************************** 
Function RotubeCreateGridScreen(rotubeGridScreen as Object) as Object
 
    totalCategories = m.Rotube.categories.Count()
    rotubeGridScreen.SetupLists(totalCategories)
    rotubeGridScreen.SetListNames(m.Rotube.categories)
 
    for index = 0 to totalCategories
        rotubeGridScreen.SetContentList(index, m.Rotube.results[index])
    end for
    rotubeGridScreen.Show()
    
    return m.Rotube.results
End Function

'***********************************************************
'**  Play the youtube item.
'** 
'**  @param  roVideoScreen videoScreen
'**  @return void
'*********************************************************** 
Function RotubePlay(rotubevideoScreen as Object,  rotubeItems as Object)
    
    rotubevideoScreen.show()
    rotubeMedia = RotubeParse(rotubeItems, rotubeItems.videoId)
    rotubevideoScreen.SetPositionNotificationPeriod(30)
    rotubevideoScreen.SetContent(rotubeMedia)
   
End Function

'***********************************************************
'**  Parse the results and return as proper AA.
'** 
'**  @param  object rotubeItems
'**  @param  string youtubeId
'**  @return object media
'*********************************************************** 
Function RotubeParse(rotubeItems as Object, youtubeId as String) as Object
    
    config = {
        sourceUrl:"http://www.youtube.com/get_video_info?video_id=" + youtubeId
    }
    
    response    = RotubeConnect (config.sourceUrl)
    if response = invalid then return invalid
    format      = RotubeFormat(response)
    bitrates    = []
    urls        = []
    qualities   = []
    
    if(format = invalid) 
        RotubeMessageDialog("Not Available", "This Youtube video is not available.")
        return false
    else
        for each data in format
            bitrates.Push(data["bitrate"])
            urls.Push(data["url"])
            qualities.Push(data["quality"])
        next 
    end if     
       
    media = {}
    media.Title            = rotubeItems.Title
    media.StreamBitrates   = bitrates
    media.StreamUrls       = urls
    media.StreamQualities  = qualities
    media.StreamFormat     = "mp4"
    return media
End Function

'***********************************************************
'**  Format the results into proper AA items.
'**  I borrowed this method to toasterdesigns (Thank you man!)
'**
'**  @param  string results
'**  @return object
'*********************************************************** 
Function RotubeFormat(results As String) As Object
    roRegex             = CreateObject("roRegex", "(?:|&"+CHR(34)+")url_encoded_fmt_stream_map=([^(&|\$)]+)", "")
    videoFormatsMatches = roRegex.Match(results)
    if videoFormatsMatches[0]<>invalid then
        videoFormats = videoFormatsMatches[1]
    else
        return invalid
    end if

    sep1 = CreateObject("roRegex", "%2C", "")
    sep2 = CreateObject("roRegex", "%26", "")
    sep3 = CreateObject("roRegex", "%3D", "")

    videoURL          = CreateObject("roAssociativeArray")
    videoFormatsGroup = sep1.Split(videoFormats)
    for each videoFormat in videoFormatsGroup
        videoFormatsElem = sep2.Split(videoFormat)
        videoFormatsPair = CreateObject("roAssociativeArray")
        for each elem in videoFormatsElem
            pair = sep3.Split(elem)
            if pair.Count() = 2 then
                videoFormatsPair[pair[0]] = pair[1]
            end if
        end for

        if videoFormatsPair["url"]<>invalid then 
            r1  = CreateObject("roRegex", "\\\/", ""):r2=CreateObject("roRegex", "\\u0026", "")
            url = RoTubeURLDecode(RoTubeURLDecode(videoFormatsPair["url"]))
            r1.ReplaceAll(url, "/"):r2.ReplaceAll(url, "&")
        end if
        if videoFormatsPair["itag"]<>invalid then
            itag = videoFormatsPair["itag"]
        end if
        if videoFormatsPair["sig"]<>invalid then 
            sig = videoFormatsPair["sig"]
            url = url + "&signature=" + sig
        end if

        if Instr(0, LCase(url), "http") = 1 then 
            videoURL[itag] = url
        end if
    end for

    qualityOrder    = ["18","22","37"]
    bitrates        = [768,2250,3750]
    isHD            = [false,true,true]
    streamQualities = []
    for i = 0 to qualityOrder.Count()-1
        qn = qualityOrder[i]
       
        if videoURL[qn]<>invalid then
            streamQualities.Push({url: videoURL[qn], bitrate: bitrates[i], quality: isHD[i], contentid: qn})
        end if
    end for
    
    return streamQualities
End Function

'***********************************************************
'**  Decode url into proper format.
'**
'**  @param  string str
'**  @return string
'*********************************************************** 
Function RoTubeURLDecode(str As String) As String
    RotubeStrReplace(str,"+"," ") ' backward compatibility
    if not m.DoesExist("encodeProxyUrl") then m.encodeProxyUrl = CreateObject("roUrlTransfer")
    
    return m.encodeProxyUrl.Unescape(str)
End function

'***********************************************************
'**  Replace all occurrences of the search 
'**  string with the replacement string.
'**
'**  @param  string baseStr
'**  @param  string oldSub
'**  @param  string newSub
'**  @return string
'*********************************************************** 
Function RotubeStrReplace(baseStr As String, oldSub As String, newSub As String) As String
    newstr = ""
    i = 1
    while i <= Len(basestr)
        x = Instr(i, basestr, oldsub)
        if x = 0 then
            newstr = newstr + Mid(basestr, i)
            exit while
        endif
        if x > i then
            newStr = newstr + Mid(basestr, i, x-i)
            i = x
        endif

        newStr = newStr + newsub
        i = i + Len(oldsub)
    end while
    return newStr
End Function

'***********************************************************
'**  Rotube message dialog
'**
'**  @param  string title
'**  @param  string text
'**  @return string
'*********************************************************** 
Function RotubeMessageDialog(title  as String, text as String) As Void
    port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)
    dialog.SetTitle(title)
    dialog.SetText(text)
 
    dialog.AddButton(1, "OK")
    dialog.EnableBackButton(true)
    dialog.Show()
    While True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                if dlgMsg.GetIndex() = 1
                    exit while
                end if
            else if dlgMsg.isScreenClosed()
                exit while
            end if
        end if
    end while
End Function
