// ------------------------------------------------------------------------------
unit DPF.Android.JTabHost.DesignTime;

interface

{$I DPF.Android.Defs.inc}

uses
  System.SysUtils,

{$IFDEF IOS}
  DPF.Android.Common;
{$ELSE}
  DesignEditors, DesignIntf;
{$ENDIF}

{$IFNDEF IOS}

type
  // ----------------------------------------------------------------------------
  TDPFJTabHostActivePageIndexProperty = class( TStringProperty )
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure SetValue( const value: string ); override;
    function GetValue: string; override;
  end;

  TAndroidTabBarControllerEditor = class( TComponentEditor )
  public
    procedure ExecuteVerb( Index: Integer ); override;
    function GetVerb( Index: Integer ): string; override;
    function GetVerbCount: Integer; override;
  end;

  // ----------------------------------------------------------------------------
{$ENDIF}

  // ------------------------------------------------------------------------------

implementation

uses

  System.Classes,
  //System.Types,
  //System.UITypes,
  //System.Variants,
  System.TypInfo,
{$IFDEF WIN32}
  Windows, ToolsAPI,
{$ENDIF}
  FMX.Layouts, FMX.Memo,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  DPF.Android.JTabHost;

type
  // ----------------------------------------------------------------------------
  IFormDesigner = IDesigner;
  TFormDesigner = IFormDesigner;

const
  TabBarControllerVerbs: array [0 .. 2] of string = ( 'New Page', 'Next Page', 'Previous Page' );

{$IFNDEF IOS}
// ------------------------------------------------------------------------------
{ TAndroidTabBarControllerEditor }

procedure TAndroidTabBarControllerEditor.ExecuteVerb( Index: Integer );
var
  PageControl: TDPFJTabHost;
  Page       : TDPFAndroidTabBarItem;
  Designer   : TFormDesigner;
begin
  if Component is TDPFAndroidTabBarItem then
  begin
    PageControl := TDPFAndroidTabBarItem( Component ).PageControl;
  end
  else
  begin
    PageControl := TDPFJTabHost( Component );
  end;

  // if ( PageControl is TDPFJTabHost ) and ( index = 0 ) then exit;

  if PageControl <> nil then
  begin
    Designer := Self.Designer;
    if index = 0 then
    begin
      Page := TDPFAndroidTabBarItem.Create( Designer.Root );
      try
        Page.Name        := Designer.UniqueName( System.copy( TDPFAndroidTabBarItem.ClassName, 2, MaxInt ) );
        Page.Parent      := PageControl;
        Page.PageControl := PageControl;
        PageControl.AddObject( Page );
      except
        Page.DisposeOf;
        raise;
      end;
      PageControl.ActivePage := Page;
      Page.BringToFront;
      Designer.SelectComponent( Page );
      Designer.Modified;
    end
    else
    begin
      { Page := PageControl.FindNextPage( PageControl.ActivePage, index = 1, False );
        if ( Page <> nil ) and ( Page <> PageControl.ActivePage ) then
        begin
        PageControl.ActivePage := Page;
        if Component is TDPFAndroidTabBarItem then
        Designer.SelectComponent( Page );
        Designer.Modified;
        end; }
    end;
    TDPFJTabHost( PageControl ).Change;
  end;
end;

// ------------------------------------------------------------------------------
function TAndroidTabBarControllerEditor.GetVerb( Index: Integer ): string;
begin
  result := TabBarControllerVerbs[index];
end;

// ------------------------------------------------------------------------------
function TAndroidTabBarControllerEditor.GetVerbCount: Integer;
begin
  result := 1;
end;

// ------------------------------------------------------------------------------
{ TDPFJTabHostActivePageIndexProperty }
function TDPFJTabHostActivePageIndexProperty.GetAttributes: TPropertyAttributes;
begin
  result := inherited GetAttributes + [paValueEditable];
end;

// ------------------------------------------------------------------------------
function TDPFJTabHostActivePageIndexProperty.GetValue: string;
var
  C: TDPFJTabHost;
begin
  C      := TComponent( Self.GetComponent( 0 ) ) as TDPFJTabHost;
  result := IntToSTr( C.ActivePageIndex );
end;

// ------------------------------------------------------------------------------
procedure TDPFJTabHostActivePageIndexProperty.SetValue( const value: string );
var
  C: TDPFJTabHost;
begin
  inherited;
  C := TComponent( Self.GetComponent( 0 ) ) as TDPFJTabHost;
  if ( C as TDPFJTabHost ).ActivePageIndex = StrToInt( value ) then
    Exit;
  ( C as TDPFJTabHost ).ActivePageIndex := StrToInt( value );

  if ( C as TDPFJTabHost ).ActivePageIndex <> -1 then
  begin
    Designer.SelectComponent( C.ActivePage );
    ( C as TDPFJTabHost ).ActivePage.BringToFront;
  end;
  Designer.Modified;
end;
{$ENDIF}

end.
