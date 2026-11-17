# Captura a tela virtual inteira, ou so a janela de um processo. Classe: Leitura. Saida: caminho do PNG.
# A captura pode mostrar segredo: nao anexe a imagem em relatorio publico.
param([string]$Processo = "", [string]$Saida = "$env:TEMP\captura_tela.png")
. "$PSScriptRoot\_comum.ps1"
Add-Type -AssemblyName System.Windows.Forms,System.Drawing
Add-Type @"
using System; using System.Runtime.InteropServices;
public class CapW { [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
 [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L,T,R,B; } }
"@
if ($Processo) {
  $p = Get-Process $Processo -ErrorAction Stop | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
  $r = New-Object CapW+RECT; [CapW]::GetWindowRect($p.MainWindowHandle, [ref]$r) | Out-Null
  $x=$r.L; $y=$r.T; $w=$r.R-$r.L; $h=$r.B-$r.T
} else {
  $b=[System.Windows.Forms.SystemInformation]::VirtualScreen; $x=$b.X; $y=$b.Y; $w=$b.Width; $h=$b.Height
}
$bmp = New-Object System.Drawing.Bitmap $w,$h
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($x,$y,0,0,(New-Object System.Drawing.Size $w,$h))
$bmp.Save($Saida,[System.Drawing.Imaging.ImageFormat]::Png)
Registrar-Passo -Acao 'capturar' -Classe 'Leitura' -Janela $Processo -Resultado 'ok' -Prova "${w}x${h}"
"$w x $h em ($x,$y) -> $Saida"
