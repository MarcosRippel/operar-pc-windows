# Clica em coordenadas SO se a janela do processo alvo estiver em primeiro plano (nunca as cegas).
# Classe: Escrita (exige -Permitir Escrita). Botao de efeito irreversivel (Aplicar/Instalar/Remover/Enviar/Pagar) = Destrutiva:
# passe -Permitir Destrutiva so com confirmacao humana. ULTIMO RECURSO: prefira scripts/uia.ps1 (nao move o mouse).
# Uso: .\clicar-na-janela.ps1 -Processo MeuPainel -Cliques "86,36","150,198" -Permitir Escrita
param([Parameter(Mandatory)][string]$Processo, [Parameter(Mandatory)][string[]]$Cliques, [string]$Permitir = "")
. "$PSScriptRoot\_comum.ps1"
Confirmar-Risco -Classe Escrita -Permitir $Permitir -Acao 'clicar-por-coordenada'
Add-Type -AssemblyName System.Windows.Forms,System.Drawing
Add-Type @"
using System; using System.Runtime.InteropServices;
public class Clk { [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h); [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
 [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint x,uint y,uint d,UIntPtr e); [DllImport("user32.dll")] public static extern void keybd_event(byte vk,byte sc,uint fl,UIntPtr e);
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h,int c); [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h,int x,int y,int w,int hh,bool b); }
"@
$p = Get-Process $Processo -ErrorAction Stop | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
[Clk]::ShowWindow($p.MainWindowHandle,9) | Out-Null
[Clk]::MoveWindow($p.MainWindowHandle,0,0,880,681,$true) | Out-Null   # posicao fixa = coordenadas repetiveis
[Clk]::keybd_event(0x12,0,0,[UIntPtr]::Zero); [Clk]::keybd_event(0x12,0,2,[UIntPtr]::Zero)  # toque em Alt libera o foco
[Clk]::SetForegroundWindow($p.MainWindowHandle) | Out-Null
Start-Sleep -Milliseconds 800
$feitos = 0
foreach ($c in $Cliques) {
  if ([Clk]::GetForegroundWindow() -ne $p.MainWindowHandle) {
    Registrar-Passo -Acao 'clicar-por-coordenada' -Classe Escrita -Janela $Processo -Resultado 'abortado' -Prova 'janela alvo fora do primeiro plano'
    Write-Output "ABORTADO: $Processo nao esta em primeiro plano"; exit 3
  }
  $xy = $c.Split(','); [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point ([int]$xy[0]),([int]$xy[1])
  Start-Sleep -Milliseconds 250
  [Clk]::mouse_event(2,0,0,0,[UIntPtr]::Zero); [Clk]::mouse_event(4,0,0,0,[UIntPtr]::Zero)
  Start-Sleep -Milliseconds 800
  $feitos++
  Registrar-Passo -Acao 'clicar-por-coordenada' -Classe Escrita -Janela $Processo -Resultado 'clicado' -Prova "xy=$c (efeito ainda NAO provado: confira por fora da tela)"
}
"ok: $feitos clique(s) em $Processo"
