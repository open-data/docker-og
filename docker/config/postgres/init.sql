CREATE USER IF NOT EXISTS root;
ALTER USER root PASSWORD 'secret';
CREATE USER IF NOT EXISTS postgres;
ALTER USER postgres PASSWORD 'secret';
CREATE USER IF NOT EXISTS homestead;
ALTER USER homestead PASSWORD 'secret';