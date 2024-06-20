import 'package:drift/drift.dart';

Future<void> runMigrationV2(Migrator m) async {
  // need to create new table because got the following error when using alter with default value
  // https://stackoverflow.com/questions/61966855/how-to-add-column-to-database-with-default#:~:text=sqlite3.OperationalError%3A%20Cannot%20add%20a%20column%20with%20non%2Dconstant%20default.
  await m.database.customStatement("""
  create table orders_temp(
    id int primary key, 
    customer text not null,
    total real not null,
    created_at datetime default current_timestamp
  );

  insert into orders_temp(id, customer, total, created_at) select id, customer, total, current_timestamp from orders;
  drop table orders;  -- back it up first!
  alter table orders_temp rename to orders;
  """);
}