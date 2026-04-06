$PBExportHeader$salesdemo.sra
$PBExportComments$Generated Application Object
forward
global type salesdemo from application
end type
type timing_1 from timing within salesdemo
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global variables
String gs_host = "http://localhost:5099"
String gs_token
RestClient gnv_RestClient

Boolean gb_expand = True

String gs_msg_title = "Sales CRM Demo"

//Token expiresin
Long gl_Expiresin
//Refresh token clockskew 
Long gl_ClockSkew = 3

end variables

global type salesdemo from application
string appname = "salesdemo"
string displayname = "SalesDemo"
integer highdpimode = 0
string themepath = "C:\Program Files (x86)\Appeon\PowerBuilder 25.0\IDE\theme"
string themename = "Do Not Use Themes"
boolean nativepdfvalid = true
boolean nativepdfincludecustomfont = false
string nativepdfappname = ""
long richtextedittype = 5
long richtexteditx64type = 5
long richtexteditversion = 3
string richtexteditkey = ""
string appicon = ".\image\CRM.ico"
string appruntimeversion = "25.0.0.3726"
boolean manualsession = false
boolean unsupportedapierror = true
boolean ultrafast = false
boolean bignoreservercertificate = false
uint ignoreservercertificate = 0
long webview2distribution = 0
boolean webview2checkx86 = false
boolean webview2checkx64 = false
string webview2url = "https://developer.microsoft.com/en-us/microsoft-edge/webview2/"
timing_1 timing_1
end type
global salesdemo salesdemo

forward prototypes
public function integer of_getserviceurl ()
public function integer of_authorization ()
end prototypes

public function integer of_getserviceurl ();String ls_file

ls_file = "apisetup.ini"

IF Not FileExists(ls_file) Then
	MessageBox("Error", "Apisetup.ini does not exist.")
Else
	gs_host = "http://" + Trim(ProfileString(ls_file, "Setup", "URL", ""))	
End IF

IF Isnull(gs_host) OR gs_host = '' Then Return -1
Return 1
end function

public function integer of_authorization ();String  ls_theme, ls_postdata, ls_Token
Integer li_return
JsonParser  ljson_Parser
ljson_Parser =Create JsonParser

ls_postdata = '{"Username":"alice","Password":"alice"}'
li_return = gnv_RestClient.getjwttoken(gs_host + "/connect/token", ls_postdata, ls_Token)
gnv_restclient.clearrequestheaders()
gnv_restclient.setrequestheader("Content-Type","application/json")
If li_return = 1 Then
	//in this example, the token server returns a JSON string which contains token, therefore, gets the token via the following scripts
	ljson_Parser.Loadstring( ls_Token)
	If Pos ( ls_Token, "access_token" ) > 0 Then 
		gs_token = ljson_Parser.GetItemString( "/access_token" )
		//Set Global Variables
 		gl_Expiresin = Long (ljson_Parser.GetItemNumber("/expires_in"))

		//Sets the JWT token
		gnv_restclient.clearrequestheaders()
 		gnv_RestClient.SetJwtToken( gs_token)
		gnv_restclient.setrequestheader("Content-Type", "application/json",True)
	Else
		MessageBox("Token", "Get JWT Token Failed!")
	End If
 Else
	//MessageBox(String(gnv_restclient.getresponsestatuscode()), gnv_restclient.getresponsestatustext())
	
End If

Destroy ( ljson_Parser )

Return 1
end function

on salesdemo.create
appname="salesdemo"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
this.timing_1=create timing_1
end on

on salesdemo.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
destroy(this.timing_1)
end on

event open;String  ls_theme

gnv_RestClient = Create RestClient

//Check Evergreen WebView2 Runtime Installed
If f_chk_webview_installed() = -1 Then
              Return
End If

ls_theme = ProfileString("apisetup.ini", "Setup", "Theme", "Flat Design Blue")
IF ls_theme <> "Do Not Use Themes" THEN
	applytheme(GetCurrentDirectory( ) + "\Theme\" + ls_theme)
END IF

gs_host = "http://" + Trim(ProfileString("apisetup.ini", "Setup", "URL", ""))	

If Len(gs_host) < 10 Then
	Open(w_Setup)
	gs_host = "http://" + Trim(ProfileString("apisetup.ini", "Setup", "URL", ""))	
End If

//Authorization
If of_Authorization() <> 1 Then
 Return
End If

//Refresh Token for timing
If gl_Expiresin > 0 And (gl_Expiresin - gl_ClockSkew) > 0 Then
 timing_1.Start(gl_Expiresin - gl_ClockSkew)
End If


open(w_main)

end event

event systemerror;Choose Case error.Number
        Case 220  to 229 //Session Error
                 MessageBox ("Session Error", "Number:" + String(error.Number) + "~r~nText:" + error.Text )
        Case 230  to 239 //License Error
                 MessageBox ("License Error", "Number:" + String(error.Number) + "~r~nText:" + error.Text )
        Case 240  to 249 //Token Error
                 MessageBox ("Token Error", "Number:" + String(error.Number) + "~r~nText:" + error.Text )
        Case Else
                 MessageBox ("SystemError", "Number:" + String(error.Number) + "~r~nText:" + error.Text )
End Choose

end event

event close;
If Isvalid ( gnv_RestClient ) Then DesTroy ( gnv_RestClient )
end event

type timing_1 from timing within salesdemo descriptor "pb_nvo" = "true" 
end type

event timer;//
of_Authorization()
end event

on timing_1.create
call super::create
TriggerEvent( this, "constructor" )
end on

on timing_1.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

