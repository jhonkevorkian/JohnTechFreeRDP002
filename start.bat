version: 2.1 

orbs:
  win: circleci/windows@2.2.0

jobs:
  build: 
    executor:
      name: win/default 
      size: "medium" 
    
    steps:
    - run: |
        Set-Content authtoken.txt "1wPc43xVccwK13O1xUcDkAGumcu_4F3xh1SdcRuUZ96Q8Rgj8" #enter your ngrok authtoken from https://dashboard.ngrok.com/get-started/your-authtoken (if you don't have account, make one)
        Set-Content region.txt "US" #enter region for the Ngrok servers (available: EU, US, JP, AP, SA) write one of them with capital letters
    - run: |
        Invoke-WebRequest https://raw.githubusercontent.com/tman10001/Windows2019RDP-AP/main/ngrok.exe -OutFile ngrok.exe
        Invoke-WebRequest https://raw.githubusercontent.com/tman10001/Windows2019RDP-US/main/Files/nssm.exe -OutFile nssm.exe
    - run: | 
        copy nssm.exe C:\Windows\System32
        copy ngrok.exe C:\Windows\System32
        copy authtoken.txt C:\Windows\System32
        copy region.txt C:\Windows\System32
    - run: |
        $authtoken = Get-Content authtoken.txt
        .\ngrok.exe authtoken $authtoken
    - run: |
        $region = Get-Content region.txt
        Invoke-WebRequest https://raw.githubusercontent.com/bEmcho-cyber/files/main/NGROK-$region.bat -Outfile NGROK-$region.bat
        Invoke-WebRequest https://raw.githubusercontent.com/bEmcho-cyber/files/main/NGROK-CHECK.bat -Outfile NGROK-CHECK.bat
        Invoke-WebRequest https://raw.githubusercontent.com/bEmcho-cyber/files/main/loop.bat -Outfile loop.bat
    - run: |
        $region = Get-Content region.txt
        cmd /c NGROK-$region.bat
    - run: |
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1
    - run: cmd /c sc start ngrok
    - run: cmd /c NGROK-CHECK.bat
    - run: cmd /c loop.bat
