ALTER TABLE groups DROP COLUMN `group_type`;
ALTER TABLE groups ADD COLUMN `user_id` int(10) unsigned;
UPDATE groups SET user_id = 4;
ALTER TABLE `groups` MODIFY  user_id int(10) unsigned NOT NULL;
create index `user_id__name` on `groups` (user_id, name);