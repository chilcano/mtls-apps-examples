#!/usr/bin/env bash

sudo apt-get update
sudo apt-get -yqq install language-pack-en
sudo apt-get -yqq install puppet-master puppet-module-puppetlabs-stdlib
sudo puppet config set --section master autosign true
sudo systemctl restart puppet-master
sudo chown ${username}:${username} /etc/puppet/code

echo "--> Setting hostname..."
echo "${hostname}" | sudo tee /etc/hostname
sudo hostname -F /etc/hostname

echo "--> Adding hostname to /etc/hosts"
sudo tee -a /etc/hosts > /dev/null <<EOF

# For local resolution
$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)  ${hostname}
EOF

echo "--> Create new user, edit ssh settings"
sudo useradd ${username} \
   --shell /bin/bash \
   --create-home 
echo '${username}:${ssh_pass}' | sudo chpasswd
sudo sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo service sshd reload

echo "--> Adding ${username} user to sudoers"
sudo tee /etc/sudoers.d/${username} > /dev/null <<"EOF"
${username} ALL=(ALL:ALL) ALL
EOF
sudo chmod 0440 /etc/sudoers.d/${username}
sudo usermod -a -G sudo ${username}

echo "--> Docker"
curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -a -G docker ${username}
sudo systemctl enable docker

echo "--> Wetty"
docker run --rm -p 80:3000 --detach wettyoss/wetty --ssh-host=172.17.0.1 --ssh-user ${username}

echo "--> Improving the Linux Prompt with Fancy Prompt"
curl -sS https://raw.githubusercontent.com/diogocavilha/fancy-git/master/install.sh | sh
. ~/.bashrc
fancygit human
. ~/.bashrc

echo "--> Cloning Git repos into workdir"
sudo mkdir /home/${username}/workdir
sudo chown -R ${username} /home/${username}/workdir
cd /home/${username}/workdir
sudo git clone ${gitrepo}

echo "--> Copying Puppet manifest files into Puppet server"
mkdir -p /home/${username}/workdir/puppet_tmp
#sudo mv workdir/mtls-emojivoto-tf/conf/puppet/code/environments/*  /home/${username}/etc/puppet/code
cp -R /home/${username}/workdir/mtls-emojivoto-tf/conf/puppet/code/environments/*  /home/${username}/workdir/puppet_tmp/

#sed -E "s/node '(.*).emojivoto.local'/node '${prefix}-\1-${type_panda}'/g" conf/puppet/code/environments/production/data/common.yaml
sed -i -E "s/ca.emojivoto.local/${prefix}-ca-${type_panda}/g" /home/${username}/workdir/pp_code/conf/puppet/code/environments/production/data/common.yaml
sed -i -E "s/web.emojivoto.local/${prefix}-web-${type_panda}/g" /home/${username}/workdir/pp_code/conf/puppet/code/environments/production/data/common.yaml
sed -i -E "s/emoji.emojivoto.local/${prefix}-emoji-${type_panda}/g" /home/${username}/workdir/pp_code/conf/puppet/code/environments/production/data/common.yaml
sed -i -E "s/voting.emojivoto.local/${prefix}-voting-${type_panda}/g" /home/${username}/workdir/pp_code/conf/puppet/code/environments/production/data/common.yaml

#sed -E "s/node '(.*).emojivoto.local'/node '${prefix}-\1-${type_panda}'/g" conf/puppet/code/environments/production/manifests/site.pp
sed -i -E "s/node '(.*).emojivoto.local'/node '${prefix}-\1-${type_panda}'/g" /home/${username}/workdir/pp_code/conf/puppet/code/environments/production/manifests/site.pp

#sed -E "s/web.emojivoto.local/${prefix}-web-${type_panda}/g" conf/puppet/code/environments/production/modules/envoy/files/emojivoto-web.yaml
sed -i -E "s/web.emojivoto.local/${prefix}-web-${type_panda}/g" /home/${username}/workdir/pp_code/conf/puppet/code/environments/production/modules/envoy/files/emojivoto-web.yaml
sed -i -E "s/emoji.emojivoto.local/${prefix}-emoji-${type_panda}/g" /home/${username}/workdir/pp_code/conf/puppet/code/environments/production/modules/envoy/files/emojivoto-web.yaml
sed -i -E "s/voting.emojivoto.local/${prefix}-voting-${type_panda}/g" /home/${username}/workdir/pp_code/conf/puppet/code/environments/production/modules/envoy/files/emojivoto-web.yaml