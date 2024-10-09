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

###################################################################################################
# Functions

function Get-SymlinkTarget {
  [CmdletBinding()]
  param([parameter(ValueFromPipelineByPropertyName)] $Path)
  process { $_ | Resolve-Path | Get-Item | Select-Object }
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

#✦ ❯ alias | fzf -m | awk -F= '
#{
#  gsub(/'"'"'/, "", $2)
#  print "function", $1, "{", $2, "@args", "}"
#  names[NR] = "\"" $1 "\""
#}
#END {
#  expr="@("
#  for (i = 1; i < NR; i++)
#    expr=expr names[i] ", "
#  expr = expr names[NR] ") | Remove-Alias -Force 2>$null"
#  print expr
# }'
function gc { git commit -v @args }
function gca { git commit -v -a @args }
function gcm { git switch "$(git default-branch || echo .)" @args }
function gcob { git switch -c @args }
function gcop { git checkout -p @args }
function gd { git diff --color @args }
function gdc { git diff --color --cached @args }
function gfo { git fetch origin @args }
function gl { git pull @args }
function glr { git pull --rebase @args }
function glrp { glr && gp @args }
function gp { git push -u @args }
function gpa { git push all --all @args }
function grt { cd -- "$(gtl || pwd)" @args }
function gs { git status -sb @args }
function gsrt { git rev-parse --show-toplevel @args }
function gsw { git stash show --patch @args }
function gtl { git rev-parse --show-toplevel @args }
function gtlr { git rev-parse --show-cdup @args }
function gw { git show @args }
function gwd { git rev-parse --show-prefix @args }
@('gc', 'gca', 'gcm', 'gcob', 'gcop', 'gd', 'gdc', 'gfo', 'gl', 'glr', 'glrp', 'gp', 'gpa', 'grt', 'gs', 'gsrt', 'gsw', 'gtl', 'gtlr', 'gw', 'gwd') | Remove-Alias -Force 2>$null

if ( Import-Module WslInterop -ErrorAction SilentlyContinue ) {
  Import-WslCommand 'sh', 'bash', 'zsh',
  'emacs',
  'grep',
  'awk',
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
  'home-manager'
}

if ( Get-Command nvim.exe -ErrorAction SilentlyContinue ) {
  Set-Alias -Name vim -Value nvim
}

###################################################################################################
# Editor

if ($host.Name -eq 'ConsoleHost') {
  $script:PSReadlineOptions = @{
    EditMode                      = 'Emacs'
    HistoryNoDuplicates           = $true
    HistorySearchCursorMovesToEnd = $true
    Colors                        = @{
      'Default'   = '#e8e8d3'
      'Comment'   = '#888888'
      'Keyword'   = '#8197bf'
      'String'    = '#99ad6a'
      'Operator'  = '#c6b6ee'
      'Variable'  = '#c6b6ee'
      'Command'   = '#8197bf'
      'Parameter' = '#e8e8d3'
      'Type'      = '#fad07a'
      'Number'    = '#cf6a4c'
      'Member'    = '#fad07a'
      'Emphasis'  = '#f0a0c0'
      'Error'     = '#902020'
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
# Completion

# winget
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
  [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
  $Local:word = $wordToComplete.Replace('"', '""')
  $Local:ast = $commandAst.ToString().Replace('"', '""')
  winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

###################################################################################################
# Hooks

Invoke-Expression (& { (zoxide init powershell | Out-String) })

Invoke-Expression (&starship init powershell)