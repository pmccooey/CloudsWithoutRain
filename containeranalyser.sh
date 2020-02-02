echo ....Cloning Github Repo....
#git clone https://github.com/x-cellent/clair-registry-example.git
cd clair-registry-example/

echo ....Composing Multiple Containers....
sudo docker-compose up -d

echo ....What Image Would You Like To Analyze?....
read IMAGE

echo ....Pulling Image From Docker....
docker pull $IMAGE
docker tag $IMAGE localhost:5000/$IMAGE
echo ....Pushing Image To localhost:5000....
docker push localhost:5000/$IMAGE
cd $GOPATH
echo ....Installing Klar....
sudo go get github.com/optiopay/klar
cd ~/work/bin
sudo cp -fr klar /usr/local/bin
sudo cp -fr klar /usr/local/go/bin
sudo rsync -a klar /usr/local/go/bin
sudo rsync -a klar /usr/local/bin
cd ~
mkdir results
echo ....Running Vulnerability Scan Using Klar+Clair....
#CLAIR_ADDR=http://localhost:6060 CLAIR_OUTPUT=Low CLAIR_THRESHOLD=10 REGISTRY_INSECURE=TRUE klar localhost:5000/$IMAGE
echo ....Sorting Output Severity....
# echo "
#
#
#
# /////////////Klar+Clair Vulnerability Scan////////////////
#
#
#
# " > ~/results/ClairOutput.txt
cd ~
CLAIR_ADDR=http://localhost:6060 CLAIR_THRESHOLD=10 REGISTRY_INSECURE=TRUE klar localhost:5000/$IMAGE | sudo tee ~/results/ClairOutput.txt

# echo "
#
# /////////////Klar+Clair Vulnerability Scan////////////////
#
# " > ~/results/unknown/Unkown.txt
# CLAIR_ADDR=http://localhost:6060 CLAIR_OUTPUT=Unknown CLAIR_THRESHOLD=10 REGISTRY_INSECURE=TRUE klar localhost:5000/$IMAGE >> ~/results/uknown/Unknown.txt
#
# echo "
#
# /////////////Klar+Clair Vulnerability Scan////////////////
#
# " > ~/results/negligible/Negligible.txt
# CLAIR_ADDR=http://localhost:6060 CLAIR_OUTPUT=Negligible CLAIR_THRESHOLD=10 REGISTRY_INSECURE=TRUE klar localhost:5000/$IMAGE >> ~/results/negligible/Negligible.txt
#
# echo ....Sorting Output Severity....
#
# echo "
#
# /////////////Klar+Clair Vulnerability Scan////////////////
#
# " > ~/results/low/Low.txt
# CLAIR_ADDR=http://localhost:6060 CLAIR_OUTPUT=Low CLAIR_THRESHOLD=10 REGISTRY_INSECURE=TRUE klar localhost:5000/$IMAGE >> ~/results/low/Low.txt
# echo "
#
# /////////////Klar+Clair Vulnerability Scan////////////////
#
# " > ~/results/medium/Medium.txt
# CLAIR_ADDR=http://localhost:6060 CLAIR_OUTPUT=Medium CLAIR_THRESHOLD=10 REGISTRY_INSECURE=TRUE klar localhost:5000/$IMAGE >> ~/results/medium/Medium.txt
# echo "
#
# /////////////Klar+Clair Vulnerability Scan////////////////
#
# " > ~/results/high/High.txt
# CLAIR_ADDR=http://localhost:6060 CLAIR_OUTPUT=High CLAIR_THRESHOLD=10 REGISTRY_INSECURE=TRUE klar localhost:5000/$IMAGE >> ~/results/high/High.txt
# echo "
#
# /////////////Klar+Clair Vulnerability Scan////////////////
#
# " > ~/results/critical/Critical.txt
# CLAIR_ADDR=http://localhost:6060 CLAIR_OUTPUT=Critical CLAIR_THRESHOLD=10 REGISTRY_INSECURE=TRUE klar localhost:5000/$IMAGE >> ~/results/critical/Critical.txt
# echo "
#
# /////////////Klar+Clair Vulnerability Scan////////////////
#
# " > ~/results/defcon1/Defcon1.txt
# CLAIR_ADDR=http://localhost:6060 CLAIR_OUTPUT=Defcon1 CLAIR_THRESHOLD=10 REGISTRY_INSECURE=TRUE klar localhost:5000/$IMAGE >> ~/results/defcon1/Defcon1.txt
#



cd ~
mkdir ~/aevolume
cd ~/aevolume
echo ....Installing Anchore Engine + CLI....
docker pull docker.io/anchore/anchore-engine:latest
docker create --name ae docker.io/anchore/anchore-engine:latest
docker cp ae:/docker-compose.yaml ~/aevolume/docker-compose.yaml
docker rm ae
docker-compose pull
echo ....Composing Multiple Containers....
docker-compose up -d

cd ~/.local/bin
sudo apt-get update
sudo apt-get install python-pip
sudo pip install anchorecli

# if [cd ~/.anchore/ ;] && [ -s credentials.yaml ]; then
#   echo ....Adding Environment Variables....
#   echo "default:
#         ANCHORE_CLI_USER: 'admin'
#         ANCHORE_CLI_PASS: 'foobar'
#         ANCHORE_CLI_URL: 'http://localhost:8228/v1'" >> credentials.yaml
#   elif [ -s credentials.yaml ]; then
#     #statements
#     echo ....Forcibly Adding Environment Variables....
#     cd ~
#     mkdir ~/.anchore/
#     cd ~/.anchore/
#     echo "default:
#           ANCHORE_CLI_USER: 'admin'
#           ANCHORE_CLI_PASS: 'foobar'
#           ANCHORE_CLI_URL: 'http://localhost:8228/v1'" >> credentials.yaml

#   fi

cd ~/aevolume
echo ....Adding Image To Engine....
anchore-cli image add $IMAGE
echo ....Waiting For Image To Be Analaysed....
anchore-cli image wait $IMAGE
wait
anchore-cli image get $IMAGE
echo ....Adding Vulnerabilities To File....



#Anchore-CLI Low Medium High Critical
#Clair+Klar Uknown Negligible Low Medium High Critical, Defcon1
anchore-cli image vuln $IMAGE os >> ~/results/AnchoreOutput.txt
cd /home/linux/results
# echo "
#
# /////////////Anchore Vulnerability Scan////////////////
#
# " >>  ~/results/low/Low.txt
# cat AnchoreOutput.txt | grep Low >> ~/results/low/Low.txt
# echo "
#
# /////////////Anchore Vulnerability Scan////////////////
#
# " >>  ~/results/medium/Medium.txt
# cat AnchoreOutput.txt | grep Medium >> ~/results/medium/Medium.txt
# echo "
#
# /////////////Anchore Vulnerability Scan////////////////
#
# " >>  ~/results/high/High.txt
# cat AnchoreOutput.txt | grep High >> ~/results/high/High.txt
# echo "
#
# /////////////Anchore Vulnerability Scan////////////////
#
# " >>  ~/results/critical/Critical.txt
# cat AnchoreOutput.txt | grep Critical >> ~/results/critical/Critical.txt

cat ClairOutput.txt > ~/results/CombinedOutput.txt

cat AnchoreOutput.txt >> ~/results/CombinedOutput.txt

echo ....Finished, Please Check Results Folder....
