#!/bin/bash
source ~/.bash_profile

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

mkdir results

echo "${BLUE} ######################################################### ${RESET}"
echo "${BLUE} #AUDITING DOCKER SECURITY WITH DOCKER BENCH FOR SECURITY# ${RESET}"
echo "${BLUE} ######################################################### ${RESET}"

#git clone https://github.com/docker/docker-bench-security.git
cd ~/dockauto/docker-bench-security

sudo ./docker-bench-security.sh | tee -a ~/dockauto/results/docker-bench-security_report.txt

echo "${BLUE} ######################################################### ${RESET}"
echo "${BLUE} #   HOST SECURITY AUDITING WITH LYNIS & Linpeas          # ${RESET}"
echo "${BLUE} ######################################################### ${RESET}"

#git clone https://github.com/CISOfy/lynis

cd ~/dockauto/lynis 
sudo ./lynis audit system | tee -a ~/dockauto/results/lynis_report.txt

#cd Linpeas
#sudo sh linpeas.sh -a |tee -a ~/dockauto/results/linpeas_report.txt 

#cd ..
echo "${BLUE} ######################################################### ${RESET}"
echo "${BLUE} #  DOCKER IMAGE SCANNING FOR VULNERABILITIES WITH TRIVY # ${RESET}"
echo "${BLUE} ######################################################### ${RESET}"

cd ~/dockauto

while getopts ":d:" input;do
        case "$input" in
                d) image_name=${OPTARG}
                        ;;
               esac
        done
if [ -z "$image_name" ]     
       then
                echo "Please give a docker image name like \"-d nginx:1.15.12-alpine\""
               exit 2
fi
docker save $image_name -o ~/dockauto/results/$image_name.tar
cp ~/dockauto/results/$image_name.tar ~/dockauto/results/dock_image.tar
sudo ./trivy image --skip-update --offline-scan --input ~/dockauto/results/dock_image.tar | tee -a  ~/dockauto/results/trivy_$image_name.report.txt
#sudo trivy image $image_name | tee -a ~/dockauto/results/trivy_$image_name.report.txt

echo "${BLUE} ######################################################### ${RESET}"
echo "${BLUE} #    DOCKER IMAGE SCANNING FOR MISCONFIG WITH DOCKlE    # ${RESET}"
echo "${BLUE} ######################################################### ${RESET}"
#git clone https://github.com/goodwithtech/dockle.git
sudo ./dockle --input ~/dockauto/results/dock_image.tar | tee -a  ~/dockauto/results/dockle_$image_name.report.txt
#sudo dockle $image_name | tee -a  ~/dockauto/results/dockle_$image_name.report.txt

rm -rf ~/dockauto/results/dock_image.tar
echo "Deleted Temp dock_Image.tar file"
zip -r Results.zip ~/dockauto/results
echo "zipped results folder"
echo "${BLUE} ######################################################### ${RESET}"
echo "${BLUE} #                  Successfull completed                # ${RESET}"
echo "${BLUE} ######################################################### ${RESET}"




