program TDI;

uses
  Vcl.Forms,
  UFrmPrincipal in 'UFrmPrincipal.pas' {FrmPrincipal},
  UTDI in 'UTDI.pas',
  UFrmClientes in 'UFrmClientes.pas' {FrmClientes},
  UFrmFornecedores in 'UFrmFornecedores.pas' {FrmFornecedores};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
