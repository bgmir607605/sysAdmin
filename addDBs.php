<?php
$rootPass = 'xxxx';
$prefix = 'tp15_';
$query = "select * from users where id > 50";


$mysqli = new mysqli('localhost', 'root', $rootPass, 'server');
$mysqli->query("set names utf8");
$results = $mysqli->query($query);

while($row = $results->fetch_assoc()){
        $login = $prefix.''.$row["login"];
        $pass = $row["pass"];
        $query = 'create database '.$login.';';
        $mysqli->query($query);
        $query = "CREATE USER '$login'@'localhost' IDENTIFIED BY '$pass';";
        $mysqli->query($query);
        $query = "GRANT ALL PRIVILEGES ON `$login`.* TO '$login'@'localhost';";
        $mysqli->query($query);
        $query = 'FLUSH PRIVILEGES;';
        $mysqli->query($query);
}
?>
