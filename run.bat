@ECHO OFF
echo [+] Building
npx quartz build
echo [+] Syncing
npx quartz sync 
echo [+] Done