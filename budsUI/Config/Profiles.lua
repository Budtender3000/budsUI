local K, C, L, _ = select(2, ...):unpack()

-- Per Class Config (overwrites general)
-- Class Type need to be UPPERCASE -- DRUID, MAGE ect ect...
if K.Class == "DRUID" then
end

if K.Role == "Tank" then
end

-- Per Character Name Config (overwrite general and class)
-- Name need to be case sensitive
if K.Name == "CharacterName" then
end

-- Per Max Character Level Config (overwrite general, class and name)
if K.Level ~= MAX_PLAYER_LEVEL then
end