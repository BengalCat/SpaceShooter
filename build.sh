cd source/
printf "Creating .love file\n"
zip -9 -q -r SpaceShooter.love .
cd ..
printf "Moving .love file to builds directory\n"
cp source/SpaceShooter.love builds/linux/
cp source/SpaceShooter.love builds/windows/
rm source/SpaceShooter.love
printf "Creating .exe file\n"
cd builds/windows/
cat love.exe SpaceShooter.love > SpaceShooter.exe
cd ..
cd ..
read -n 1 -p "Do you want to update the repository (y/n)? " yn
if [ $yn = "y" ]
then
	printf "\n"
	read -p "Enter message: " message
	git add -A
	git commit -m "$message"
	git push origin master
fi
printf "\nDone\n"