$updateSession = new-object -com "Microsoft.Update.Session"; 
$updates=$updateSession.CreateupdateSearcher().Search($criteria).Updates
wuauclt.exe /resetauthorization /detectnow
