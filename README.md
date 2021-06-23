# Insertable
Convert a MySQL select query into an insertable mysql command. This is helpful when you want to replicate production data in your dev environment but don't want to either: create fake data manually, or load and or dump MySQL tables or databases. 

---

Take the output of the program and put it into a file like so

```javascript
mysql -f -uusername -p'password' database << EOF
  program output goes here
EOF
```

**Example query:**
```javascript
INSERTABLE_ENV=production ruby Insertable.rb -q"select * from cars where created_at > '2021-04-06 00:00:00' and created_at < '2021-04-06 23:59:59' and make = 'nissan' order by id desc limit 2" -tcars --fields id,model --without-id
```

**Example:**
```javascript
mysql -f -uusername -p'password' database << EOF
  insert into cars (created_at,make, model) values ('nissan', 'rogue', '2021-04-06 11:46:28');
  insert into cars (created_at,make, model) values ('nissan', 'Murano', '2021-04-06 11:54:12');
EOF
```
