$PBExportHeader$n_cst_sys.sru
forward
global type n_cst_sys from nonvisualobject
end type
end forward

global type n_cst_sys from nonvisualobject
end type
global n_cst_sys n_cst_sys

forward prototypes
public function integer of_stringtoarray (string as_source, string as_delimiter, ref string as_array[])
public function string of_replaceall (string as_source, string as_old, string as_new, boolean ab_ignorecase)
public subroutine of_log (string as_log)
end prototypes

public function integer of_stringtoarray (string as_source, string as_delimiter, ref string as_array[]);//Parse a String using delimiter to an Array.

long		ll_DelLen, ll_Pos, ll_Count, ll_Start, ll_Length
string 	ls_holder

//Check for NULL
IF IsNull(as_source) or IsNull(as_delimiter) Then
	long ll_null
	SetNull(ll_null)
	Return ll_null
End If

//Check for at leat one entry
If Trim (as_source) = '' Then
	Return 0
End If

//Get the length of the delimeter
ll_DelLen = Len(as_Delimiter)

ll_Pos =  Pos(Upper(as_source), Upper(as_Delimiter))

//Only one entry was found
if ll_Pos = 0 then
	as_Array[1] = as_source
	return 1
end if

//More than one entry was found - loop to get all of them
ll_Count = 0
ll_Start = 1
Do While ll_Pos > 0
	
	//Set current entry
	ll_Length = ll_Pos - ll_Start
	ls_holder = Mid (as_source, ll_start, ll_length)

	// Update array and counter
	ll_Count ++
	as_Array[ll_Count] = ls_holder
	
	//Set the new starting position
	ll_Start = ll_Pos + ll_DelLen

	ll_Pos =  Pos(Upper(as_source), Upper(as_Delimiter), ll_Start)
Loop

//Set last entry
ls_holder = Mid (as_source, ll_start, Len (as_source))

// Update array and counter if necessary
if Len (ls_holder) > 0 then
	ll_count++
	as_Array[ll_Count] = ls_holder
end if

//Return the number of entries found
Return ll_Count

end function

public function string of_replaceall (string as_source, string as_old, string as_new, boolean ab_ignorecase);//Replace all occurrences of one string inside another with a new string.


Long	ll_Start
Long	ll_OldLen
Long	ll_NewLen
String ls_Source

//Check parameters
If IsNull(as_source) or IsNull(as_old) or IsNull(as_new) or IsNull(ab_ignorecase) Then
	string ls_null
	SetNull(ls_null)
	Return ls_null
End If

//Get the string lenghts
ll_OldLen = Len(as_Old)
ll_NewLen = Len(as_New)

//Should function respect case.
If ab_ignorecase Then
	as_old = Lower(as_old)
	ls_source = Lower(as_source)
Else
	ls_source = as_source
End If

//Search for the first occurrence of as_Old
ll_Start = Pos(ls_Source, as_Old)

Do While ll_Start > 0
	// replace as_Old with as_New
	as_Source = Replace(as_Source, ll_Start, ll_OldLen, as_New)
	
	//Should function respect case.
	If ab_ignorecase Then 
		ls_source = Lower(as_source)
	Else
		ls_source = as_source
	End If
	
	// find the next occurrence of as_Old
	ll_Start = Pos(ls_Source, as_Old, (ll_Start + ll_NewLen))
Loop

Return as_Source

end function

public subroutine of_log (string as_log);//Output the log to the log file.
//String ls_filename, ls_logfile
//integer li_FileNum
//
//ls_filename =  Trim(gnv_sys.of_loadini("OutputLog", ""))
//
//If ls_filename <> '' Then
//	ls_logfile = gs_currentdir + '\' + ls_filename
//	li_FileNum = FileOpen(ls_logfile,TextMode!, Write!, LockWrite!, Append!)
//	FileWriteEx(li_FileNum, String(Today(), "MM/DD/YYYY HH:MM:SS") +"~r~n"+ as_log + "~r~n~r~n~r~n")	
//	FileClose(li_FileNum)
//End If

Return 
end subroutine

on n_cst_sys.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_sys.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

