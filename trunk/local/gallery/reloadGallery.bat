@ECHO OFF

for /f "tokens=*" %%c in ('dir . /ad /b ') do (
echo indexing %%c
dir /b %%c\image > %%c\images.xml
dir /b %%c\video > %%c\videos.xml


echo ^<presentationLoader^> > %%c\presentations.xml
echo ^<presentations^> >> %%c\presentations.xml
for /f "tokens=*" %%g in ('dir %%c\presentations /ad /b ') do (
echo indexing %%c/%%g
 echo ^<slideshow name="%%g" ^> >> %%c\presentations.xml

 for /f "tokens=*" %%h in ('dir %%c\presentations\%%g /b ') do ( 
 echo indexing %%c/%%g/%%h
 echo ^<slide^>%%g/%%h^</slide^> >> %%c\presentations.xml
 ) 
 echo ^</slideshow ^> >> %%c\presentations.xml)
echo ^</presentations^> >> %%c\presentations.xml
echo ^</presentationLoader^> >> %%c\presentations.xml


)
echo Done indexing
exit

