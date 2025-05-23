Attribute VB_Name = "ModSettings"
'    Argentum 20 - Game Client Program
'    Copyright (C) 2022 - Noland Studios
'
'    This program is free software: you can redistribute it and/or modify
'    it under the terms of the GNU Affero General Public License as published by
'    the Free Software Foundation, either version 3 of the License, or
'    (at your option) any later version.
'
'    This program is distributed in the hope that it will be useful,
'    but WITHOUT ANY WARRANTY; without even the implied warranty of
'    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'    GNU Affero General Public License for more details.
'    You should have received a copy of the GNU Affero General Public License
'    along with this program.  If not, see <https://www.gnu.org/licenses/>.
'
'
Option Explicit

Const CustomSettingsFile As String = "\..\Recursos\OUTPUT\Configuracion.ini"
Const DefaultSettingsFile As String = "\..\Recursos\OUTPUT\DefaultSettings.ini"
Const HotKeySettingsFile As String = "\..\Recursos\OUTPUT\Hotkeys.ini"

Public Function InitializeSettings() As Boolean
    
    If Not FileExist(App.path & DefaultSettingsFile, vbArchive) Then
        InitializeSettings = False
        Call MsgBox(JsonLanguage.Item("MENSAJEBOX_ARCHIVO_NO_ENCONTRADO") & App.path & DefaultSettingsFile, vbInformation + vbOKOnly, JsonLanguage.Item("MENSAJEBOX_ADVERTENCIA"))
        Exit Function
    End If
    
    If Not FileExist(App.path & CustomSettingsFile, vbArchive) Then
        Call FileSystem.FileCopy(App.path & DefaultSettingsFile, App.path & CustomSettingsFile)
    End If
    InitializeSettings = True
End Function


Public Function GetSetting(ByVal Section As String, ByVal Name As String) As String
    Dim currentValue As String
    currentValue = GetVar(App.path & CustomSettingsFile, Section, Name)
    If currentValue = "" Then
        currentValue = GetVar(App.path & DefaultSettingsFile, Section, Name)
    End If
    GetSetting = currentValue
End Function

Public Function GetSettingAsByte(ByVal Section As String, ByVal Name As String, ByVal DefaultValue As Byte) As Byte
On Error GoTo GetSettingAsByteErr:
    GetSettingAsByte = DefaultValue
    Dim Value As String
    Value = GetSetting(Section, Name)
    If Value = "" Then Exit Function
    GetSettingAsByte = CByte(Value)
    Exit Function
GetSettingAsByteErr:
    
    Call LogError("Error in GetSettingAsByte Section: " & Section & " Name: " & Name & " Actual value: " & Value)

    GetSettingAsByte = DefaultValue
End Function

Public Sub SaveSetting(ByVal Section As String, ByVal Name As String, ByVal Value As String)
    Call WriteVar(App.path & CustomSettingsFile, Section, Name, Value)
End Sub

Public Sub LoadHotkeys()
    Dim i As Integer
    Call ClearHotkeys
    Dim FilePath As String
    FilePath = App.path & HotKeySettingsFile
    If Not FileExist(FilePath, vbArchive) Then
        Exit Sub
    End If
    
    For i = 0 To HotKeyCount - 1
        HotkeyList(i).Index = Val(GetVar(FilePath, UserName, "BindIndex" & i))
        HotkeyList(i).LastKnownSlot = Val(GetVar(FilePath, UserName, "LastSlot" & i))
        HotkeyList(i).Type = Val(GetVar(FilePath, UserName, "Type" & i))
        Call WriteSetHotkeySlot(i, HotkeyList(i).Index, HotkeyList(i).LastKnownSlot, HotkeyList(i).Type)
    Next i
    HideHotkeys = Val(GetVar(FilePath, UserName, "HideHotkeys"))
End Sub

Public Sub SaveHotkey(ByVal Index As Integer, ByVal LastKnownSlot As Integer, ByVal HotkeyType As e_HotkeyType, ByVal HotkeySlot As Integer)
    Dim FilePath As String
    FilePath = App.path & HotKeySettingsFile
    Call General_Var_Write(FilePath, UserName, "BindIndex" & HotkeySlot, Index)
    Call General_Var_Write(FilePath, UserName, "LastSlot" & HotkeySlot, LastKnownSlot)
    Call General_Var_Write(FilePath, UserName, "Type" & HotkeySlot, HotkeyType)
End Sub

Public Sub SaveHideHotkeys()
    Dim FilePath As String
    FilePath = App.path & HotKeySettingsFile
    Call General_Var_Write(FilePath, UserName, "HideHotkeys", IIf(HideHotkeys, 1, 0))
End Sub
