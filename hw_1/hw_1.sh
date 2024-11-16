docker pull docker.io/vldbuk/gpdb_demo_repo:gpdb_demo
docker run -ti -d --privileged=true -p 5432:5432 docker.io/vldbuk/gpdb_demo_repo:gpdb_demo "/usr/lib/systemd/systemd"
docker exec -it 3b761880d471720ef32262dd1c3144db5a1868dcddef15bf47b2cb69e69f9aea bash
su gpadmin
gpstart -qa
psql -d demo