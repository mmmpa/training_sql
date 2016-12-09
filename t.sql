SELECT
COUNT(*)
FROM "students"
WHERE "students"."id"
IN (
   SELECT
   DISTINCT "students"."id"
   FROM "students"
   INNER JOIN "friend_ships" ON "friend_ships"."owner_id" = "students"."id"
   INNER JOIN "students" "friends_students" ON "friends_students"."id" = "friend_ships"."ownee_id"
   WHERE (
      friends_students.birth_day >= '2000-01-01' ANDfriends_students.birth_day < '2001-01-01' ))
AND ( birth_day >= '2000-01-01' AND birth_day < '2001-01-01' )
