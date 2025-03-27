Param(
  [int] $s,
  [int] $sleep
)

if ($s -and $s -gt 0) {
  $sleep_duration = $s
}

if ($sleep -and $sleep -gt 0) {
  $sleep_duration = $sleep
}

if (-not $sleep_duration -or $sleep_duration -le 0) {
  $sleep_duration = 60
}

function ConvertTo-PlainText($secureString) {
  $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
  try {
      [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
  } finally {
      [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
  }
}

while ($true) {
  $password = Read-Host "Enter password" -AsSecureString
  $plainPassword = ConvertTo-PlainText $password
  if ( $plainPassword -and $plainPassword -ne "") {
    break
  }
}

$verifyPassword = Read-Host "Verify password" -AsSecureString
$plainVerifyPassword = ConvertTo-PlainText $verifyPassword
  if ( $plainPassword -ne $plainVerifyPassword) {
  Write-Output "password verification failed"
  exit 1
}

7z a -p"$password" -mhe=on -tzip "transfer.zip" "transfer/"
# Compress-Archive -Path "transfer/*" -DestinationPath "transfer.zip"

try {
  Push-Location $PSScriptRoot

  git checkout main
  try {
    git branch -D new_main 2>$null
  } catch {
    # ignore
  }
  git checkout --orphan new_main

  git add .vscode/tasks.json
  git add transfer/.gitkeep
  git add .gitignore
  git add pushp.ps1
  git add pushp.sh
  git add pushu.ps1
  git add pushu.sh
  git add pull.ps1
  git add pull.sh
  git add README.md
  git add transfer.zip

  git commit -m "Initial commit"
  git branch -D main
  git branch -m main
  git push origin -f main


  Write-Output "sleeping $sleep_duration ..."
  Start-Sleep -Seconds $sleep_duration


  # Remove-Item -Recurse -Force transfer/*
  # New-Item -Force -ItemType File -Path "transfer/.gitkeep"
  Remove-Item -Force transfer.zip

  git checkout --orphan new_main

  git rm --cached -r .
  git add .vscode/tasks.json
  git add transfer/.gitkeep
  git add .gitignore
  git add pushp.ps1
  git add pushp.sh
  git add pushu.ps1
  git add pushu.sh
  git add pull.ps1
  git add pull.sh
  git add README.md

  git commit -m "Initial commit"
  git branch -D main
  git branch -m main
  git push origin -f main

  Remove-Item -Recurse -Force .git/logs
}
finally {
  Pop-Location
}
