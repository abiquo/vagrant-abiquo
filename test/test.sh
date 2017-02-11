cd test

vagrant up --provider=abiquo
vagrant provision
vagrant halt
vagrant up
vagrant destroy --force

cd ..
