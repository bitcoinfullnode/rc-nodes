#!/bin/bash
VERSION=$1
if [ -x ${VERSION} ];
then
	echo VERSION not defined
	exit 1
fi
PACKAGE=hz-client-${VERSION}
echo PACKAGE="${PACKAGE}"
CHANGELOG=hz-client-${VERSION}.changelog.txt
OBFUSCATE=$2

FILES="changelogs conf html lib resource contrib"
FILES="${FILES} horizon.exe hzservice.exe"
FILES="${FILES} 3RD-PARTY-LICENSES.txt AUTHORS.txt COPYING.txt DEVELOPER-AGREEMENT.txt LICENSE.txt"
FILES="${FILES} DEVELOPERS-GUIDE.md README.txt"
FILES="${FILES} mint.bat mint.sh run.bat run.sh run-tor.sh run-desktop.sh compact.sh compact.bat sign.sh"
FILES="${FILES} Horizon_Wallet.url Dockerfile"

unix2dos *.bat
echo compile
./compile.sh
rm -rf html/doc/*
rm -rf hz-client
rm -rf ${PACKAGE}.jar
rm -rf ${PACKAGE}.exe
rm -rf ${PACKAGE}.zip
mkdir -p hz-client/
mkdir -p hz-client/logs

FILES="${FILES} classes src"
FILES="${FILES} compile.sh javadoc.sh jar.sh package.sh"
FILES="${FILES} win-compile.sh win-javadoc.sh win-package.sh"
echo javadoc
./javadoc.sh

echo copy resources
cp installer/lib/JavaExe.exe horizon.exe
cp installer/lib/JavaExe.exe hzservice.exe
cp -a ${FILES} hz-client
echo gzip
for f in `find hz-client/html -name *.html -o -name *.js -o -name *.css -o -name *.json  -o -name *.ttf -o -name *.svg -o -name *.otf`
do
	gzip -9c "$f" > "$f".gz
done
cd hz-client
echo generate jar files
../jar.sh
echo package installer Jar
../installer/build-installer.sh ../${PACKAGE}
#echo create installer exe
#../installer/build-exe.bat ${PACKAGE}
echo create installer zip
cd -
zip -q -X -r ${PACKAGE}.zip hz-client -x \*/.idea/\* \*/.gitignore \*/.git/\* \*/\*.log \*.iml hz-client/conf/nhz.properties hz-client/conf/logging.properties
rm -rf hz-client

#echo signing zip package
#../jarsigner.sh ${PACKAGE}.zip

echo signing jar package
../jarsigner.sh ${PACKAGE}.jar

echo creating change log ${CHANGELOG}
echo -e "Release $1\n" > ${CHANGELOG}
echo -e "https://hz-services.com/downloads/${PACKAGE}.zip\n" >> ${CHANGELOG}
echo -e "sha256:\n" >> ${CHANGELOG}
sha256sum ${PACKAGE}.zip >> ${CHANGELOG}

echo -e "\nhttps://hz-services.com/downloads/${PACKAGE}.jar\n" >> ${CHANGELOG}
echo -e "sha256:\n" >> ${CHANGELOG}
sha256sum ${PACKAGE}.jar >> ${CHANGELOG}

echo -e "\nhttps://hz-services.com/downloads/${PACKAGE}.exe\n" >> ${CHANGELOG}
#echo -e "sha256:\n" >> ${CHANGELOG}
#sha256sum ${PACKAGE}.exe >> ${CHANGELOG}

#echo -e "The exe and jar packages must have a digital signature by \"Stichting NXT\"." >> ${CHANGELOG}

echo -e "\n\nChange log:\n" >> ${CHANGELOG}

cat changelogs/${CHANGELOG} >> ${CHANGELOG}
echo >> ${CHANGELOG}

#gpg --detach-sign --armour --sign-with 0x811D6940E1E4240C ${PACKAGE}.zip
#gpg --detach-sign --armour --sign-with 0x811D6940E1E4240C ${PACKAGE}.jar
##gpg --detach-sign --armour --sign-with 0x811D6940E1E4240C ${PACKAGE}.exe

#gpg --clearsign --sign-with 0x811D6940E1E4240C ${CHANGELOG}
#rm -f ${CHANGELOG}
#gpgv ${PACKAGE}.zip.asc ${PACKAGE}.zip
#gpgv ${PACKAGE}.jar.asc ${PACKAGE}.jar
##gpgv ${PACKAGE}.exe.asc ${PACKAGE}.exe
#gpgv ${CHANGELOG}.asc
sha256sum -c ${CHANGELOG}.asc
##jarsigner -verify ${PACKAGE}.zip
jarsigner -verify ${PACKAGE}.jar


