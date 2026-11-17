# Abre um programa como administrador. Classe: Escrita (exige -Permitir Escrita).
# O humano precisa clicar "Sim" no UAC: avise ANTES. Nunca contorna o UAC.
param([Parameter(Mandatory)][string]$Exe, [string]$Argumentos = "", [string]$Permitir = "")
. "$PSScriptRoot\_comum.ps1"
Confirmar-Risco -Classe Escrita -Permitir $Permitir -Acao 'abrir-como-admin'
if (-not (Test-Path $Exe)) { Write-Output "nao achei: $Exe"; exit 2 }
Write-Output "Vai aparecer o aviso do Windows (UAC): clique em Sim."
try {
  if ($Argumentos) { Start-Process -FilePath $Exe -ArgumentList $Argumentos -Verb RunAs -ErrorAction Stop }
  else { Start-Process -FilePath $Exe -Verb RunAs -ErrorAction Stop }
} catch {
  Registrar-Passo -Acao 'abrir-como-admin' -Classe Escrita -Janela ([IO.Path]::GetFileName($Exe)) -Resultado 'uac-negado'
  Write-Output "UAC cancelado ou negado: $($_.Exception.Message). Pare e reporte; nao tente contornar."; exit 4
}
Start-Sleep -Seconds 3
$nome = [IO.Path]::GetFileNameWithoutExtension($Exe)
$proc = Get-Process $nome -ErrorAction SilentlyContinue
Registrar-Passo -Acao 'abrir-como-admin' -Classe Escrita -Janela $nome -Resultado $(if ($proc) { 'aberto' } else { 'nao-visto' }) -Prova "processos=$(@($proc).Count)"
$proc | Select-Object ProcessName,Id,MainWindowTitle | Format-Table -AutoSize | Out-String
