#!/bin/bash
#====================================================================================================
# Baslik:           hcp.sh
# Kullanim:         ./hcp.sh
# Amaci:            Otomatik health check yapmak.
# Sahibi:           Feridun OZTOK
# Versiyon:         1.0.1
# Tarih:            1 Nisan 2023
#====================================================================================================

#====================================================================================================
#Degiskenler
#====================================================================================================
source /etc/profile.d/CP.sh
source /var/log/egis/database.txt
DATE=`date +%Y-%m-%d`
FILE=$DATE"_"$HOSTNAME".tar.gz"
CLIREPORT=$DATE"_"$HOSTNAME".txt"
MEVCUTSURUM="Script Versiyon  : 1.0.1"
clear
#====================================================================================================
#show_version_info Fonksiyon
#====================================================================================================
show_version_info() {
	echo ""
	echo "Script Versiyon  : 1.0.1"
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
	echo "Bu script, Feridun OZTOK tarafindan CheckPoint management ve gateway uzerinde"
	echo "otomatik saglik kontrolu yapmak ve EGIS tarafına gonderilmek icin yazilmistir."
	echo ""
	echo "Script ./hcp.sh seklinde calisir. Kullanilabilir diger parametreler -v -u -h 'dir"
	echo "/var/log/database.txt dosyasindan FTP icin gerekli kullanici adi ve sifre bilgisini alir."
	echo "HCPUSER ve HCPPWD degerlerini kullanir."
	echo "Eski ciktilari saklamak adina olusturulan dosya /var/log/egis/hcp/ altina kopyalanir."
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
#Reklamlar
#====================================================================================================
echo
echo
echo *#######################################################*
echo *#_________________ HealthCheck Point ________________##*
echo *#___________________ Version 1.0.1 __________________##*
echo *#_____________ Creator by Feridun OZTOK _____________##*
echo *#_ Egis Proje ve Danismanlik Bilisim Hiz. Ltd. Sti. _##*
echo *#____________ support@egisbilisim.com.tr ____________##*
echo *#######################################################*
echo
echo
#====================================================================================================
#Health Check islemi yapiliyor
#====================================================================================================
echo "Health Check islemi basliyor. Ciktilar /var/log/egis/hcp/$CLIREPORT dosyasinin icine yazilacakdir. Bu sirada ekranda islem gorunmez."
hcp -r all --include-wts yes --include-topology yes --include-charts yes > /var/log/egis/hcp/$CLIREPORT
echo "Health Check islemi bitti."
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
echo "Ciktilar EGIS'e gonderiliyor."
ftp -p -n $HOST  <<END_SCRIPT
ascii
quote USER $HCPUSER
quote PASS $HCPPWD
bin
put $FILE
ascii
put $CLIREPORT
quit
END_SCRIPT
#====================================================================================================
#Cikis
#====================================================================================================
echo "Script tamamlandi, cikis yapiliyor."
exit
#====================================================================================================
#Surum Notlari
#====================================================================================================
#1.0.1 - HCP'nin silent calismasi iptal edildi.
#1.0.1 - HCP'nin ekrana yazdikleri CLIREPORT adinda tarih ile olusan TXT icine yazilmaya baslandi.
#1.0.1 - CLIREPORT FTP ile gonderilmeye baslandi.
#1.0.1 - Help menusu yenilendi.
#1.0.1 - Ekran temizleme, reklam ve bildirimler eklendi.
#1.0.0 - Script olusturuldu.