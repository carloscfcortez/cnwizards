{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2015 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnTestFormatterWizard;
{ |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包测试用例
* 单元名称：测试代码格式化功能的测试用例单元
* 单元作者：CnPack 开发组
* 备    注：测试 CnCppCodeParser 中 ParseCppCodePosInfo 以查看是否获得了光标
            所在处的位置类型。运行时当前正在打开 C/C++ 文件即可测试。
* 开发平台：WinXP + BCB 5/6
* 兼容测试：PWin9X/2000/XP + C++Builder 5/6
* 本 地 化：该窗体中的字符串暂不支持本地化处理方式
* 单元标识：$Id: CnTestFormatterWizard.pas 1146 2012-10-24 06:25:41Z liuxiaoshanzhashu@gmail.com $
* 修改记录：2015.02.12 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts, CnFormatterIntf;

type

//==============================================================================
// 测试加载 DLL 并进行格式化工作的菜单专家
//==============================================================================

{ TCnTestFormatterWizard }

  TCnTestFormatterWizard = class(TCnMenuWizard)
  private
    FHandle: THandle;
    FGetProvider: TCnGetFormatterProvider;
  protected
    function GetHasConfig: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
  end;

implementation

uses
  CnDebug, CnCommon;

const
  DLLName: string = 'CnFormatLib.dll';

function ModulePath: string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ModName, GetModuleFileName(HInstance, ModName, SizeOf(ModName)));
  Result := _CnExtractFilePath(Result);
end;

//==============================================================================
// 测试加载 DLL 并进行格式化工作的菜单专家
//==============================================================================

{ TCnTestFormatterWizard }

procedure TCnTestFormatterWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

constructor TCnTestFormatterWizard.Create;
begin
  inherited;

end;

destructor TCnTestFormatterWizard.Destroy;
begin
  if FHandle <> 0 then
  begin
    FreeLibrary(FHandle);
    FHandle := 0;
  end;
  inherited;
end;

procedure TCnTestFormatterWizard.Execute;
var
  S: AnsiString;
  Res: PAnsiChar;
  Formatter: ICnPascalFormatterIntf;
  ErrCode, SourceLine, SourcePos: Integer;
  CurrentToken: PAnsiChar;
begin
  if FHandle = 0 then
    FHandle := LoadLibrary(PChar(ModulePath + DLLName));
   
  if FHandle = 0 then
  begin
    ShowMessage('No DLL Found.');
    Exit;
  end;

  if not Assigned(FGetProvider) then
    FGetProvider := TCnGetFormatterProvider(GetProcAddress(FHandle, 'GetCodeFormatterProvider'));
  if not Assigned(FGetProvider) then
  begin
    FreeLibrary(FHandle);
    FHandle := 0;
    ShowMessage('No Provider Found.');
    Exit;
  end;

  Formatter := FGetProvider();
  if Formatter = nil then
  begin
    FGetProvider := nil;
    FreeLibrary(FHandle);
    FHandle := 0;
    ShowMessage('No Formatter Found.');
    Exit;
  end;

  try
    S := AnsiString(CnOtaGetCurrentEditorSource);
    Res := Formatter.FormatOnePascalUnit(PAnsiChar(S), Length(S));

    if Res <> nil then
    begin
      ShowMessage(Res);
      CnOtaSetCurrentEditorSource(string(Res));
    end
    else
    begin
      ErrCode := Formatter.RetrievePascalLastError(SourceLine, SourcePos, CurrentToken);
      ShowMessage(Format('Error Code %d, Line %d, Pos %d, Token %s', [ErrCode,
        SourceLine, SourcePos, CurrentToken]));
    end;
  finally
    Formatter := nil;
  end;
end;

function TCnTestFormatterWizard.GetCaption: string;
begin
  Result := 'Test Formatter';
end;

function TCnTestFormatterWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestFormatterWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestFormatterWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestFormatterWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestFormatterWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Formatter Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Formatterusing DLL.';
end;

procedure TCnTestFormatterWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestFormatterWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTestFormatterWizard); // 注册此测试专家

end.
