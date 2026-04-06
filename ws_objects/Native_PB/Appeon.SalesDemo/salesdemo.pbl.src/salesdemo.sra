$PBExportHeader$salesdemo.sra
$PBExportComments$Generated Application Object
forward
global type salesdemo from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global variables
String gs_msg_title = "Sales CRM Demo"
end variables

global type salesdemo from application
string appname = "salesdemo"
string displayname = "SalesDemo"

string themepath = "C:\Program Files (x86)\Appeon\PowerBuilder 25.0\IDE\theme"
string themename = "Flat Design Blue"
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
integer highdpimode = 0
end type
global salesdemo salesdemo

forward prototypes
public function unsignedlong hex2dec (string hex)
end prototypes

public function unsignedlong hex2dec (string hex);char hexchar[]
long i,ll,result
string hexdigitstr
char 	HEXDIGIT[] = "0123456789ABCDEF"
hexdigitstr = HEXDIGIT
hexchar = hex
ll = upperbound(hexchar)
for i = 1 to ll
	result *= 16
	result += pos(hexdigitstr,hexchar[i]) - 1
next

return result
end function

on salesdemo.create
appname="salesdemo"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on salesdemo.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;String  ls_theme

//Check Evergreen WebView2 Runtime Installed
If f_chk_webview_installed() = -1 Then
              Return
End If

ls_theme = ProfileString("config.ini", "Theme", "Theme", "Flat Design Blue")
IF ls_theme <> "Do Not Use Themes" THEN
	applytheme(GetCurrentDirectory( ) + "\Theme\" + ls_theme)
END IF

// MSOLEDBSQL SQL Server
string startupfile = "dbparam.ini"
string ls_dbparm,ls_pass,ls_intercepthex,ls_convertdec
Blob lblb_data
Blob lblb_key
Blob lblb_iv
Blob lblb_encrypt,lblb_decrypt
int i,j=0
byte lb_convertbyte[]

CrypterObject lnv_CrypterObject
lnv_CrypterObject = Create CrypterObject

SQLCA.DBMS = ProfileString(startupfile,"database","dbms","")
ls_dbparm = ProfileString(startupfile,"database","DBParm","")
if pos(ls_dbparm,'TrustedConnection=1') < 1 then
	ls_pass = Upper(ProfileString(startupfile,"database","LogPass",""))
	for i = 1 to len(ls_pass)
		ls_intercepthex = Mid(ls_pass,i,2)
		ls_convertdec =  string(Hex2Dec(ls_intercepthex))		
		if mod(i,2) <> 0 then
			j = j+1
			lb_convertbyte[j]= byte(ls_convertdec)
		end if	   	
		i = i+1
	next
	lblb_data = Blob(lb_convertbyte)  //,EncodingANSI!
	lblb_key = Blob("0cc61539135e1f89",EncodingANSI!)
	lblb_iv = Blob("",EncodingANSI!)
	lblb_decrypt = lnv_CrypterObject.SymmetricDecrypt(AES!, lblb_data, lblb_key,	OperationModeECB!, lblb_iv, PKCSPadding!)
	SQLCA.LogPass = string(lblb_decrypt,EncodingANSI!)
	SQLCA.LogId = ProfileString(startupfile,"database","LogId","")
end if
SQLCA.ServerName = ProfileString(startupfile,"database","ServerName","")


SQLCA.DBParm = ls_dbparm + ",DelimitIdentifier='YES'"
SQLCA.AutoCommit = False
Connect Using SQLCA;


if sqlca.sqlcode = 0 then
   open(w_main)
else
	messagebox('Information','Connect database fail: '+ sqlca.sqlerrtext)
end if

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

