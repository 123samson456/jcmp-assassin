-- ASSASSIN: a gamemode for the Just Cause 2: Mulitplayer mod by jc-mp.com
-- gamemode written by Drew Higgins (www.drewhiggins.com)

players = {}
targets = {}
gameInProgress = false

-- table shuffling function (src: http://snippets.luacode.org/snippets/Shuffle_array_145)
math.randomseed(os.time())
function shuffled(tab)
  local n, order, res = #tab, {}, {}
  for i=1,n do order[i] = { rnd = math.random(), idx = i } end
  table.sort(order, function(a,b) return a.rnd < b.rnd end)
  for i=1,n do res[i] = tab[order[i].idx] end
  return res
end

function StartGame(args)
  Chat:Broadcast("[Assassin] Starting new round. Your assignment is incoming!")
  players = shuffled(Server:GetPlayers())
  for index, player in players do
    -- gives all players a pistol and clears their other inventory
    player:ClearInventory()
    player:GiveWeapon(2, Weapon(2))
    -- key is predator, value is their prey
    if index == #players then
      targets[player] = players[1]
    else
      targets[player] = players[index + 1]
    end
    player:SendChatMessage("Your target is "..targets[player]..". Good luck!")
  end
  gameInProgress = true
end

-- takes the winner of the game as its argument
function EndGame(args)
  Chat:Broadcast("Game over! The winner was "..args.."!")
  players = {}
  targets = {}
  gameInProgress = false
end

function PlayerDeathOrQuit(args)
  for pred, prey in targets do
    if prey == args.player then
      predator = pred
      break
    end
  end
  -- if there's only one player left, its game over
  table.remove(players, args.player)
  if #players == 1 then
    EndGame(predator)
  else
    -- reassigns the dead player's target to their assassin and removes them from the player list
    table.remove(targets, targets[args.player])
    table.remove(targets, targets[pred])
    targets[pred] = targets[args.player]
    predator:SendChatMessage("Your target has perished! You now have their target, "..targets[args.player])
  end
end
