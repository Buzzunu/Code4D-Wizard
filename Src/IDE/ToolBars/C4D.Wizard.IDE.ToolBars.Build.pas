unit C4D.Wizard.IDE.ToolBars.Build;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,
  Winapi.Windows,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  ToolsAPI;

type
  TC4DWizardIDEToolBarsBuild = class
  private
    FINTAServices: INTAServices;
    FToolBarBuild: TToolBar;
    FToolButtonBuildAllGroup: TToolButton;
    FToolButtonBuildInRelease: TToolButton;
    FToolButtonRefresh: TToolButton;
    FComboBox: TComboBox;
    procedure NewToolBarBuild;
    procedure OnC4DToolButtonBuildRefreshClick(Sender: TObject);
    procedure OnC4DToolButtonBuildInReleaseClick(Sender: TObject);
    procedure RemoveToolBarBuild;
    procedure AddButtonRefreshBuild;
    procedure AddButtonBuildInRelease;
    procedure AddComboBoxBuild;
    procedure FillComboBoxBuild;
    function GetReferenceToolBar: string;
    function GetIniFile: TIniFile;
    procedure ComboBoxClick(Sender: TObject);
    procedure AddButtonBuildAllGroup;
    procedure OnC4DToolButtonBuildAllGroupClick(Sender: TObject);
  protected
    constructor Create;
  public
    destructor Destroy; override;
    function ProcessRefreshComboBox(const AForceRefresh: Boolean = False): string;
    procedure SetVisibleInINI(AVisible: Boolean);
    function GetVisibleInINI: Boolean;
  end;

var
  C4DWizardIDEToolBarsBuild: TC4DWizardIDEToolBarsBuild;

procedure RegisterSelf;

implementation

uses
  C4D.Wizard.Consts,
  C4D.Wizard.Utils,
  C4D.Wizard.Utils.OTA,
  C4D.Wizard.IDE.ImageListMain;

const
  BUILD_STR_EMPTY = '';
  BUILD_STR_Debug = 'Debug';
  BUILD_STR_Release = 'Release';

procedure RegisterSelf;
begin
  if(not Assigned(C4DWizardIDEToolBarsBuild))then
    C4DWizardIDEToolBarsBuild := TC4DWizardIDEToolBarsBuild.Create;

  C4DWizardIDEToolBarsBuild.ProcessRefreshComboBox;
end;

constructor TC4DWizardIDEToolBarsBuild.Create;
begin
  FINTAServices := TC4DWizardUtilsOTA.GetINTAServices;
  Self.NewToolBarBuild;
  Self.ProcessRefreshComboBox;
end;

destructor TC4DWizardIDEToolBarsBuild.Destroy;
begin
  Self.RemoveToolBarBuild;
  inherited;
end;

function TC4DWizardIDEToolBarsBuild.GetIniFile: TIniFile;
begin
  Result := TIniFile.Create(TC4DWizardUtils.GetPathFileIniGeneralSettings);
end;

procedure TC4DWizardIDEToolBarsBuild.SetVisibleInINI(AVisible: Boolean);
begin
  Self.GetIniFile.WriteBool(TC4DConsts.C_TOOL_BAR_BUILD_NAME,
    TC4DConsts.C_TOOL_BAR_BUILD_INI_Visible,
    AVisible);
  if(AVisible)then
    Self.ProcessRefreshComboBox(True);
end;

function TC4DWizardIDEToolBarsBuild.GetVisibleInINI: Boolean;
begin
  Result := Self.GetIniFile.ReadBool(TC4DConsts.C_TOOL_BAR_BUILD_NAME,
    TC4DConsts.C_TOOL_BAR_BUILD_INI_Visible,
    True);
end;

function TC4DWizardIDEToolBarsBuild.GetReferenceToolBar: string;
var
  LStandardToolBar: TToolBar;
  LControlBar: TControlBar;
  LControl: TControl;
  i: integer;
  LBiggerLeft: integer;
