###################################################################################################
# Imports 

Import-Module @(
  'Pscx'
  'Microsoft.WinGet.CommandNotFound'
  'Microsoft.WinGet.Client'
  'Wsl'
)

###################################################################################################
# Variables

$env:POWERSHELL_TELEMETRY_OPTOUT = 'true'
$env:DOTFILES ??= "$HOME\.dotfiles"
$env:DOCUMENTS ??= [Environment]::GetFolderPath('mydocuments')

Add-PathVariable "$HOME\bin"
Add-PathVariable "$HOME\.emacs.d\bin"
Add-PathVariable "$APPDATA\.emacs.d\bin"
Add-PathVariable "$env:ProgramFiles\Emacs\emacs-29.2\bin"

###################################################################################################
# Functions

function Get-SymlinkTarget {
  [CmdletBinding()]
  param(
    [parameter(ValueFromPipelineByPropertyName)] $Path
  )
  process {
    $_ | Resolve-Path | Get-Item | Select-Object

  }
}

function Man { Get-Command @args -ErrorAction SilentlyContinue }
function Which { Get-Command @args -ErrorAction SilentlyContinue }
function Describe { $input | Get-Member }
function First($n) { $input | Select-Object -First ($n ?? 1) }
function Last($n) { $input | Select-Object -Last ($n ?? 1) }
function Skip($n) { $input | Select-Object -Skip ($n ?? 1) }
function Unique { $input | Select-Object -Unique }
function TypeOf { $_?.GetType() }
function CustomProperty([String]$label, [ScriptBlock]$expression) { @{label = $label; expression = $expression } }
function l { Get-ChildItem -Force @args }

Import-Module WslInterop -ErrorAction 'Continue' &&
Import-WslCommand `
  'emacs',
'nix',
'nix-build',
'nix-channel',
'nix-collect-garbage',
'nix-env',
'nix-hash',
'nix-instantiate',
'nix-shell',
'nix-store',
'nix-update',
'nixfmt',
'home-manager',
'sh',
'bash',
'zsh'

###################################################################################################
# Editor

if ($host.Name -eq 'ConsoleHost' && Import-Module PSReadLine -ErrorAction 'Continue') {
  $script:PSReadlineOptions = @{
    EditMode                      = 'Emacs'
    HistoryNoDuplicates           = $true
    HistorySearchCursorMovesToEnd = $true
    Colors                        = @{
      'Default' = '#e8e8d3'
      'Comment' = '#888888'
      'Keyword' = '#8197bf'
      'String' = '#99ad6a'
      'Operator' = '#c6b6ee'
      'Variable' = '#c6b6ee'
      'Command' = '#8197bf'
      'Parameter' = '#e8e8d3'
      'Type' = '#fad07a'
      'Number' = '#cf6a4c'
      'Member' = '#fad07a'
      'Emphasis' = '#f0a0c0'
      'Error' = '#902020'
    }
  }

  Set-PSReadlineOption @PSReadlineOptions

  # Searching for commands with up/down arrow is really handy.  The
  # option "moves to end" is useful if you want the cursor at the end
  # of the line while cycling through history like it does w/o searching,
  # without that option, the cursor will remain at the position it was
  # when you used up arrow, which can be useful if you forget the exact
  # string you started the search on.
  Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

  # Token-based editing not provided by Emacs
  Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
  Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellBackwardKillWord
  Set-PSReadLineKeyHandler -Key Alt+b -Function ShellBackwardWord
  Set-PSReadLineKeyHandler -Key Alt+f -Function ShellForwardWord
  Set-PSReadLineKeyHandler -Key Alt+B -Function SelectShellBackwardWord
  Set-PSReadLineKeyHandler -Key Alt+F -Function SelectShellForwardWord

  # Wrap current selection with parens
  Set-PSReadLineKeyHandler -Key 'Alt+(' `
    -BriefDescription ParenthesizeSelection `
    -LongDescription 'Put parenthesis around the selection or entire line and move the cursor to after the closing parenthesis' `
    -ScriptBlock {
    param($key, $arg)

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($selectionStart -ne -1) {
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '(' + $line.SubString($selectionStart, $selectionLength) + ')')
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    }
    else {
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
      [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
    }
  }

  # F1 for help on the command line - naturally
  Set-PSReadLineKeyHandler -Key F1 `
    -BriefDescription CommandHelp `
    -LongDescription 'Open the help window for the current command' `
    -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $commandAst = $ast.FindAll({
        $node = $args[0]
        $node -is [CommandAst] -and
        $node.Extent.StartOffset -le $cursor -and
        $node.Extent.EndOffset -ge $cursor
      }, $true) | Select-Object -Last 1

    $commandName = $commandAst?.GetCommandName()
    if ($commandName) {
      $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
      if ($command -is [AliasInfo]) {
        $commandName = $command.ResolvedCommandName
      }
      if ($commandName) {
        Get-Help $commandName -Full
      }
    }
  }
}

###################################################################################################
# Hooks

Invoke-Expression (&starship init powershell)

Invoke-Expression (& { (zoxide init powershell | Out-String) })
