@ECHO OFF
echo Indexing gallery files...

"FoldersToXML\RobotFoldersToXml.exe silent" /wait
echo Starting Multitouch client
cd client
start RoboDays_MT.exe

