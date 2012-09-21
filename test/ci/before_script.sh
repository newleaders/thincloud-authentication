rm -f test/dummy/config/database.yml

engine=$(ruby -e 'puts RUBY_ENGINE')

case $DB in
  "mysql" )
    mysql -e 'CREATE DATABASE thincloud_authentication_test;';;
  "postgres" )
    psql -c 'CREATE DATABASE thincloud_authentication_test;' -U postgres;;
esac

cp test/ci/database.$DB.$engine.yml test/dummy/config/database.yml

cd test/dummy
RAILS_ENV=test bundle exec rake db:setup db:migrate
