{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2018 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ���������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnIDEMirrorIntf;
{* |<PRE>
================================================================================
* �������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�IDE �ӿھ���Ԫ�����ڶ�̬���� IDE �ӿڵĳ���
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע���õ�Ԫ�ṩ�� IDE �Ĳ��� ToolsAPI �ӿڵľ���������
* ����ƽ̨��PWin2000Pro + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�������ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2018.06.09
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  SysUtils, Classes, Windows, Forms, ToolsAPI {$IFDEF DELPHI102_TOKYO}, Themes {$ENDIF};

{$IFDEF DELPHI102_TOKYO}

{
  Delphi 10.2.2 �� IDE ��ʼ֧�����⣬�� 10.2.3 �в��� ToolsAPI ���ṩ����ӿڣ�
  �������˷ѽ���� 10.2.2 �� 10.2.3 �����������ṩ���֣����ר�Ұ�Ҫ֧�����⡢
  �� 10.2.3 ����ʱ��ʹ�� 10.2.3 ToolsAPI �е�������������صĽӿڣ�����ר�Ұ�
  �� 10.2.0/1/2 ��ʹ��ʱ����ֶ�̬���ӿ��еĺ����Ҳ��������⡣

  Ϊ�˶��������⣬����Ԫ���³��ֵĽӿڶ�����дһ��ͬ���Ķ��壬���ڲ�ѯʱ��
  ʹ�� 10.2.3 �������ӿڵ� GUID�������ܲ�ѯ���ӿڣ�Ȼ�󰵵���ǿ��ת��������
  ����Ľӿڣ������ճ������ˡ��� 10.2.0/1/2 �����°汾����Щ�ӿ��ǲ�ѯ�����ġ�

  ���⣬�½ӿ�������������ã������Ƿ������ Service ��ͷ�� Notifier ֪ͨ��
  ��Ҫ�޸ķ�д�Ľӿ��е����ýӿ�����ͬ�����ɷ�д�Ľӿڡ�

  �� IDE �ڲ��������� Notifier ʱ���鴫��� Notifier �Ƿ���ָ���ӿڣ�����
  ��������Ƿ�д�ӿڣ���������Ը������������д�˸� ChangeIntfGUID�����Խ�
  ĳ����ʵ�ֵ�ָ���ӿڵ� GUID �滻��ָ�� GUID����ƭ�� IDE �ļ�顣
}

const
  GUID_INTAIDETHEMINGSERVICESNOTIFIER = '{4CBFAA40-89E6-412C-B667-9034666E2931}';
  GUID_IOTAIDETHEMINGSERVICES = '{DEAD2647-9B2C-4084-A61E-1E69A9179637}';
  GUID_IOTAIDETHEMINGSERVICES250 = '{DEAD2648-9B21-4084-771E-1E69A9176637}';

type
  ICnNTAIDEThemingServicesNotifier = interface(IOTANotifier)
  ['{46949416-FD06-4B49-A43F-1C7A4A760B32}']
    procedure ChangingTheme();
    procedure ChangedTheme();
  end;

  ICnOTAIDEThemingServices = interface(IInterface)
    function AddNotifier(const ANotifier: ICnNTAIDEThemingServicesNotifier): Integer;
    procedure RemoveNotifier(Index: Integer);
    function GetActiveThemeName: string;
    function GetIDEStyleServices: TCustomStyleServices;
    function GetIDEThemingEnabled: Boolean;
    procedure ApplyTheme(AComponent: TComponent);
    function GetEditorColorSpeedSetting(const ThemeName: string): string;
    function GetOIColorSpeedSetting(const ThemeName: string): string;
    property StyleServices: TCustomStyleServices read GetIDEStyleServices;
    property ActiveTheme: string read GetActiveThemeName;
    property IDEThemingEnabled: Boolean read GetIDEThemingEnabled;
  end;

  ICnOTAIDEThemingServices250 = interface(ICnOTAIDEThemingServices)
    procedure RegisterFormClass(AFormClass : TCustomFormClass);
  end;

{$ENDIF}

function ChangeIntfGUID(AClass: TClass; const OldGUID, NewGUID: TGUID): Boolean;

implementation

resourcestring
  SMemoryWriteError = 'Error Writing Interface Table Memory (%s).';

function ChangeIntfGUID(AClass: TClass; const OldGUID, NewGUID: TGUID): Boolean;
var
  I: Integer;
  IntfTable: PInterfaceTable;
  IntfEntry: PInterfaceEntry;
  OldProtection, DummyProtection: DWORD;
begin
  Result := False;
  IntfTable := AClass.GetInterfaceTable;
  if IntfTable <> nil then
  begin
    for I := 0 to IntfTable.EntryCount-1 do
    begin
      IntfEntry := @IntfTable.Entries[I];
      if CompareMem(@IntfEntry^.IID, @OldGUID, SizeOf(TGUID)) then
      begin
        if not VirtualProtect(@IntfEntry^.IID, SizeOf(TGUID), PAGE_EXECUTE_READWRITE, @OldProtection) then
          raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);

        try
          IntfEntry^.IID := NewGUID;
        finally
          if not VirtualProtect(@IntfEntry^.IID, SizeOf(TGUID), OldProtection, @DummyProtection) then
            raise Exception.CreateFmt(SMemoryWriteError, [SysErrorMessage(GetLastError)]);
        end;

        Result := True;
        Exit;
      end;
    end;
  end;
end;

end.