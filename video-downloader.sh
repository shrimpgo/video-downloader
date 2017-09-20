#!/bin/bash
echo -e "\e[01;32m================================================="
echo -e "|						|"
echo -e "|               \e[01;91mVideo Downloader\e[01;32m       		|"
echo -e "|						|"
echo -e "=================================================\e[0m"
echo -e "				\e[01;34mby: Shrimp GO\e[00m"

echo -ne "\e[01mInsert link list: \e[0m"
read chunk

# Check if URL is valid
check_url=$(curl -s -o /dev/null -w "%{http_code}" $chunk)
if [ $check_url == 000 ]
then
	echo -e "\e[01;91mInvalid URL:\e[0m $chunk\n\e[01;91mClosing...\e[0m\n"
	exit 1
fi

echo -ne "\e[01mInsert name of file: \e[0m"
read file

# Change spaces for underline (anti-dumb-users)
file=$(echo $file | sed 's/ /_/g;s/[^a-z|A-Z|0-9|_]//g')

dir=temp

# Delete $dir if exists (avoiding to mix old contents)
if [ ! -d $dir ]
then
	mkdir $dir
else
	echo -e "\e[01;93mDeleting \"$dir\"...\e[0m\n"
	rm -rf $dir
	mkdir $dir
fi

# Downloading list (by URL at $chunk)
echo -e "\e[01mDownloading list...\e[0m"
lista="lista.m3u8"
wget -q $chunk -O $dir/$lista

# Checking if m3u8 file is valid
if [ -z $(egrep "^#EXTM3U" $dir/$lista) ]
then
	echo -e "\e[01;91mThis list is not valid. Closing...\e[0m\n"
	exit 1
fi

# Calculating number of segments
lenseg=$(grep '^https://' $dir/$lista | wc -l)

# Downloading video segments
echo -e "\e[01mDownloading video's segments...\e[0m\n"
cont=1
while [ $cont -lt $lenseg ]
	do
		for i in $(grep '^https://' $dir/$lista)
		do
			# Progress bar while downloading
			perok=$(echo "$cont * 100 / $lenseg" | bc)
			pernotok=$(echo "100 - ($cont * 100 / $lenseg)" | bc)
			echo -ne "\e[01m[$(printf '#%.0s' $(seq 1 $perok))""$(printf ' %.0s' $(seq 1 $pernotok))]($perok%)\e[0m\r"
			sleep 1
			wget -q $i -O $dir/seg$cont && cont=$((cont+1))
		done
	done
echo -e "\n\n\e[01mDownload completed!\e[0m"
echo -e "\e[01mDecoding and contatenating all of segments in one file...\e[0m"

# Downloading encryption key of video segments
echo -e "\e[01mAcquiring key...\e[0m"
key=$(wget -q $(egrep -o 'https://(.*)encryption.key(.*)hmac=([0-9a-f])+' $dir/$lista) -O - | xxd -p)

iv=$(egrep -o 'IV=([0-9a-z]+)' $dir/$lista | sed 's/IV=0x//')
for i in $(seq 1 $lenseg)
do
	# If IV exists in URL, keep that in var iv, if not, every segment file has its IV, corresponding with segment number and padding zeros in
	# the left until reach 32 digits. Ex.: 00000000000000000000000000000001 corresponding with segment 1.
	if [ -z $iv ]
	then
		if [ $(echo -n $i|wc -c) -eq 1 ]
		then
			j=$(printf '0%.0s' {1..31})
		elif [ $(echo -n $i|wc -c) -eq 2 ]
		then
			j=$(printf '0%.0s' {1..30})
		else
			j=$(printf '0%.0s' {1..29})
		fi
	iv=$j$i
	fi
	# Decoding every segment with key and IV
	openssl aes-128-cbc -d -K $key -iv $iv -nosalt -in $dir/seg$i -out $dir/seg$i.mp4
	# Concatenating all of segments in one file
	cat $dir/seg$i.mp4 >> $file.mp4
done
echo -e "\e[01mVideo \e[01;93m$file.mp4\e[0m \e[01mcreated!\e[0m\n"
echo -ne "\e[01mDelete temp files? [S/n] \e[0m"
read ask
if [[ $ask == "s" || $ask == "S" || $ask == "" ]]
then
	rm -rf $dir
	echo -e "\e[01;93mTemp files deleted!\e[0m"
else
	echo -e "\e[01;93mTemp files unchanged in $(pwd)/$dir\e[0m"
fi