begin
  Result := sBrowserToolbar;

  if(FINTAServices.ToolBar[TC4DConsts.C_TOOL_BAR_BRANCH_NAME] <> nil)then
    Result := TC4DConsts.C_TOOL_BAR_BRANCH_NAME;

  LStandardToolBar := FINTAServices.ToolBar[sStandardToolBar];
  if(not Assigned(LStandardToolBar))then
    Exit;
  LControlBar := LStandardToolBar.Parent as TControlBar;

  LBiggerLeft := 0;
  for i := 0 to Pred(LControlBar.ControlCount) do
  begin
    LControl := LControlBar.Controls[i];
    if(LControl.Visible)and(LControl.Left > LBiggerLeft)then
    begin
      Result := LControl.Name;
      LBiggerLeft := LControl.Left;
    end;
  end;
end;

procedure TC4DWizardIDEToolBarsBuild.NewToolBarBuild;
begin
  Self.RemoveToolBarBuild;
  FToolBarBuild := FINTAServices.NewToolbar(TC4DConsts.C_TOOL_BAR_BUILD_NAME,
    TC4DConsts.C_TOOL_BAR_BUILD_CAPTION,
    Self.GetReferenceToolBar,
    True);
  FToolBarBuild.Visible := False;
  FToolBarBuild.Flat := True;
  FToolBarBuild.Images := TC4DWizardUtilsOTA.GetINTAServices.ImageList;
  FToolBarBuild.ShowCaptions := False;
  FToolBarBuild.AutoSize := True;

  Self.AddButtonBuildAllGroup;
  Self.AddButtonBuildInRelease;
  Self.AddButtonRefreshBuild;
  Self.AddComboBoxBuild;
  Self.FillComboBoxBuild;
  FToolBarBuild.Visible := Self.GetVisibleInINI;
end;

procedure TC4DWizardIDEToolBarsBuild.RemoveToolBarBuild;
var
  i: integer;
begin
  FToolBarBuild := FINTAServices.ToolBar[TC4DConsts.C_TOOL_BAR_BUILD_NAME];
  if(Assigned(FToolBarBuild))then
  begin
    for i := Pred(FToolBarBuild.ButtonCount) DownTo 0 do
      FToolBarBuild.Buttons[i].Free;
    FreeAndNil(FToolBarBuild);
  end;
end;

procedure TC4DWizardIDEToolBarsBuild.AddButtonBuildAllGroup;
begin
  FToolButtonBuildAllGroup := TToolButton(FToolBarBuild.FindComponent(TC4DConsts.C_TOOL_BAR_BUILD_TOOL_BUTTON_BuildAllGroup_NAME));
  if(FToolButtonBuildAllGroup <> nil)then
    FToolButtonBuildAllGroup.Free;

  FToolButtonBuildAllGroup := TToolButton.Create(FToolBarBuild);
  FToolButtonBuildAllGroup.Parent := FToolBarBuild;
  FToolButtonBuildAllGroup.Caption := 'Build all group projects';
  FToolButtonBuildAllGroup.Hint := FToolButtonBuildAllGroup.Caption;
  FToolButtonBuildAllGroup.ShowHint := True;
  FToolButtonBuildAllGroup.Name := TC4DConsts.C_TOOL_BAR_BUILD_TOOL_BUTTON_BuildAllGroup_NAME;
  FToolButtonBuildAllGroup.Style := tbsButton;
  FToolButtonBuildAllGroup.ImageIndex := TC4DWizardIDEImageListMain.GetInstance.ImgIndexBuildGroup;
  FToolButtonBuildAllGroup.Visible := True;
  FToolButtonBuildAllGroup.Left := 0;
  FToolButtonBuildAllGroup.OnClick := OnC4DToolButtonBuildAllGroupClick;
  FToolButtonBuildAllGroup.AutoSize := True;
end;

