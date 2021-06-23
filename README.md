# Insertable
Convert a MySQL select query into a chain of insertable mysql commands. This is helpful when you want to replicate production data in your development environment but don't want to either: create fake data manually, or load and or dump MySQL tables or databases. ...or you can just use the mysqldump --where switch(command line option) to replicate what this program does. Eventhough this only took me a single night after work to write, realizing that what I wrote is already a feature of mysqldump has left me feeling a mixture of a little embarrassment and mostly amused. 😂

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
> **-f** is for force. Remove this if you're absolutely not sure that this is what you want!
```javascript
mysql -f -uusername -p'password' database << EOF
  insert into cars (created_at,make, model) values ('nissan', 'rogue', '2021-04-06 11:46:28');
  insert into cars (created_at,make, model) values ('nissan', 'Murano', '2021-04-06 11:54:12');
EOF
```

Then execute that file containing your insertables with:
```javascript
chmod +x file
./file
```

**Usage:**
```javascript
    Usage example: ruby Insertable.rb -q'select * from cdrs limit 10' -tcars --fields make, model --without-id

    [ Option with * is mandatory! ]

      Option:
        --help,            Display this help messgage.
    * Option:
        --table,       -t, The name of the table that you are querying.
    * Option:
        --mysql-query, -q, MySQL query for the program to parse without ; or G terminator.
      Option:
        --without-id,      Remove the id field name and the id from the printed insertable.
    * Option:
        --fields f1,f2     This is the first and last field of the specified table that you are querying.     
```
