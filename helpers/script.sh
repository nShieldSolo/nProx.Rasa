# AWS 
cd /etc/systemd/system
sudo systemctl enable kestrel-rasa.service
sudo systemctl start kestrel-rasa.service
cd /
sudo systemctl enable sshd
sudo systemctl start sshd