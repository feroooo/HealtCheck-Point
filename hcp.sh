#!/bin/bash
#====================================================================================================
# Baslik:           hcp.sh
# Kullanim:         ./hcp.sh
# Amaci:            Otomatik health check yapmak.
# Sahibi:           Feridun OZTOK
# Versiyon:         1.0.0
# Tarih:            1 Nisan 2023
#====================================================================================================

#====================================================================================================
#Degiskenler
#====================================================================================================
source /etc/profile.d/CP.sh
source /var/log/egis/database.txt
DATE=`date +%Y-%m-%d`
FILE=$DATE"_"$HOSTNAME".tar.gz"
MEVCUTSURUM="Script Versiyon  : 1.0.0"
#====================================================================================================
#show_version_info Fonksiyon
#====================================================================================================
show_version_info() {
	echo ""
	echo "Script Versiyon  : 1.0.0"
	echo "Script Tarihi    : 1 Nisan 2023"
	echo "Son Guncelleyen  : Feridun OZTOK"
	echo ""
	exit 0
}
#====================================================================================================
#versiyon_kontrol Fonksiyon
#====================================================================================================
versiyon_kontrol() {
	sed '2,$d' surumyakala.txt >surumazalt.txt
	awk -F"MEVCUTSURUM=" '{print $2}' surumazalt.txt >surumkisa.txt
	sed 's/"//g' surumkisa.txt >surumtemizlenmis.txt
	GUNCELSURUM=$(<surumtemizlenmis.txt)
	rm surum*
	if [[ "$MEVCUTSURUM" == "$GUNCELSURUM" ]]; then
		echo "$MEVCUTSURUM" "Script calismaya uygun"
	else
		echo "Kullanilan surum guncel degil. Surumun $GUNCELSURUM olmasi gerekiyor."
		echo "./hcp.sh -u komutu ile guncelleyebilirsiniz. Script kapanacak."
		exit
	fi
}
#====================================================================================================
#show_help_infoFonksiyon
#====================================================================================================
show_help_info() {
	echo ""
	echo "Bu script, Feridun OZTOK tarafindan CheckPoint Management ve Gateway uzerinde"
	echo "otomatik saglik kontrolu yapmak icin yazilmistir."
	echo ""
	echo "Script ./hcp.sh seklinde calisir. Kullanilabilir diger parametreler -v -u -h 'dir"
	echo ""
	echo "./hcp.sh -v ile mecvut scriptin surumunu ogrenebilirsiniz."
	echo "./hcp.sh -u ile script surumunu guncelleyebilirsiniz."
	echo "./hcp.sh -h ve diger tum tuslar su an okudugunuz yardim menusunu getirecektir."
	echo ""
	exit 0
}
#====================================================================================================
#download_updates Fonksiyon
#====================================================================================================
download_updates() {
	rm hcp.sh
	curl_cli http://script.egisbilisim.com.tr/script/hcp.sh | cat > hcp.sh && chmod 770 hcp.sh
	exit 0
}
#====================================================================================================
#Fonksiyon Tuslari
#====================================================================================================
while getopts ":v :u :h" opt; do
	case "${opt}" in
	h)
		show_help_info
		;;
	u)
		download_updates
		;;
	v)
		show_version_info
		;;
	*)
		#Catch all for any other flags
		show_help_info
		exit 1
		;;
	esac
done
#====================================================================================================
#Health Check islemi yapiliyor
#====================================================================================================
hcp -r all --include-wts yes --include-topology yes --include-charts yes --silent 
#====================================================================================================
#Dosyanin yeniden adlandirilmasi ve kopyalanmasi
#====================================================================================================
cd /var/log/egis/
if [ -d hcp ]
	then
		cp /var/log/hcp/last/hcp_report* /var/log/egis/hcp/$FILE  
		cd /var/log/egis/hcp/
	else
		mkdir hcp
		cp /var/log/hcp/last/hcp_report* /var/log/egis/hcp/$FILE  
		cd /var/log/egis/hcp/
fi
#====================================================================================================
#FTP ile dosyanin gonderilmesi
#====================================================================================================
ftp -p -n $HOST  <<END_SCRIPT
ascii
quote USER $HCPUSER
quote PASS $HCPPWD
bin
put $FILE
quit
END_SCRIPT
#====================================================================================================
#Cikis
#====================================================================================================
exit
#====================================================================================================
#Surum Notlari
#====================================================================================================
#1.0.0 - Script olusturuldu.