procedure TC4DWizardIDEToolBarsBuild.AddButtonBuildInRelease;
begin
  FToolButtonBuildInRelease := TToolButton(FToolBarBuild.FindComponent(TC4DConsts.C_TOOL_BAR_BUILD_TOOL_BUTTON_BuildInRelease_NAME));
  if(FToolButtonBuildInRelease <> nil)then
    FToolButtonBuildInRelease.Free;

  FToolButtonBuildInRelease := TToolButton.Create(FToolBarBuild);
  FToolButtonBuildInRelease.Parent := FToolBarBuild;
  FToolButtonBuildInRelease.Caption := 'Build Project In Release';
  FToolButtonBuildInRelease.Hint := FToolButtonBuildInRelease.Caption;
  FToolButtonBuildInRelease.ShowHint := True;
  FToolButtonBuildInRelease.Name := TC4DConsts.C_TOOL_BAR_BUILD_TOOL_BUTTON_BuildInRelease_NAME;
  FToolButtonBuildInRelease.Style := tbsButton;
  FToolButtonBuildInRelease.ImageIndex := TC4DWizardIDEImageListMain.GetInstance.ImgIndexPlayBlue;
  FToolButtonBuildInRelease.Visible := True;
  FToolButtonBuildInRelease.Left := FToolButtonBuildAllGroup.Left + FToolButtonBuildAllGroup.Width;
  FToolButtonBuildInRelease.OnClick := OnC4DToolButtonBuildInReleaseClick;
  FToolButtonBuildInRelease.AutoSize := True;
end;

procedure TC4DWizardIDEToolBarsBuild.AddButtonRefreshBuild;
begin
  FToolButtonRefresh := TToolButton(FToolBarBuild.FindComponent(TC4DConsts.C_TOOL_BAR_BUILD_TOOL_BUTTON_REFRESH_NAME));
  if(FToolButtonRefresh <> nil)then
    FToolButtonRefresh.Free;

  FToolButtonRefresh := TToolButton.Create(FToolBarBuild);
  FToolButtonRefresh.Parent := FToolBarBuild;
  FToolButtonRefresh.Caption := 'Get Current Build Configuration';
  FToolButtonRefresh.Hint := FToolButtonRefresh.Caption;
  FToolButtonRefresh.ShowHint := True;
  FToolButtonRefresh.Name := TC4DConsts.C_TOOL_BAR_BUILD_TOOL_BUTTON_REFRESH_NAME;
  FToolButtonRefresh.Style := tbsButton;
  FToolButtonRefresh.ImageIndex := TC4DWizardIDEImageListMain.GetInstance.ImgIndexRefresh;
  FToolButtonRefresh.Visible := True;
  FToolButtonRefresh.Left := FToolButtonBuildInRelease.Left + FToolButtonBuildInRelease.Width;
  FToolButtonRefresh.OnClick := OnC4DToolButtonBuildRefreshClick;
  FToolButtonRefresh.AutoSize := True;
end;

procedure TC4DWizardIDEToolBarsBuild.AddComboBoxBuild;
begin
  FComboBox := TComboBox(FToolBarBuild.FindComponent(TC4DConsts.C_TOOL_BAR_BUILD_COMBOBOX_NAME));
  if(FComboBox <> nil)then
    FComboBox.Free;

  FComboBox := TComboBox.Create(FToolBarBuild);
  FComboBox.Parent := FToolBarBuild;
  FComboBox.Hint := 'Alter Build Configuration';
  FComboBox.ShowHint := True;
  FComboBox.Name := TC4DConsts.C_TOOL_BAR_BUILD_COMBOBOX_NAME;
  FComboBox.Style := csDropDownList;
  FComboBox.Width := 80;
  FComboBox.OnClick := Self.ComboBoxClick;

  FComboBox.Left := 0;
  if(FToolBarBuild.ButtonCount > 0)then
    FComboBox.Left := FToolBarBuild.Buttons[Pred(FToolBarBuild.ButtonCount)].Width +
      FToolBarBuild.Buttons[Pred(FToolBarBuild.ButtonCount)].Left;
end;

procedure TC4DWizardIDEToolBarsBuild.FillComboBoxBuild;
begin
  if(FComboBox = nil)then
    Exit;

  FComboBox.Items.Clear;
  FComboBox.Items.Add(BUILD_STR_EMPTY);
  FComboBox.Items.Add(BUILD_STR_Debug);
  FComboBox.Items.Add(BUILD_STR_Release);
end;

procedure TC4DWizardIDEToolBarsBuild.OnC4DToolButtonBuildRefreshClick(Sender: TObject);
begin
  Self.ProcessRefreshComboBox;
end;

procedure TC4DWizardIDEToolBarsBuild.OnC4DToolButtonBuildAllGroupClick(Sender: TObject);
var
  LIOTAProjectGroup: IOTAProjectGroup;
  LContProjetos: integer;
  LIOTAProject: IOTAProject;
  LClearMessages: Boolean;
