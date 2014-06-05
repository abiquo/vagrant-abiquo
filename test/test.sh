
cd test

vagrant up --provider=abiquo
vagrant up
vagrant provision
vagrant rebuild
vagrant halt
vagrant destroy

cd ..
