unit UFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, UxTheme, Themes, System.Math, UTDI,
  Vcl.Menus;

type
  TFrmPrincipal = class(TForm)
    MainMenu1: TMainMenu;
    Clientes1: TMenuItem;
    Clientes2: TMenuItem;
    Fornecedores1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Clientes2Click(Sender: TObject);
    procedure Fornecedores1Click(Sender: TObject);
  private
    { Private declarations }
    FTDI: TTDI;
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

uses UFrmClientes, UFrmFornecedores;

procedure TFrmPrincipal.Clientes2Click(Sender: TObject);
begin
  FTDI.AddPage(TFrmClientes);
end;

procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FTDI.FecharTodasTabSheet;
  FTDI.Free;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  FTDI := TTDI.Create(Self);
end;

procedure TFrmPrincipal.Fornecedores1Click(Sender: TObject);
begin
  FTDI.AddPage(TFrmFornecedores);
end;

end.