begin
  LIOTAProjectGroup := (BorlandIDEServices as IOTAModuleServices).MainProjectGroup; //TC4DWizardUtilsOTA.GetCurrentProjectGroup
  if(LIOTAProjectGroup = nil)then
    raise Exception.Create('Nenhum grupo selecionado');

  LClearMessages := True;
  for LContProjetos := 0 to Pred(LIOTAProjectGroup.ProjectCount)do
  begin
    LIOTAProject := LIOTAProjectGroup.Projects[LContProjetos];
    if(not LIOTAProject.ProjectBuilder.BuildProject(cmOTABuild, True, LClearMessages))then
      Exit;
    LClearMessages := False;
  end;
end;

procedure TC4DWizardIDEToolBarsBuild.OnC4DToolButtonBuildInReleaseClick(Sender: TObject);
var
  LIOTAProject: IOTAProject;
  LBuildConfCurrent: string;
  LCurrentBinaryPath: string;
begin
  LIOTAProject := TC4DWizardUtilsOTA.GetCurrentProject;
  if(LIOTAProject = nil)then
    Exit;

  if(ExtractFileName(LIOTAProject.FileName) = TC4DConsts.C_C4D_WIZARD_DPROJ)then
    TC4DWizardUtils.ShowMsgAndAbort('It is not possible to build in project: ' + TC4DConsts.C_C4D_WIZARD_DPROJ);

  LCurrentBinaryPath := TC4DWizardUtilsOTA.GetBinaryPathCurrent;
  if(FileExists(LCurrentBinaryPath))then
  begin
    if(TC4DWizardUtils.ProcessWindowsExists(ExtractFileName(LCurrentBinaryPath), LCurrentBinaryPath))then
    begin
      if(not TC4DWizardUtils.ShowQuestion('The application is already running, do you wish to continue?'))then
        Exit;

      //PostMessage(FindWindow(nil, PWideChar(LCurrentBinaryPath)), WM_QUIT, 0, 0);
    end;
  end;

  LBuildConfCurrent := LIOTAProject.CurrentConfiguration;
  try
    LIOTAProject.CurrentConfiguration := TC4DConsts.C_BUILD_RELEASE;
    Self.ProcessRefreshComboBox;
    LIOTAProject
      .ProjectBuilder
      .BuildProject(cmOTABuild, True, True);
  finally
    LIOTAProject.CurrentConfiguration := LBuildConfCurrent;
    Self.ProcessRefreshComboBox;
  end;
end;

function TC4DWizardIDEToolBarsBuild.ProcessRefreshComboBox(const AForceRefresh: Boolean = False): string;
var
  LIOTAProject: IOTAProject;
  LCurrentConfiguration: string;
begin
  if(FComboBox = nil)then
    Exit;

  FComboBox.Text := BUILD_STR_EMPTY;
  if(not AForceRefresh)and(not FToolBarBuild.Visible)then
    Exit;

  Sleep(200);
  LIOTAProject := TC4DWizardUtilsOTA.GetCurrentProject;
  if(LIOTAProject = nil)then
    Exit;

  LCurrentConfiguration := LIOTAProject.CurrentConfiguration;
  if(LCurrentConfiguration = BUILD_STR_Debug)then
    FComboBox.ItemIndex := FComboBox.Items.IndexOf(BUILD_STR_Debug)
  else if(LCurrentConfiguration = BUILD_STR_Release)then
    FComboBox.ItemIndex := FComboBox.Items.IndexOf(BUILD_STR_Release);
end;

procedure TC4DWizardIDEToolBarsBuild.ComboBoxClick(Sender: TObject);
var
  LIOTAProject: IOTAProject;
  LCurrentConfiguration: string;
begin
  LIOTAProject := TC4DWizardUtilsOTA.GetCurrentProject;
  if(LIOTAProject = nil)then
    Exit;

  LCurrentConfiguration := LIOTAProject.CurrentConfiguration;
  if(FComboBox.Text = LCurrentConfiguration)then
    Exit;

  LIOTAProject.CurrentConfiguration := FComboBox.Text;
end;

initialization

finalization
  if(Assigned(C4DWizardIDEToolBarsBuild))then
    FreeAndNil(C4DWizardIDEToolBarsBuild);

end.
